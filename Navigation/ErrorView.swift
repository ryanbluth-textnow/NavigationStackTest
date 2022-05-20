//
//  ErrorView.swift
//  Navigation
//
//  Created by Ryan Bluth on 2022-05-20.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .navigationTitle("Error")
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(message: "Error")
    }
}
