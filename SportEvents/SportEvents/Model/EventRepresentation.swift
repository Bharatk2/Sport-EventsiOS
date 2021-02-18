//
//  EventRepresentation.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//


import Foundation
import CoreData
enum EventAction: Int, Codable {
    case favorited
    case removed
}

class EventRep: Codable {
    var events: [EventRepresentation]
    class EventRepresentation: Codable {
        let title: String
        let eventURL: String
        let datetimeLocal: String
        let type: String
        let id: Int64
        // stats
        let listingCount: Int64?
        let lowestPrice: Int64?
        let averagePrice: Int64?
        let highestPrice: Int64?
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
            case datetimeLocal
            case stats
            case performers
            case venue
            case type
            case id
            
            enum StatsKeys: String, CodingKey {
                case listingCount
                case averagePrice
                case lowestPrice
                case highestPrice
                
            }
            enum PerformersKeys: String, CodingKey {
                case name = "name"
                case image
                case url = "url"
            }
            enum VenueKeys: String, CodingKey {
                case city
                case terminalName = "name"
                case location
                
               
            }
           
        }
       
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: EventKeys.self)
            title = try container.decode(String.self, forKey: .title)
            eventURL = try container.decode(String.self, forKey: .eventURL)
            datetimeLocal = try container.decode(String.self, forKey: .datetimeLocal)
            type = try container.decode(String.self, forKey: .type)
            id = try container.decode(Int64.self, forKey: .id)
            let statsDictionary = try container.nestedContainer(keyedBy: EventKeys.StatsKeys.self, forKey: .stats)
            listingCount = try statsDictionary.decodeIfPresent(Int64.self, forKey: .listingCount)
            averagePrice = try statsDictionary.decodeIfPresent(Int64.self, forKey: .averagePrice)
            lowestPrice = try statsDictionary.decodeIfPresent(Int64.self, forKey: .lowestPrice)
            highestPrice = try statsDictionary.decodeIfPresent(Int64.self, forKey: .highestPrice)
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

class FavoritedEvents: NSManagedObject {
    @NSManaged var events: Event
}
