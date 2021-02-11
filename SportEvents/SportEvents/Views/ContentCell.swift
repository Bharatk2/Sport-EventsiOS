//
//  ContentCell.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import UIKit

class ContentCell: UICollectionViewCell {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var cellView: UIView!
    weak var delegate: EventFavoritedProtocol?
    var event: EventResults.Events? 
   
    @objc private func handleFavoriteButtonTapped() {
        guard let event = event else { return }
        delegate?.didFavoriteEvent(event: event)
    }
    func updateViews() {
        guard let event = event else { return }
        eventTitle.text = event.title
        eventLocation.text = event.city
        eventDate.text = "\(event.datetimeUtc)"
    }
    
 

}



