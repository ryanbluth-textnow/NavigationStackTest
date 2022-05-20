//
//  Page2View.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import SwiftUI

struct Page2View: View {
    
    @EnvironmentObject var coordinator: TestCoordinator
    
    var body: some View {
        VStack {
            Button("Back") {
                coordinator.back()
            }
            Button("To Page 3.1"){
                coordinator.toPage3(subsection: 1)
            }
            Button("To Error"){
                coordinator.toError()
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
