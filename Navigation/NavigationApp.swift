//
//  routerApp.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import SwiftUI



@main
struct NavigationApp: App {
    
    let navigationStack: NavigationStack<Page>
    let coordinator: TestCoordinator
    
    init() {
        navigationStack = NavigationStack<Page>()
        coordinator = TestCoordinator(navigationStack: navigationStack)
        navigationStack.push(.page1)
    }
    
    var body: some Scene {
        WindowGroup {
            Router(navigationStack: navigationStack, routeBuilder: TestRouteBuilder())
                .environmentObject(coordinator)
        }
    }
}
