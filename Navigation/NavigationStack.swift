//
//  NavigationStack.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import Foundation
import SwiftUI
import Combine

class NavigationStack<Name: Equatable>: ObservableObject {
    
    enum Action {
        case push(name: Name)
        case popTo(to: Name, stack: [Name])
    }
    
    fileprivate var stack: [Name] = []
    
    fileprivate var actionSubject: PassthroughSubject<Action, Never>
    
    init(initialName: Name){
        stack = [initialName]
        actionSubject = PassthroughSubject()
    }
    
    func popTo(_ name: Name) {
        if let index = stack.lastIndex(of: name) {
            if index > 0 {
                actionSubject.send(.popTo(to: name, stack: stack))
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
    
    func push(_ name: Name) {
        if stack.contains(name){
            fatalError("\(String(describing: name)) already exists in the navigation stack.")
        }
        
        stack.append(name)
        actionSubject.send(.push(name: name))
    }
}

struct NavigationStackView<Name: Equatable, Destination: View>: View {
    
    let initialDestinationName: Name
    let initialDestination: () -> Destination
    
    var body: some View {
        NavigationView {
            initialDestination()
        }
        .navigationViewStyle(.stack)
        .environmentObject(NavigationStack(initialName: initialDestinationName))
    }
}

struct NavigationStackLink<Destination: View, Label: View, Name: Equatable>: View {
    
    @EnvironmentObject var router: NavigationStack<Name>
    @Environment(\.presentationMode) var presentation
    
    let destination: () -> Destination
    let label: () -> Label
    let destinationName: Name
    
    @State private var isActive: Bool = false
    @State private var wasShown: Bool = false
    
    public init(destinationName: Name, @ViewBuilder destination: @escaping () -> Destination, @ViewBuilder label: @escaping () -> Label) {
        self.destinationName = destinationName
        self.destination = destination
        self.label = label
    }
    
    var body: some View {
        Group {
            Button(action: {
                self.router.push(self.destinationName)
                self.isActive = true
            }, label: label)
            
            NavigationLink(isActive: $isActive, destination: destination ){
                EmptyView()
            }
            .isDetailLink(false)
            .onReceive(router.actionSubject) { action in
               
                    switch action {
                    case .popTo(let to, let stack):
                        if let toIndex = stack.lastIndex(of: to) {
                            if stack[toIndex + 1] == destinationName {
                                isActive = false
                            }
                        }
                    case .push(let name):
                        if name == destinationName {
                            isActive = true
                        }
                        break
                    }
                }
            
            .onAppear {
                // If onAppear is called after wasShown is true we can assume the back button is being pressed
                if wasShown {
                    if router.stack.contains(destinationName){
                        router.pop()
                    }
                }
                wasShown = true
            }
        }
    }
}
