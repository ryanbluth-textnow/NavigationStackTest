//
//  NavigationStack.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import Foundation
import SwiftUI
import Combine

class NavigationStack<ItemIdentifier: Equatable>: ObservableObject {
    
    fileprivate enum Action {
        case push(ItemIdentifier)
        case popTo(to: ItemIdentifier, stack: [ItemIdentifier])
    }
    
    fileprivate var stack: [ItemIdentifier] = []
    
    fileprivate var actionSubject: PassthroughSubject<Action, Never>
    
    init(initialIdentifier: ItemIdentifier){
        stack = [initialIdentifier]
        actionSubject = PassthroughSubject()
    }
    
    func popTo(_ identifier: ItemIdentifier) {
        if let index = stack.lastIndex(of: identifier) {
            if index > 0 {
                actionSubject.send(.popTo(to: identifier, stack: stack))
                stack = Array(stack[0...index])
            }
        }
    }
    
    func pop() {
        if stack.count > 1 {
            let current = stack[stack.count - 2]
            actionSubject.send(.popTo(to: current, stack: stack))
            stack.removeLast()
        }
    }
    
    func popToRoot() {
        if let first = stack.first {
            actionSubject.send(.popTo(to: first, stack: stack))
            stack = [first]
        }
    }
    
    func push(_ identifier: ItemIdentifier) {
        if stack.contains(identifier){
            fatalError("\(String(describing: identifier)) already exists in the navigation stack.")
        }
        
        stack.append(identifier)
        actionSubject.send(.push(identifier))
    }
}

struct NavigationStackView<ItemIdentifier: Equatable, DestinationView: View>: View {
    
    let initialDestinationIdentifier: ItemIdentifier
    let initialDestination: () -> DestinationView
    
    var body: some View {
        NavigationView {
            initialDestination()
        }
        .navigationViewStyle(.stack)
        .environmentObject(NavigationStack(initialIdentifier: initialDestinationIdentifier))
    }
}

struct NavigationStackLink<DestinationView: View, Label: View, ItemIdentifier: Equatable>: View {
    
    @EnvironmentObject var navigationStack: NavigationStack<ItemIdentifier>
    
    let destination: () -> DestinationView
    let label: () -> Label
    let destinationIdentifier: ItemIdentifier
    
    @State private var isActive: Bool = false
    @State private var wasShown: Bool = false
    
    public init(destinationIdentifier: ItemIdentifier, @ViewBuilder destination: @escaping () -> DestinationView, @ViewBuilder label: @escaping () -> Label) {
        self.destinationIdentifier = destinationIdentifier
        self.destination = destination
        self.label = label
    }
    
    var body: some View {
        Group {
            Button(action: {
                self.navigationStack.push(self.destinationIdentifier)
                self.isActive = true
            }, label: label)
            
            NavigationLink(isActive: $isActive, destination: destination ){
                EmptyView()
            }
            .isDetailLink(false)
            .onReceive(navigationStack.actionSubject) { action in
                    switch action {
                    case .popTo(let to, let stack):
                        if let toIndex = stack.lastIndex(of: to) {
                            if stack[toIndex + 1] == destinationIdentifier {
                                isActive = false
                            }
                        }
                    case .push(let identifier):
                        if identifier == destinationIdentifier {
                            isActive = true
                        }
                        break
                    }
                }
            .onAppear {
                // If onAppear is called after wasShown is true we can assume the back button is being pressed
                if wasShown {
                    if navigationStack.stack.contains(destinationIdentifier){
                        navigationStack.pop()
                    }
                }
                wasShown = true
            }
        }
    }
}
