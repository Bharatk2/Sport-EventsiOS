//
//  Event.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import Foundation

struct EventResults: Codable, Equatable {
    let results: [Event]
}
struct Event: Codable, Equatable {
    let title: String
    let type: String
    let dateTimeLocal: String
    let url: String
    let performers: [Performers]
    let stats: Stats
    let venue: Venue
    let id: Int
}

struct Performers: Codable, Equatable {
    let name: String
    let url: String
}

struct Stats: Codable, Equatable {
    let listingCount: Int?
    let lowestPrice: Int?
    let highestPrice: Int?
}

struct Venue: Codable, Equatable {
    let city: String
    let name: String
}
