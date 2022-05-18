//
//  routerApp.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import SwiftUI

@main
struct NavigationApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStackView(initialDestinationIdentifier: Page.page1) {
                Page1View()
            }
        }
    }
}
