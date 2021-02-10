//
//  EventsTableViewCell.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/10/21.
//

import UIKit

class EventsTableViewCell: UITableViewCell {

    @IBOutlet weak var performerImage: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var cellView: UIView!
    var event: EventResults.Events? {
        didSet {
            updateViews()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        guard let event = event else { return }
        eventTitleLabel.text = event.title
        locationLabel.text = event.city
        timeLabel.text = "\(event.dateTimeLocal)"
    }

}


