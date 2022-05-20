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
        navigationStack = NavigationStack<Page>(rootItem: .page1)
        coordinator = TestCoordinator(navigationStack: navigationStack)
    }
    
    var body: some Scene {
        WindowGroup {
            Router(navigationStack: navigationStack, routeBuilder: TestRouteBuilder())
                .environmentObject(coordinator)
        }
    }
}
