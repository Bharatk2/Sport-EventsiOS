//
//  Event+Convenience.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//


import Foundation
import CoreData

extension Event {
    @discardableResult convenience init(id: Int64,
                                        type: String,
                                        datetimeLocal: String,
                                        eventURL: String,
                                        title: String,
                                        listingCount: Int64? = nil,
                                        lowestPrice: Int64? = nil,
                                        averagePrice: Int64? = nil,
                                        highestPrice: Int64? = nil,
                                        name: String,
                                        image: String,
                                        url: String,
                                        city: String,
                                        terminalName: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.type = type
        self.datetimeLocal = datetimeLocal
        self.eventURL = eventURL
        self.title = title
        self.listingCount = listingCount ?? 0
        self.lowestPrice = lowestPrice ?? 0
        self.averagePrice = averagePrice ?? 0
        self.highestPrice = highestPrice ?? 0
        self.name = name
        self.image = image
        self.url = url
        self.city = city
        self.terminalName = terminalName
    }

    @discardableResult convenience init?(representation: EventRep.EventRepresentation,
                                            context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

       
        
        self.init(id: representation.id,
                  type: representation.type,
                  datetimeLocal: representation.datetimeLocal,
                  eventURL: representation.eventURL,
                  title: representation.title,
                  listingCount: representation.listingCount,
                  lowestPrice: representation.lowestPrice,
                  averagePrice: representation.averagePrice,
                  highestPrice: representation.highestPrice,
                  name: representation.name,
                  image: representation.image,
                  url: representation.url,
                  city: representation.city,
                  terminalName: representation.terminalName)
    }
}
