//
//  EventsViewController.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import UIKit

class EventsViewController: UIViewController, LikedEventDelegate {
   

    var events = [EventResults.Events]()
    var favoriteEvents = [EventResults.Events]()
    
   
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchEvents()
        favoriteEventss()
      
   
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = layout
        setupCollectionView()
        let flowlayout = UICollectionViewFlowLayout()
        collectionView.accessibilityScroll(.right)
        flowlayout.scrollDirection = .horizontal
      
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.reloadData()
    }
    
    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .white
     
    }
    
    func likeEventButtonTapped(event: EventResults.Events) {
        favoriteEvents.append(event)
    }
    
    func favoriteEventss() {
        FavoriteEventsController.shared.loadFromPersistentStoreEvents {[weak self] events, _ in
            guard let self = self else { return }
            print("this is favorite events: \(events)")
            for event in events {
                self.favoriteEvents.append(event)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
//    func getFavorites() {
//        FavoriteEventsController.shared.loadFromPersistentStoreEvents { [weak self] result in
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let favorites):
//                self.favoriteEvents = favorites
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//            case .failure(let error):
//                NSLog("Failed to get events: \(error)")
//            }
//        }
//    }
    
    func fetchEvents() {
        
        EventController.shared.getEvents { [weak self] events, error in
            guard let self = self else { return }
            if let error = error {
                NSLog("Failed to fetch events with error: \(error)")
                return
            }
            
            guard let events = events else {
                NSLog("No events found")
                return
            }
            
            // We only want to display events
            for event in events.events {
                
                self.events.append(event)
            }
            
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    
    func updateViews() {
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
    
    
    

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        if segue.identifier == "EventDetailSegue" {
        if let eventDetailVC = segue.destination as? EventsDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow{
            let event = events[indexPath.row]
            eventDetailVC.event = event
            eventDetailVC.delegate = self
        }
            
        } else if segue.identifier == "CollectionSegue" {
            if let eventDetailVC = segue.destination as? EventsDetailViewController,
               let cell = sender as? ContentCell,
               let collectionIndex = collectionView.indexPath(for: cell) {
                let collectionEvent =  favoriteEvents[collectionIndex.row]
                eventDetailVC.event = collectionEvent
                eventDetailVC.delegate = self
            }
        }
     }
    
    
}
extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventsTableViewCell", for: indexPath) as? EventsTableViewCell else { return UITableViewCell() }
        cell.event = events[indexPath.row]
        cell.delegate = self 
        guard let imageURL = cell.event?.image else { return cell }
        EventController.shared.getImages(imageURL: imageURL) { image, _ in
            DispatchQueue.main.async {
                cell.performerImage.image = image
               
            }
        }
        
        cell.performerImage.layer.cornerRadius = 12
     
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "All Events"
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
 
    
}

extension EventsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath) as? ContentCell else { return UICollectionViewCell() }
     
        cell.event = favoriteEvents[indexPath.row]
        cell.delegate = self
        
        
        guard let imageURL = cell.event?.image else { return cell}
        EventController.shared.getImages(imageURL: imageURL) { image, _ in
            DispatchQueue.main.async {
                cell.eventImage.image = image
            }
        }
        
        cell.layer.cornerRadius = 12
        cell.cellView.layer.cornerRadius = 12
        cell.eventImage.layer.cornerRadius = 12
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 249, height: 290)
        }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader{
            sectionHeader.sectionHeaderlabel.text = "Section \(indexPath.section)"
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
   
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//    }
    
 

    
    
    
}
extension EventsViewController: EventFavoritedProtocol {
    func didFavoriteEvent(event: EventResults.Events) {
        self.favoriteEvents.append(event)
    }
    
    
}

class SectionHeader: UICollectionReusableView {
    @IBOutlet weak var sectionHeaderlabel: UILabel!
}
