//
//  Page1View.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import SwiftUI

struct Page1View: View {
    
    @EnvironmentObject var coordinator: TestCoordinator
    
    var body: some View {
        VStack {
            Button("To page 2") {
                coordinator.toPage2()
            }
            Button("To error") {
                coordinator.toError()
            }
        }
        .navigationTitle("Page 1")
    }
}

struct Page1View_Previews: PreviewProvider {
    static var previews: some View {
        Page1View()
    }
}
