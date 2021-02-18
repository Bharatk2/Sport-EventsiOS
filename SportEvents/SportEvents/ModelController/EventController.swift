//
//  EventController.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import Foundation
import CoreData
import UIKit

enum NetworkError: Error {
    case  noData(String), badData(String)
    case failedFetch(String), badURL(String)
    case badError(String)
}

class EventController {
    
    // MARK: - Properties
    var events: [EventRep.EventRepresentation] = []
    var cache = Cache<NSString, AnyObject>()
    var newCache = Cache<Int64, Event>()
    var dataLoader: DataLoader?
    static var shared = EventController()
    let bgContext = CoreDataStack.shared.container.newBackgroundContext()
    let operationQueue = OperationQueue()
    // MARK: - Computed Properties
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    //MARK: - Initializer
    init(dataLoader: DataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
        
    }
    //MARK: - Get Events Instructions
    /*
     All we need to do is call this function in the view controller viewDidLoad and assign the completion event to the view controller event
     and reload.
     */
    
    func syncEvents(completion: @escaping (Error?) -> Void) {
        var representations: [EventRep.EventRepresentation] = []
        do {
            try getNewEvents { events, error in
                if let error = error {
                    NSLog("Error fetching all events to sync : \(error)")
                    completion(error)
                    return
                }

                guard let fetchedEvents = events?.events else {
                    completion(NetworkError.badData("Posts array couldn't be unwrapped"))
                    return
                }
                representations = fetchedEvents

                // Use this context to initialize new events into core data.
                self.bgContext.perform {
                    for event in representations {
                        // First if it's in the cache
                        
                        if self.newCache.value(for: event.id) != nil {
                            let cachedEvent = self.newCache.value(for: event.id)!
                          
                            self.update(event: cachedEvent, with: event)
                            if cachedEvent.id == event.id {
                                CoreDataStack.shared.mainContext.delete(cachedEvent)
                            }
                        } else {
                            do {
                                try self.saveEvent(by: event.id, from: event)
                               
                            } catch {
                                completion(error)
                                return
                            }
                        }
                       
                    }
                }// context.perform
                completion(nil)
            }// Fetch closure

        } catch {
            completion(error)
        }
    }
    
    func getNewEvents(completion: @escaping (EventRep?, Error?) -> Void) throws {
        
        var urlComponents = URLComponents(url: Endpoint.events, resolvingAgainstBaseURL: false)
        let queryItems = [
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "client_id", value: ClientKey.clientKey)
        ]
        urlComponents?.queryItems = queryItems
        print(urlComponents?.url ?? "")
        guard let requestURL = urlComponents?.url else {
            completion(nil, NetworkError.badURL("The request url was invalid"))
            return
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        dataLoader?.loadData(from: request, completion: { data, _, error in
            if let error = error {
                return completion(nil, error)
            }
            
            guard let data = data else {
                completion(nil, NetworkError.badData("No data was returned"))
                return
            }
           
            
            let event = EventRep.self
          
            do {
                let events = try self.decoder.decode(event, from: data)
                self.events = events.events
                print(events)
                return completion(events, nil)
                
            } catch {
                
                return completion(nil, NetworkError.badData("There was an error decoding data"))
            }
            
            
        })
        
    }
    
    
    func saveEvent(by userID: Int64, from representation: EventRep.EventRepresentation) throws {
        if let newEvent = Event(representation: representation, context: bgContext) {
       
            let handleSaving = BlockOperation {
                do {
                    // After going through the entire array, try to save context.
                    // Make sure to do this in a separate do try catch so we know where things fail
                    try CoreDataStack.shared.save(context: self.bgContext)
                } catch {
                    NSLog("Error saving context.\(error)")
                }
            }
            operationQueue.addOperations([handleSaving], waitUntilFinished: false)
            newCache.cache(value: newEvent, for: userID)
        }
    }
    
    func saveEvents(by userID: Int64, from representation: Event) throws {
        let context = CoreDataStack.shared.container.newBackgroundContext()
         let newEvent = Event(entity: representation.entity, insertInto: context)
       
            let handleSaving = BlockOperation {
                do {
                    // After going through the entire array, try to save context.
                    // Make sure to do this in a separate do try catch so we know where things fail
                    try CoreDataStack.shared.save(context: self.bgContext)
                } catch {
                    NSLog("Error saving context.\(error)")
                }
            }
            operationQueue.addOperations([handleSaving], waitUntilFinished: false)
            newCache.cache(value: newEvent, for: userID)
        
    }

    
    private func update(event: Event, with rep: EventRep.EventRepresentation) {
    
        event.id = rep.id
        event.type = rep.type
        event.datetimeLocal = rep.datetimeLocal
        event.eventURL = rep.eventURL
        event.title = rep.title
        event.listingCount = rep.listingCount ?? 0
        event.lowestPrice = rep.lowestPrice ?? 0
        event.averagePrice = rep.averagePrice ?? 0
        event.highestPrice = rep.highestPrice ?? 0
        event.name = rep.name
        event.image = rep.image
        event.url = rep.url
        event.city = rep.city
        event.terminalName = rep.terminalName
    }
        
        //MARK: - Get Image Instructions
    /*
     All we need to do is call this function in the view controller cell,
     assign the imageURL to the eventImageURL
     and assign  completion image to the outlet image
     */
    func getImages(imageURL: String, completion: @escaping (UIImage?, Error?) -> Void) {
        
        let imageString = NSString(string: imageURL)
        if let imageFromCache = cache.value(for: imageString) as? UIImage {
            completion(imageFromCache, nil)
            return
        }
        guard let imageURL = URL(string: imageURL) else {
            return completion(nil, NetworkError.badURL("The url for image was incorrect"))
        }
        
        dataLoader?.loadData(from: imageURL, completion: { data, _, error in
            if let error = error {
                NSLog("error in fetching image :\(error)")
                return
            }
            
            guard let data = data,
                  let image = UIImage(data: data) else {
                completion(nil, NetworkError.badData("there was an error in image data"))
                return
            }
            
            self.cache.cache(value: image, for: imageString)
            completion(image, nil)
            
        })
        
    }
    
}
