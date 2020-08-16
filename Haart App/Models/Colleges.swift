//
//  Colleges.swift
//  Haart App
//
//  Created by OBS on 15/08/2020.
//  Copyright © 2020 TalhaShah. All rights reserved.
//


import Foundation

// MARK: - Universities
struct Universities: Codable {
    let results: [Results]
}

// MARK: - Result
struct Results: Codable {
    let objectID, name: String
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case objectID = "objectId"
        case name, createdAt, updatedAt
    }
}

