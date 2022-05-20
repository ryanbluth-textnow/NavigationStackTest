//
//  NavigationStack.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import Combine
import SwiftUI

protocol RouteBuilder {
    associatedtype ItemIdentifier: Equatable
    associatedtype RouteView: View
    
    func routeView(_ identifier: ItemIdentifier) -> RouteView
}

struct Router<ItemIdentifier, RB: RouteBuilder>: View where RB.ItemIdentifier == ItemIdentifier {
    
    @ObservedObject var navigationStack: NavigationStack<ItemIdentifier>
    let routeBuilder: RB
    
    var body: some View {
        NavigationView {
            navigationView()
        }
        .navigationViewStyle(.stack)
        .environmentObject(navigationStack)
    }
    
    // Builds a recursive NavigationLink structrue to match the current navigation stack.
    @ViewBuilder private func navigationView() -> some View {
        let res: AnyView? = navigationStack.stack.reversed().reduce(nil, { res, identifier in
            if identifier == navigationStack.stack.first! {
                return AnyView(
                    VStack {
                        routeBuilder.routeView(identifier).onAppear {
                            navigationStack.navigationItemAppeared(identifier)
                        }
                        res
                    }
                )
            } else {
                return AnyView(NavigationLink(isActive: Binding(get: {
                    navigationStack.isActive(identifier)
                }, set: { _,_ in
                }), destination: {
                    VStack {
                        if res != nil {
                            res
                        }
                        routeBuilder.routeView(identifier).onAppear {
                            navigationStack.navigationItemAppeared(identifier)
                        }
                    }
                }, label: EmptyView.init))
            }
        })
        res
    }
}

class NavigationStack<ItemIdentifier: Equatable>: ObservableObject {
   
    @Published fileprivate var stack: [ItemIdentifier] = []
    
    private let navigationItemAppearedSubject: PassthroughSubject<ItemIdentifier, Never>
    private var navigationItemAppearedSubscription: AnyCancellable?
    
    init() {
        self.stack = []
        self.navigationItemAppearedSubject = PassthroughSubject()
        
        // Collect the last and previous values from the navigationItemAppearedSubject so we can compare them.
        // We know the current view was popped by some external factor(ex: the back button) if the next value is before the previous value in the stack
        self.navigationItemAppearedSubscription = navigationItemAppearedSubject.scan((nil, nil)) { previous, next in
            // Collect the previous value and the next value in a tuple
            // ex: (nil, nil) -> .identifier1 = (nil, identifier1) -> .identifier2 = (identifier1, identifier2) -> .identifier2 = (identifier2, identifier3)
            (previous.1, next)
        }.sink(receiveValue: { [weak self] values in
            guard let self = self else { return }
            // Compare the next and previous identifiers in order to determine if a view was popped
            if let prev = values.0, let next = values.1, let prevIndex = self.stack.lastIndex(of: prev), let nextIndex = self.stack.lastIndex(of: next) {
                if prevIndex > nextIndex {
                    self.pop()
                }
            }
        })
    }
    
    func popTo(_ identifier: ItemIdentifier) {
        if let index = stack.lastIndex(of: identifier) {
            stack = Array(stack[0...index])
        }
    }
    
    func pop() {
        if stack.count > 1 {
            stack.removeLast()
        }
    }
    
    func popToRoot() {
        if let first = stack.first, stack.count > 1 {
            stack = [first]
        }
    }
    
    func push(_ identifier: ItemIdentifier) {
        if stack.contains(identifier) {
            fatalError("\(String(describing: identifier)) already exists in the navigation stack.")
        }
        
        stack.append(identifier)
    }
    
    func isActive(_ identifier: ItemIdentifier) -> Bool {
        return stack.contains(identifier)
    }
    
    fileprivate func navigationItemAppeared(_ identifier: ItemIdentifier) {
        navigationItemAppearedSubject.send(identifier)
    }
    
}
