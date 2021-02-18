//
//  ContentCell.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import UIKit

class ContentCell: UICollectionViewCell {
    
    // MARK: - Properties
    weak var delegate: EventsViewController?
    weak var favoriteDelegate: FavoriteEventDelegate?
    var event: Event? {
        didSet {
            updateViewsCore()
        }
    }
    var favoriteEvent: Event2? {
        didSet {
            updateViewsCore()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    var date: String {
        let formatter = DateFormatter()
        guard let event = event?.datetimeLocal else { return "" }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = formatter.date(from: event)
        let formattedDisplayDate = DateFormatter()
        formattedDisplayDate.dateFormat = "EEEE, d MMM yyyy hh:mm a"
        guard let dater = date else { return "" }
        return formattedDisplayDate.string(from: dater)
        
    }
    
    func updateViewsCore() {
        guard let event = event,
              let city = event.city else { return }
        eventTitle.text = event.title
        eventLocation.text = "📍\(city)"
        eventDate.text = date
    }
    
}



