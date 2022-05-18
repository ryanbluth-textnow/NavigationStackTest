//
//  routerApp.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import SwiftUI

@main
struct NavigationApp: App {
    
    let navigationStack = NavigationStack(initialIdentifier: Page.page1)
    
    var body: some Scene {
        WindowGroup {
            NavigationStackView(navigationStack: navigationStack) {
                Page1View()
            }
        }
    }
}
