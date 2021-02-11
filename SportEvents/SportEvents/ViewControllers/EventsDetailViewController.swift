//
//  EventsDetailViewController.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

protocol LikedEventDelegate: AnyObject {
    func likeEventButtonTapped(event: EventResults.Events)
}
import UIKit
enum OnandOF {
    case on
    case off
}
fileprivate var standardDefaults = UserDefaults.standard
class EventsDetailViewController: UIViewController {
    
    // MARK: - Properties
    var event: EventResults.Events?
    var delegate: EventFavoritedProtocol?
    var favoriteEvents = [EventResults.Events?]()
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
        if let imgStatus = defaults.string(forKey: "imgStatus")
        {
            setImageStatus = imgStatus
        } else {
            setImageStatus = "off"
        }
      
    }

    // MARK: - Actions
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let event = event else { return }
        determineEvent(ev: event)
        
    }
    // MARK: - Methods
    func determineEvent(ev: EventResults.Events) {
        guard let event = event else { return }
        var stat = setImageStatus == "on" ? "off" : "on"
        setImageStatus = stat
        if event.id == ev.id {
            defaults.set(stat, forKey: "imgStatus")
            favoriteButton.isSelected = !favoriteButton.isSelected
            if stat == "on" {
               
                guard let image = UIImage(named: "iconLike") else { return }
                favoriteButton.setImage(image, for: .selected)
                likedEventDelegate?.update(event: event, eventAction: .favorited)
            } else {
                stat = "off"
                guard let image = UIImage(named: "Like") else { return }
                favoriteButton.setImage(image, for: .normal)
                likedEventDelegate?.update(event: event, eventAction: .removed)
            }
        }
    }
    
    private func updateViews() {
        guard let event = event,
              let averagePrice = event.averagePrice,
              let listingCount = event.listingCount,
              let lowestPrice = event.lowestPrice,
              let highestPrice = event.highestPrice
        else { return }
        
        self.eventTitle.text = event.title
        self.performerName.text = event.name
        self.eventDateLabel.text = date
        self.listingCountLabel.text = "Listing Count: \(listingCount)"
        self.averagePriceLabel.text = "Average Count: \(averagePrice)"
        self.lowestPriceLabel.text = "Lowest Count: \(lowestPrice)"
        self.highestPriceLabel.text = "Highest Count: \(highestPrice)"
        let performerImage = event.image
        
        EventController.shared.getImages(imageURL: performerImage) { image, _ in
            DispatchQueue.main.async {
                self.performerImage.image = image
            }
        }
        
    }
    
}
