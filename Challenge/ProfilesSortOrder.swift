//
//  ProfilesSortOrder.swift
//  Challenge
//
//  Created by Matthew Mohrman on 8/6/18.
//  Copyright © 2018 Matthew Mohrman. All rights reserved.
//

import Foundation

enum ProfilesSortOrder: Int {
    case uidAscending = 0, ageAscending, ageDescending, nameAscending, nameDescending
    
    func textDescription() -> String {
        switch self {
        case .uidAscending:
            return "UID Ascending"
        case .ageAscending:
            return "Age Ascending"
        case .ageDescending:
            return "Age Descending"
        case .nameAscending:
            return "Name Ascending"
        case .nameDescending:
            return "Name Descending"
        }
    }
    
    func sortLogic() -> (field: String, isDescending: Bool) {
        switch self {
        case .uidAscending:
            return ("uid", false)
        case .ageAscending:
            return ("age", false)
        case .ageDescending:
            return ("age", true)
        case .nameAscending:
            return ("name", false)
        case .nameDescending:
            return ("name", true)
        }
    }
}
