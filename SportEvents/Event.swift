//
//  Event.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import Foundation
enum EventAction: Int, Codable {
    case favorited
    case removed
}

struct EventResults: Codable, Equatable, Hashable {
    var events: [Events]

    struct Events: Codable, Equatable, Hashable {
        let title: String
        let eventURL: String
        let datetime_utc: Date?
        let type: String
        let id: Int
        // stats
        let listingCount: Int?
        let lowestPrice: Int?
        let averagePrice: Int?
        let highestPrice: Int?
        // performers
        let name: String
        let image: String
        let url: String
        // Venue
        let city: String
        let terminalName: String
        
        enum EventKeys: String, CodingKey {
         
            case title = "title"
            case eventURL = "url"
            case datetime_utc = "datetime_utc"
            case stats
            case performers
            case venue
            enum StatsKeys: String, CodingKey {
                case listingCount = "listing_count"
                case averagePrice = "average_price"
                case lowestPrice = "lowest_price"
                case highestPrice = "highest_price"
                
            }
            enum PerformersKeys: String, CodingKey {
                case name = "name"
                case image
                case url = "url"
            }
            enum VenueKeys: String, CodingKey {
                case city
                case terminalName = "name"
            }
            case type
            case id
        }
       
         init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: EventKeys.self)
            title = try container.decode(String.self, forKey: .title)
            eventURL = try container.decode(String.self, forKey: .eventURL)
            datetime_utc = try container.decodeIfPresent(Date.self, forKey: .datetime_utc)
            type = try container.decode(String.self, forKey: .type)
            id = try container.decode(Int.self, forKey: .id)
            let statsDictionary = try container.nestedContainer(keyedBy: EventKeys.StatsKeys.self, forKey: .stats)
            listingCount = try statsDictionary.decodeIfPresent(Int.self, forKey: .listingCount)
            averagePrice = try statsDictionary.decodeIfPresent(Int.self, forKey: .averagePrice)
            lowestPrice = try statsDictionary.decodeIfPresent(Int.self, forKey: .lowestPrice)
            highestPrice = try statsDictionary.decodeIfPresent(Int.self, forKey: .highestPrice)
            var performerContainer = try container.nestedUnkeyedContainer(forKey: .performers)
            let containerPerformer = try performerContainer.nestedContainer(keyedBy: EventKeys.PerformersKeys.self)
            name = try containerPerformer.decode(String.self, forKey: .name)
            url = try containerPerformer.decode(String.self, forKey: .url)
            image = try containerPerformer.decode(String.self, forKey: .image)
            let venueDictionary = try container.nestedContainer(keyedBy: EventKeys.VenueKeys.self, forKey: .venue)
            city = try venueDictionary.decode(String.self, forKey: .city)
            terminalName = try venueDictionary.decode(String.self, forKey: .terminalName)
           
        }
    }
}
