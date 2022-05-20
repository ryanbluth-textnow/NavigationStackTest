//
//  Test.swift
//  Navigation
//
//  Created by Ryan Bluth on 2022-05-20.
//

import SwiftUI

class TestCoordinator: ObservableObject {
    
    let navigationStack: NavigationStack<Page>
    
    init(navigationStack: NavigationStack<Page>){
        self.navigationStack = navigationStack
    }
    
    func back() {
        navigationStack.pop()
    }
    
    func toPage2() {
        if navigationStack.isActive(.page2) {
            navigationStack.popTo(.page2)
        } else {
            navigationStack.push(.page2)
        }
    }
    
    func toPage3(subsection: Int) {
        if navigationStack.isActive(.page3(subsection: subsection)) {
            navigationStack.popTo(.page3(subsection: subsection))
        } else {
            navigationStack.push(.page3(subsection: subsection))
        }
    }
    
    func toError() {
        navigationStack.popToRoot()
        navigationStack.push(.error(message: "Uh oh. Error!"))
    }
    
    func complete(){
        navigationStack.popToRoot()
    }
}

struct TestRouteBuilder: RouteBuilder {
    
    @ViewBuilder func routeView(_ identifier: Page) -> some View {
        switch identifier {
        case .page1:
            Page1View()
        case .page2:
            Page2View()
        case .page3(let sub):
            Page3View(subsection: sub)
        case .error(let message):
            ErrorView(message: message)
        }
    }
}
