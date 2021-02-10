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
    
    var cache = Cache<NSString, UIImage>()
    var dataLoader: DataLoader?
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    init(dataLoader: DataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
        
    }
    
    func getEvents(completion: @escaping ([Event]?, Error?) -> Void) {
        
        let queryPerPage = URLQueryItem(name: "per_page", value: "25")
        let queryClientID = URLQueryItem(name: "client_id", value: ClientKey.clientKey)
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.seatgeek.com"
        urlComponents.path = "/2/events"
        urlComponents.queryItems = [queryPerPage, queryClientID]
        
        guard let requestURL = urlComponents.url else {
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
            
            let event = [Event].self
            
            do {
                let events = try self.decoder.decode(event, from: data)
                print(events)
                return completion(events, nil)
            } catch {
                return completion(nil, NetworkError.badData("There was an error decoding data"))
            }
        })
        
    }
    
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
