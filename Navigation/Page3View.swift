//
//  Page3View.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import SwiftUI

struct Page3View: View {
    
    let subsection: Int
    
    @EnvironmentObject var coordinator: TestCoordinator
    
    var body: some View {
        VStack {
            Button("Back") {
                coordinator.back()
            }
            Button("To Page 3.\(subsection + 1)") {
                coordinator.toPage3(subsection: subsection + 1)
            }
            Button("To Error"){
                coordinator.toError()
            }
            Button("Back") {
                coordinator.back()
            }
            Button("To Page 2") {
                coordinator.toPage2()
            }
            Button("Complete") {
                coordinator.complete()
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
