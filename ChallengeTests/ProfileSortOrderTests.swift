//
//  ProfileSortOrderTests.swift
//  ChallengeTests
//
//  Created by Matthew Mohrman on 8/9/18.
//  Copyright © 2018 Matthew Mohrman. All rights reserved.
//

import XCTest
@testable import Challenge

class ProfileSortOrderTests: XCTestCase {
    
    func testTextDescription() {
        var profilesSortOrder = ProfilesSortOrder.uidAscending
        XCTAssertEqual(profilesSortOrder.textDescription(), "UID Ascending")
        
        profilesSortOrder = .ageAscending
        XCTAssertEqual(profilesSortOrder.textDescription(), "Age Ascending")
        
        profilesSortOrder = .ageDescending
        XCTAssertEqual(profilesSortOrder.textDescription(), "Age Descending")
        
        profilesSortOrder = .nameAscending
        XCTAssertEqual(profilesSortOrder.textDescription(), "Name Ascending")
        
        profilesSortOrder = .nameDescending
        XCTAssertEqual(profilesSortOrder.textDescription(), "Name Descending")
    }
    
    func testSortLogic() {
        var profilesSortOrder = ProfilesSortOrder.uidAscending
        var sortLogic = profilesSortOrder.sortLogic()
        XCTAssertEqual(sortLogic.field, "uid")
        XCTAssertFalse(sortLogic.isDescending)
        
        profilesSortOrder = .ageAscending
        sortLogic = profilesSortOrder.sortLogic()
        XCTAssertEqual(sortLogic.field, "age")
        XCTAssertFalse(sortLogic.isDescending)
        
        profilesSortOrder = .ageDescending
        sortLogic = profilesSortOrder.sortLogic()
        XCTAssertEqual(sortLogic.field, "age")
        XCTAssertTrue(sortLogic.isDescending)
        
        profilesSortOrder = .nameAscending
        sortLogic = profilesSortOrder.sortLogic()
        XCTAssertEqual(sortLogic.field, "name")
        XCTAssertFalse(sortLogic.isDescending)
        
        profilesSortOrder = .nameDescending
        sortLogic = profilesSortOrder.sortLogic()
        XCTAssertEqual(sortLogic.field, "name")
        XCTAssertTrue(sortLogic.isDescending)
    }
    
}
