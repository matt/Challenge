//
//  Profile.swift
//  Challenge
//
//  Created by Matthew Mohrman on 8/3/18.
//  Copyright © 2018 Matthew Mohrman. All rights reserved.
//

import Foundation

struct Profile {
    var uid: Int
    var imageUrl: String
    var name: String
    var age: Int
    var gender: Gender
    var hobbies: String
    var documentId: String
    
    enum CodingKeys: String, CodingKey {
        case uid
        case imageUrl
        case name
        case age
        case gender
        case hobbies
        case documentId
    }
}

extension Profile: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)
        try container.encode(gender.rawValue, forKey: .gender)
        try container.encode(hobbies, forKey: .hobbies)
        // exclude documentId
    }
}

extension Profile: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uid = try values.decode(Int.self, forKey: .uid)
        imageUrl = try values.decode(String.self, forKey: .imageUrl)
        name = try values.decode(String.self, forKey: .name)
        age = try values.decode(Int.self, forKey: .age)
        let genderString = try values.decode(String.self, forKey: .gender)
        gender = Gender(rawValue: genderString)!
        hobbies = try values.decode(String.self, forKey: .hobbies)
        documentId = try values.decode(String.self, forKey: .documentId)
    }
}
