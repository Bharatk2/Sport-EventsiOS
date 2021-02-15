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

