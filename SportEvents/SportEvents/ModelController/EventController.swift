//
//  EventController.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import Foundation
import UIKit
enum NetworkError: Error {
    case  noData(String), badData(String)
    case failedFetch(String), badURL(String)
    case badError(String)
}

class EventController {
    
    // MARK: - Properties
    var cache = Cache<NSString, AnyObject>()
    var dataLoader: DataLoader?
    static var shared = EventController()
    
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
    func getEvents(completion: @escaping (EventResults?, Error?) -> Void) {
        
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
            
            let event = EventResults.self
            
            do {
                let events = try self.decoder.decode(event, from: data)
                print(events)
                return completion(events, nil)
            } catch {
                
                return completion(nil, NetworkError.badData("There was an error decoding data"))
            }
        })
        
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
