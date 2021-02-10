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
    
    var event: EventResults.Events? {
        didSet {
            updateViews()
        }
    }


     
    func updateViews() {
        guard let event = event else { return }
        eventTitle.text = event.title
        eventLocation.text = event.city
        eventDate.text = "\(event.dateTimeLocal?.convertToMonthYearFormat())"
    }
    
 

}



