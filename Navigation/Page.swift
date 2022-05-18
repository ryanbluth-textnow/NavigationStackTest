//
//  Page.swift
//  router
//
//  Created by Ryan Bluth on 2022-05-17.
//

import Foundation

enum Page: Equatable {
    case page1
    case page2
    case page3(subsection: Int)
}
