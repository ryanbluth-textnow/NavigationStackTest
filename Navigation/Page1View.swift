//
//  Page1View.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import SwiftUI

struct Page1View: View {
    
    var body: some View {
        VStack {
            NavigationStackLink(destinationName: Page.page2, destination: {
                Page2View()
            }, label: {
                Text("To Page 2")
            })
        }
        .navigationTitle("Page 1")
    }
}

struct Page1View_Previews: PreviewProvider {
    static var previews: some View {
        Page1View()
    }
}
