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

    @IBOutlet weak var performerImage: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var cellView: UIView!
    weak var favoriteDelegate: FavoriteEventDelegate?
    weak var delegate: EventFavoritedProtocol?
    var event: EventResults.Events? {
        didSet {
            updateViews()
        }
    }
    var date: String {
        let formatter = DateFormatter()
        guard let event = event?.datetime_utc else { return "" }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = formatter.string(from: event)
        let formattedDisplayDate = DateFormatter()
        formattedDisplayDate.dateFormat = "EEEE, d MMM yyyy hh:mm a"
        return date
    }
    
    @objc private func handleFavoriteButtonTapped() {
        guard let event = event else { return }
        delegate?.didFavoriteEvent(event: event)
    }
    
    func updateViews() {
        guard let event = event else { return }
        eventTitleLabel.text = event.title
        locationLabel.text = event.city
        timeLabel.text = date
    }

}



