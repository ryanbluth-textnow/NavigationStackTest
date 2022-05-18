//
//  Page2View.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import SwiftUI

struct Page2View: View {
    
    @EnvironmentObject var navigationStack: NavigationStack<Page>
    
    var body: some View {
        VStack {
            NavigationStackLink(destinationName: Page.page3(subsection: 1), destination: {
                Page3View(subsection: 1)
            }, label: {
                EmptyView()
            })
            Button("Pop") {
                navigationStack.pop()
            }
            Button("To Page 3.1"){
                // Example of controlling the navigation link from a button
                navigationStack.push(Page.page3(subsection: 1))
            }
        }
        .navigationTitle("Page 2")
    }
}

struct Page2View_Previews: PreviewProvider {
    static var previews: some View {
        Page2View()
    }
}
