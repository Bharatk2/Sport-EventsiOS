//
//  EventsTableViewCell.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/10/21.
//

import UIKit
protocol EventFavoritedProtocol: class {
    func didFavoriteEvent(event: EventResults.Events)
}
class EventsTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    weak var favoriteDelegate: FavoriteEventDelegate?
    weak var delegate: EventFavoritedProtocol?
    
    // MARK: - Outlets
    @IBOutlet weak var performerImage: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var favoriteImage: UIImageView!
    
    // MARK: - Computed Properties
    
    var corEvent: Event? {
        didSet {
            updateViewsCore()
        }
    }
    
    
    var date: String {
        let formatter = DateFormatter()
        guard let event = corEvent?.datetimeLocal else { return "" }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = formatter.date(from: event)
        let formattedDisplayDate = DateFormatter()
        formattedDisplayDate.dateFormat = "EEEE, d MMM yyyy hh:mm a"
        guard let dater = date else { return "" }
        return formattedDisplayDate.string(from: dater)
        
    }
    
    // MARK: - Methods
//    @objc private func handleFavoriteButtonTapped() {
//        guard let event = corEvent else { return }
//        delegate?.didFavoriteEvent(event: event)
//    }
//    

    
    func updateViewsCore() {
        guard let event = corEvent,
              let city = event.city else { return }
        eventTitleLabel.text = event.title
        locationLabel.text = "📍\(city)"
        timeLabel.text = date
    }

}


