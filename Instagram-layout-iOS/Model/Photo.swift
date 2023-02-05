//
//  Model.swift
//  Instagram-layout-iOS
//
//  Created by Mahi Al Jawad on 5/2/23.
//

import Foundation

enum Section: CaseIterable {
    case horizontalGrid
    case verticalGrid
    
    var sectionTitle: String {
        switch self {
        case .horizontalGrid: return "Horizontal Section"
        case .verticalGrid:   return "Vertical Section"
        }
    }
}

struct Photo: Hashable {
    let ID: String
    let urlString: String
}
