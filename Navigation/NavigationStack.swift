//
//  NavigationStack.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import Foundation
import SwiftUI

class NavigationStack<Name: Equatable>: ObservableObject {
    
    @Published fileprivate var stack: [Name] = []
    
    init(initialName: Name){
        stack = [initialName]
    }
    
    func popTo(_ name: Name) {
        if let index = stack.lastIndex(of: name) {
            if index > 0 {
                stack = Array(stack[0...index])
            }
        }
    }
    
    func pop() {
        if !stack.isEmpty {
            stack.removeLast()
        }
    }
    
    func popToRoot() {
        if let first = stack.first {
            stack = [first]
        }
    }
    
    fileprivate func push(_ name: Name) {
        
        if stack.contains(name){
            fatalError("\(String(describing: name)) already exists in the navigation stack.")
        }
        
        stack.append(name)
    }
}

struct NavigationStackView<Name: Equatable, Destination: View>: View {
    
    let initialDestinationName: Name
    let initialDestination: () -> Destination
    
    var body: some View {
        NavigationView {
            initialDestination()
        }.environmentObject(NavigationStack(initialName: initialDestinationName))
    }
}

struct NavigationStackLink<Destination: View, Label: View, Name: Equatable>: View {
    
    @EnvironmentObject var router: NavigationStack<Name>
    
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
        ZStack {
            Button(action: {
                self.router.push(self.destinationName)
                self.isActive = true
            }, label: label)
            
            NavigationLink(isActive: $isActive, destination: destination, label: {
                EmptyView()
            }).isDetailLink(false).onReceive(router.$stack, perform: {
                self.isActive = $0.contains(self.destinationName)
            })
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
