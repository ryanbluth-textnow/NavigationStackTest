//
//  NavigationStack.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import Combine
import SwiftUI

struct NavigationStackView<ItemIdentifier: Equatable, DestinationView: View>: View {
    let navigationStack: NavigationStack<ItemIdentifier>
    let initialDestination: () -> DestinationView

    var body: some View {
        NavigationView {
            initialDestination()
        }
        .navigationViewStyle(.stack)
        .environmentObject(navigationStack)
    }
}

class NavigationStack<ItemIdentifier: Equatable>: ObservableObject {
    fileprivate enum Action {
        case push(ItemIdentifier)
        case pop(ItemIdentifier)
    }

    fileprivate var stack: [ItemIdentifier] = []
    fileprivate let actionSubject: PassthroughSubject<Action, Never>
    fileprivate let navigationItemAppearedSubject: PassthroughSubject<ItemIdentifier, Never>

    private var navigationItemAppearedSubscription: AnyCancellable?

    init(initialIdentifier: ItemIdentifier) {
        self.stack = [initialIdentifier]
        self.actionSubject = PassthroughSubject()
        self.navigationItemAppearedSubject = PassthroughSubject()

        self.navigationItemAppearedSubscription = navigationItemAppearedSubject.scan((nil, initialIdentifier)) { prev, next in
            (prev.1, next)
        }.sink(receiveValue: { [weak self] values in
            guard let self = self else { return }
            // Determine if a view is being popped by the navigation bar back button
            if let prev = values.0, let prevIndex = self.stack.lastIndex(of: prev), let nextIndex = self.stack.lastIndex(of: values.1) {
                if prevIndex > nextIndex {
                    self.pop()
                }
            }
        })
    }

    func popTo(_ identifier: ItemIdentifier) {
        if let index = stack.lastIndex(of: identifier) {
            if index > 0 {
                if let toIndex = stack.lastIndex(of: identifier) {
                    actionSubject.send(.pop(stack[toIndex + 1]))
                }
                stack = Array(stack[0 ... index])
            }
        }
    }

    func pop() {
        if let lastItem = stack.last, stack.count > 1 {
            actionSubject.send(.pop(lastItem))
            stack.removeLast()
        }
    }

    func popToRoot() {
        if let first = stack.first, stack.count > 1 {
            actionSubject.send(.pop(stack[1]))
            stack = [first]
        }
    }

    func push(_ identifier: ItemIdentifier) {
        if stack.contains(identifier) {
            fatalError("\(String(describing: identifier)) already exists in the navigation stack.")
        }

        stack.append(identifier)
        actionSubject.send(.push(identifier))
    }
}

struct NavigationStackLink<DestinationView: View, LabelView: View, ItemIdentifier: Equatable>: View {
    @EnvironmentObject var navigationStack: NavigationStack<ItemIdentifier>

    let destination: () -> DestinationView
    let label: () -> LabelView
    let destinationIdentifier: ItemIdentifier

    @State private var isActive: Bool = false

    public init(destinationIdentifier: ItemIdentifier, @ViewBuilder destination: @escaping () -> DestinationView, @ViewBuilder label: @escaping () -> LabelView) {
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

            NavigationLink(isActive: $isActive, destination: {
                destination().onAppear {
                    navigationStack.navigationItemAppearedSubject.send(destinationIdentifier)
                }
            }) {
                EmptyView()
            }
            .isDetailLink(false)
            .onReceive(navigationStack.actionSubject) { action in
                switch action {
                case let .pop(identifier):
                    if identifier == destinationIdentifier {
                        isActive = false
                    }
                case let .push(identifier):
                    if identifier == destinationIdentifier {
                        isActive = true
                    }
                }
            }
        }
    }
}
