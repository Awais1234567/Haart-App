//
//  BookData.swift
//  Haart App
//
//  Created by OBS on 15/08/2020.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation

// MARK: - Books
struct Books: Codable {
    let kind: String?
    let totalItems: Int?
    let items: [Item]?
}

// MARK: - Item
struct Item: Codable {
    let volumeInfo: VolumeInfo?
 
}







enum Kind: String, Codable {
    case booksVolume = "books#volume"
}

// MARK: - SaleInfo




// MARK: - SearchInfo
struct SearchInfo: Codable {
    let textSnippet: String
}

// MARK: - VolumeInfo
struct VolumeInfo: Codable {
    let title: String
    let authors: [String]?

    enum CodingKeys: String, CodingKey {
        case title, authors
    }
}




