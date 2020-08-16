//
//  TvShows.swift
//  Haart App
//
//  Created by OBS on 15/08/2020.
//  Copyright © 2020 TalhaShah. All rights reserved.
//


import Foundation

// MARK: - TVShows
struct TVShows: Codable {
    let total: String
    let page, pages: Int
    let tvShows: [TvShow]

    enum CodingKeys: String, CodingKey {
        case total, page, pages
        case tvShows = "tv_shows"
    }
}

// MARK: - TvShow
struct TvShow: Codable {
    let id: Int
    let name, permalink: String


    enum CodingKeys: String, CodingKey {
        case id, name, permalink
    
    }
}
