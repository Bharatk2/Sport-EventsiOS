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
    weak var likedEventDelegate: LikedEventDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        favoriteButton.addTarget(self, action: #selector(self.likeButtonTapped(_:)) , for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func likeButtonTapped(_ sender: UIButton) {
        guard let eventDelegate = likedEventDelegate,
              let event = event else { return }
        
        eventDelegate.likeEventButtonTapped(event: event)
        }
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let event = event else { return }
        if sender.currentImage == UIImage(systemName: "iconLike") {
            guard let image = UIImage(named: "Like") else { return }
            sender.setImage(image, for: .selected)
         
            FavoriteEventsController.shared.update(event: event, eventAction: .removed)
           
        } else {
            guard let image = UIImage(named: "iconLike") else { return }
            sender.setImage(image, for: .normal)
        
            delegate?.didFavoriteEvent(event: event)
            FavoriteEventsController.shared.loadFromPersistentStore()
            FavoriteEventsController.shared.update(event: event, eventAction: .favorited)
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
