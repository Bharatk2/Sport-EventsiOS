//
//  Endpoint.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import Foundation

enum Endpoint {}

extension Endpoint {
    static let events = URL(string: "https://api.seatgeek.com/2/events")!
}

enum ClientKey {}

extension ClientKey {
    static var clientKey = "MjE1Mzg2MzB8MTYxMjkyNjA4Mi42NDI0MzYz"
}
