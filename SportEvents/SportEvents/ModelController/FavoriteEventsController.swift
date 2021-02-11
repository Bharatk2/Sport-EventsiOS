//
//  FavoriteEventsController.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/10/21.
//

import Foundation

protocol FavoriteEventDelegate: class {
    func update(event e: EventResults.Events, eventAction: EventAction)
}

class FavoriteEventsController: FavoriteEventDelegate {
    
    // MARK: - Properties
    var events = [EventResults.Events]()
    static var shared = FavoriteEventsController()
    
    //MARK: - Initializer
    init() {
        saveToPersistentStore()
    }
    
    func findEventIndex(_ t: EventResults.Events) -> Int? {
        if let index = events.firstIndex(where: { $0 == t }) {
            return index
        } else {
            return nil
        }
    }
    // MARK: - Methods
    func update(event e: EventResults.Events, eventAction: EventAction) {
        loadFromPersistentStoreEvents { events, _ in
            var favoriteEvents = events
            switch eventAction {
            case .favorited:
                favoriteEvents.append(e)
                print(favoriteEvents)
                self.saveToPersistentStore()
            case .removed:
                favoriteEvents.removeAll()
                
            }
            self.saveToPersistentStore()
        }
        
        saveToPersistentStore()
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
            let eventData = try encoder.encode(events)
            
            guard let eventURL = eventURL else { return }
            
            try eventData.write(to: eventURL)
            
        } catch {
            print("Unable to save event to plist: \(error)")
        }
    }
    
    func loadFromPersistentStoreEvents(completion: @escaping ([EventResults.Events], Error?) -> Void) {
        
        do {
            guard let eventURL = eventURL else { return }
            
            let eventData = try Data(contentsOf: eventURL)
            let decoder = PropertyListDecoder()
            let decodedEvent = try decoder.decode([EventResults.Events].self, from: eventData)
            print(decodedEvent)
            self.events = decodedEvent
            completion(decodedEvent, nil)
            
        } catch {
            print("Unable to open event plist: \(error)")
        }
    }
    
}
