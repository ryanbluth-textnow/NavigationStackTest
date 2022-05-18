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
                Text("To Page 3.1")
            })
            Button("Pop") {
                navigationStack.pop()
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
