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
    
    weak var delegate: EventFavoritedProtocol?
    var event: EventResults.Events? {
        didSet {
            updateViews()
        }
    }
    
    
    @objc private func handleFavoriteButtonTapped() {
        guard let event = event else { return }
        delegate?.didFavoriteEvent(event: event)
    }
    
    func updateViews() {
        guard let event = event else { return }
        eventTitleLabel.text = event.title
        locationLabel.text = event.city
        timeLabel.text = "\(event.datetimeUtc)"
    }

}


