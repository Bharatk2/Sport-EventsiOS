//
//  EventsDetailViewController.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//


import UIKit

class EventsDetailViewController: UIViewController {
    
    // MARK: - Properties
    var event: Event?
  
    
    var isFavorited = false
    
    weak var likedEventDelegate: FavoriteEventDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var performerImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var performerName: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var listingCountLabel: UILabel!
    @IBOutlet weak var averagePriceLabel: UILabel!
    @IBOutlet weak var lowestPriceLabel: UILabel!
    @IBOutlet weak var highestPriceLabel: UILabel!
    
    // MARK: - Computed Properties
    
    let defaults = UserDefaults.standard
    var setImageStatus: String = "off" {
        willSet {
            if newValue == "on" {
                guard let image = UIImage(named: "iconLike.png") else { return }
                favoriteButton.setImage(image, for: .normal)
            } else {
                guard let image = UIImage(named: "Like.png") else { return }
                favoriteButton.setImage(image, for: .normal)
            }
        }
    }
    
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        performerImage.layer.cornerRadius = 12
      
      
    }

    // MARK: - Actions
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let event = event else { return }
        event.isFavorited.toggle()
        sender.setImage(event.isFavorited ? UIImage(named: "iconLike") : UIImage(named: "Like"), for: .normal)
        if  event.isFavorited == true {
            
            likedEventDelegate?.update(event: event, eventAction: .favorited)
        }else {
            likedEventDelegate?.update(event: event, eventAction: .removed)
        }
    }

    // MARK: - Methods
    private func updateViews() {
        guard let event = event,
              let performerImage = event.image
        else { return }
        
        self.eventTitle.text = event.title
        self.performerName.text = event.name
        self.eventDateLabel.text = date
        self.listingCountLabel.text = "Listing Count: \(event.listingCount)"
        self.averagePriceLabel.text = "Average Count: \(event.averagePrice)"
        self.lowestPriceLabel.text = "Lowest Count: \(event.lowestPrice)"
        self.highestPriceLabel.text = "Highest Count: \(event.highestPrice)"
        favoriteButton.setImage(event.isFavorited ? UIImage(named: "iconLike") : UIImage(named: "Like"), for: .normal)
        
        EventController.shared.getImages(imageURL: performerImage) { image, _ in
            DispatchQueue.main.async {
                self.performerImage.image = image
            }
        }
        
    }
    
}
