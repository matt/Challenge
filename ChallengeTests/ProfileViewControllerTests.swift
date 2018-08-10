//
//  ChallengeTests.swift
//  ChallengeTests
//
//  Created by Matthew Mohrman on 8/3/18.
//  Copyright © 2018 Matthew Mohrman. All rights reserved.
//

import XCTest
@testable import Challenge

class ProfileViewControllerTests: XCTestCase {
    
    let profile = Profile(uid: 1, imageUrl: "http://example.com/images/25.jpg", name: "Female", age: 28, gender: .female, hobbies: "Swimming", documentId: "")
    var viewController: ProfileViewController!
    
    override func setUp() {
        super.setUp()
        viewController = ProfileViewController()
        viewController.profile = profile
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testConfigureDetails() {
        let profileDetails = viewController.configureDetails(forProfile: viewController.profile)
        let expectedResult: [[ProfileViewController.ProfileDataKey: String]] = [
            [.title: ProfileViewController.ProfileTitleValue.age.rawValue, .data: String(profile.age)],
            [.title: ProfileViewController.ProfileTitleValue.gender.rawValue, .data: profile.gender.rawValue],
            [.title: ProfileViewController.ProfileTitleValue.hobbies.rawValue, .data: profile.hobbies]
        ]
        
        XCTAssertEqual(profileDetails, expectedResult)
    }
}
