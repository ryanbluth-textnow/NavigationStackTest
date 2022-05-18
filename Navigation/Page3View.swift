//
//  Page3View.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import SwiftUI

struct Page3View: View {
    
    let subsection: Int
    
    @EnvironmentObject var navigationStack: NavigationStack<Page>
    
    var body: some View {
        VStack {
            NavigationStackLink(destinationName: Page.page3(subsection: subsection + 1), destination: {
                Page3View(subsection: subsection + 1)
            }, label: {
                Text("To Page 3.\(subsection + 1)")
            })
            Button("Pop") {
                navigationStack.pop()
            }
            Button("Pop to Page 2") {
                navigationStack.popTo(Page.page2)
            }
            Button("Pop to root") {
                navigationStack.popToRoot()
            }
        }
        .navigationTitle("Page 3.\(subsection)")
    }
}

struct Page3View_Previews: PreviewProvider {
    static var previews: some View {
        Page3View(subsection: 1)
    }
}
