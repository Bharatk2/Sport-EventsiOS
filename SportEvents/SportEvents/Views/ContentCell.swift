//
//  ContentCell.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import UIKit

class ContentCell: UICollectionViewCell {
    
    // MARK: - Properties
    weak var delegate: EventFavoritedProtocol?
    weak var favoriteDelegate: FavoriteEventDelegate?
    var event: EventResults.Events?
    
    // MARK: - Outlets
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var cellView: UIView!
   

}



