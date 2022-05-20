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
    
    private func navigationView() -> AnyView? {
        navigationStack.stack.reversed().reduce(nil, { res, ident in
            if ident == navigationStack.stack.first! {
                return AnyView(
                    VStack {
                        routeBuilder.routeView(ident).onAppear {
                            navigationStack.navigationItemAppeared(ident)
                        }
                        res
                    }
                )
            } else {
                return AnyView(NavigationLink(isActive: Binding(get: {
                    navigationStack.isActive(ident)
                }, set: { _,_ in
                    
                }), destination: {
                    VStack {
                        if res != nil {
                            res
                        }
                        routeBuilder.routeView(ident).onAppear {
                            navigationStack.navigationItemAppeared(ident)
                        }
                    }
                }, label: EmptyView.init))
            }
        })
    }
}

class NavigationStack<ItemIdentifier: Equatable>: ObservableObject {
   
    @Published fileprivate var stack: [ItemIdentifier] = []
    
    private let navigationItemAppearedSubject: PassthroughSubject<ItemIdentifier, Never>
    private var navigationItemAppearedSubscription: AnyCancellable?
    
    init() {
        self.stack = []
        self.navigationItemAppearedSubject = PassthroughSubject()
        
        self.navigationItemAppearedSubscription = navigationItemAppearedSubject.scan((nil, nil)) { prev, next in
            (prev.1, next)
        }.sink(receiveValue: { [weak self] values in
            guard let self = self else { return }
            // Determine if a view is being popped by the navigation bar back button
            if let prev = values.0, let next = values.1, let prevIndex = self.stack.lastIndex(of: prev), let nextIndex = self.stack.lastIndex(of: next) {
                if prevIndex > nextIndex {
                    self.pop()
                }
            }
        })
    }
    
    func popTo(_ identifier: ItemIdentifier) {
        if let index = stack.lastIndex(of: identifier) {
            if index > 0 {
                stack = Array(stack[0 ... index])
            }
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
