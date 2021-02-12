//
//  EventsViewController.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import UIKit
import DZNEmptyDataSet
class EventsViewController: UIViewController, LikedEventDelegate {
    
    // MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    var events = [EventResults.Events]()
    var favoriteEvents = [EventResults.Events]()
    var filteredEvents = [EventResults.Events]()
    var eventController = FavoriteEventsController()
    var searching = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchEvents()
        favoriteEventss()
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        configureSearchController()
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
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
    
    // MARK: - Methods
    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .white
        
    }
    
    func likeEventButtonTapped(event: EventResults.Events) {
        favoriteEvents.append(event)
    }
    
    func favoriteEventss() {
        eventController.loadFromPersistentStoreEvents {[weak self] events, _ in
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
                
                eventDetailVC.likedEventDelegate = self 
            }
        } else if segue.identifier == "CollectionSegue" {
            if let eventDetailVC = segue.destination as? EventsDetailViewController,
               let cell = sender as? ContentCell,
               let collectionIndex = collectionView.indexPath(for: cell) {
                let collectionEvent =  favoriteEvents[collectionIndex.row]
                eventDetailVC.event = collectionEvent
                eventDetailVC.likedEventDelegate = self
            }
        }
    }
    
}
// MARK: - Extensions
extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredEvents.count
        } else {
            return events.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventsTableViewCell", for: indexPath) as? EventsTableViewCell else { return UITableViewCell() }
        
        if searching {
            cell.event = filteredEvents[indexPath.row]
            cell.favoriteDelegate = self
            guard let imageURL = cell.event?.image else { return cell }
            EventController.shared.getImages(imageURL: imageURL) { image, _ in
                DispatchQueue.main.async {
                    cell.performerImage.image = image
                    
                }
            }
        } else {
            cell.event = events[indexPath.row]
            cell.favoriteDelegate = self
            guard let imageURL = cell.event?.image else { return cell }
            EventController.shared.getImages(imageURL: imageURL) { image, _ in
                DispatchQueue.main.async {
                    cell.performerImage.image = image
                    
                }
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
        cell.favoriteDelegate = self
        let favoriteEvent = favoriteEvents[indexPath.row]
        cell.event = favoriteEvents[indexPath.row]
        cell.eventTitle.text = favoriteEvent.title
        cell.eventLocation.text = "📍\(favoriteEvent.city) \(favoriteEvent.terminalName)"
        
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
    
}

extension EventsViewController: FavoriteEventDelegate {
    
    func update(event e: EventResults.Events, eventAction: EventAction) {
        switch eventAction {
        case .favorited:
            self.favoriteEvents.append(e)
        case .removed:
            self.favoriteEvents.removeAll(where: { $0.id == e.id})
        }
    }
}

extension EventsViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource  {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let label = UILabel()
        label.text = "No Favorite Events\n "
        label.font = label.font.withSize(100)
        
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: label.text!, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        UIImage.SymbolConfiguration(pointSize: 104, weight: .ultraLight, scale: .large)
        return UIImage(named: "Like")
    }
    
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        if overrideUserInterfaceStyle == .dark {
            return UIColor.darkGray
        } else {
        return UIColor.tertiarySystemFill
        
        }
    }
}

extension EventsViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Enter type of event"
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text,
              !filter.isEmpty else { return }
        
        searching = true
        filteredEvents = events.filter({ $0.type.lowercased().contains(filter.lowercased()) })
        tableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        tableView.reloadData()
        
    }
}
