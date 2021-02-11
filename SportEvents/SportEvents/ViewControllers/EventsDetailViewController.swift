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

class EventsDetailViewController: UIViewController {

    static var shared = EventsDetailViewController()
    @IBOutlet weak var performerImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var performerName: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    var event: EventResults.Events?
    var delegate: EventFavoritedProtocol?
    var favoriteEvents = [EventResults.Events?]()
    var isFavorited = false
    weak var likedEventDelegate: FavoriteEventDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()

    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let event = event else { return }
        if sender.currentImage == UIImage(systemName: "iconLike") {
            guard let image = UIImage(named: "Like") else { return }
            sender.setImage(image, for: .selected)
            likedEventDelegate?.update(event: event, eventAction: .removed)
           
        } else {
            guard let image = UIImage(named: "iconLike") else { return }
            sender.setImage(image, for: .normal)
            likedEventDelegate?.update(event: event, eventAction: .favorited)
     
        }
    }
    
    private func updateViews() {
        guard let event = event else { return }
        self.eventTitle.text = event.title
        self.performerName.text = event.name
        let performerImage = event.image
      
        EventController.shared.getImages(imageURL: performerImage) { image, _ in
            DispatchQueue.main.async {
                self.performerImage.image = image
            }
        }
        
    }
}
