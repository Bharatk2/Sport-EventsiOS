//
//  FavoriteEventsController.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/10/21.
//

import Foundation
import UIKit
protocol FavoriteEventDelegate: class {
    func update(event e: Event, eventAction: EventAction)
}
class FavoriteEventsController {
    
    // MARK: - Properties
    var newFavoriteEvents = [EventResults.Events]()
    
    
    //MARK: - Initializer
    init() {
        loadFromPersistentStore()
    }
    
    func findEventIndex(_ t: EventResults.Events) -> Int? {
        if let index = newFavoriteEvents.firstIndex(where: { $0 == t }) {
            return index
        } else {
            return nil
        }
    }
    // MARK: - Methods
    func update(event e: EventResults.Events, eventAction: EventAction) {
       
            switch eventAction {
            case .favorited:
                newFavoriteEvents.append(e)
               
                print(newFavoriteEvents)
            case .removed:
                newFavoriteEvents.removeAll(where: {$0.id == e.id})
                
            }
            self.saveToPersistentStore()
        
    }
    
    // MARK: Persistent Store
    
    var eventURL: URL? {
        let fileManager = FileManager.default
        
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let eventURL = documentsDir?.appendingPathComponent("event.plist")
        
        return eventURL
    }
    
    func saveToPersistentStore() {
        // Convert our event Property List
        
        let encoder = PropertyListEncoder()
        
        do {
            let eventData = try encoder.encode(newFavoriteEvents)
            
            guard let eventURL = eventURL else { return }
            
            try eventData.write(to: eventURL)
            
        } catch {
            print("Unable to save event to plist: \(error)")
        }
    }
    
    func loadFromPersistentStore() {

        do {
            guard let eventURL = eventURL else { return }

            let eventData = try Data(contentsOf: eventURL)
            let decoder = PropertyListDecoder()
            let decodedCart = try decoder.decode([EventResults.Events].self, from: eventData)
            

            self.newFavoriteEvents = decodedCart
        } catch {
            print("Unable to open shopping cart plist: \(error)")
        }
    }
    
}
