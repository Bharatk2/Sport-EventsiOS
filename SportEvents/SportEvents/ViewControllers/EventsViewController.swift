//
//  EventsViewController.swift
//  SportEvents
//
//  Created by Bharat Kumar on 2/9/21.
//

import UIKit
import CoreData
import DZNEmptyDataSet

protocol TrueButtonProtocol: class {
    var favoriteTapped: Bool { get set }
}
class EventsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    
    var searching = false
  var newFavoriteEvents = [Event]()
    var changeImage = false
    
    var eventFetchedResultsController: NSFetchedResultsController<Event>!
    private func setUpFetchResultController(with predicate: NSPredicate = NSPredicate(value: true)) {
        self.eventFetchedResultsController = nil
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
    
        fetchRequest.predicate = predicate
        let context = CoreDataStack.shared.mainContext
        //        context.reset()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
      
        frc.delegate = self
        do {
            
            try frc.performFetch()
        } catch {
            print("Error performing initial fetch inside fetchedResultsController: \(error)")
        }
        self.eventFetchedResultsController = frc
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar(searchBar, textDidChange: "")
        tableView.delegate = self
        tableView.dataSource = self
     
        collectionView.delegate = self
        collectionView.dataSource = self
        //        fetchEvents()
        //        favoriteEventss()
        fetchNewEvents()
        eventFetchedResultsController.delegate = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
       
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = layout
        setupCollectionView()
        let flowlayout = UICollectionViewFlowLayout()
        collectionView.accessibilityScroll(.right)
        flowlayout.scrollDirection = .horizontal
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Event")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try CoreDataStack.shared.mainContext.execute(deleteRequest)
          
        } catch let error as NSError {
          NSLog("error found in deleting: :\(error)")
        }
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    

    // MARK: - Methods
    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .white
        
    }
   
    
    private func fetchNewEvents() {
        EventController.shared.syncEvents { error in
            DispatchQueue.main.async {
                if let error = error {
                    NSLog("Error trying to fetch events: \(error)")
                } else {
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
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
                let event = eventFetchedResultsController.object(at: indexPath)
                eventDetailVC.event = event
                if eventDetailVC.event?.id == event.id {
                    
                }
                eventDetailVC.likedEventDelegate = self
            }
        } else if segue.identifier == "CollectionSegue" {
            if let eventDetailVC = segue.destination as? EventsDetailViewController,
               let cell = sender as? ContentCell,
               let collectionIndex = collectionView.indexPath(for: cell) {
                let collectionEvent =  newFavoriteEvents[collectionIndex.row]
                eventDetailVC.event = collectionEvent
                
                eventDetailVC.likedEventDelegate = self
                
            }
        }
    }
    
}
// MARK: - Extensions
extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return eventFetchedResultsController.sections?[section].numberOfObjects ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventsTableViewCell", for: indexPath) as? EventsTableViewCell else { return UITableViewCell() }
        
        
        cell.corEvent = eventFetchedResultsController.object(at: indexPath)
        
        
        guard let imageURL = cell.corEvent?.image else { return cell }
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
        return newFavoriteEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath) as? ContentCell else { return UICollectionViewCell() }
        cell.favoriteDelegate = self
        
        let favoriteEvent = newFavoriteEvents[indexPath.row]
        cell.event = favoriteEvent
//        cell.eventTitle.text = favoriteEvent.title
//        guard let city = favoriteEvent.city,
//              let terminal = favoriteEvent.terminalName else { return cell }
//        cell.eventLocation.text = "📍\(city) \(terminal)"
        
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

//extension EventsViewController: FavoriteEventDelegate {
//
//    func update(event e: EventResults.Events, eventAction: EventAction) {
//        switch eventAction {
//        case .favorited:
//            self.favoriteEvents.append(e)
//        case .removed:
//            self.favoriteEvents.removeAll(where: { $0.id == e.id})
//        }
//    }
//}

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


extension EventsViewController: FavoriteEventDelegate  {
    
    //MARK: - Initializer
    
    
    
    // MARK: - Methods
    func update(event e: Event, eventAction: EventAction) {
        
        switch eventAction {
        case .favorited:
            var event = e
            newFavoriteEvents.append(e)
            
        
            print(newFavoriteEvents)
        
        case .removed:
            newFavoriteEvents.removeAll(where: {$0.id == e.id})
    
         
        }
        try? CoreDataStack.shared.save(context: CoreDataStack.shared.container.newBackgroundContext())
        
    }
    
   
    
    // MARK: Persistent Store
}
extension EventsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                  let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}

extension EventsViewController: UISearchBarDelegate, UISearchDisplayDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format: "name contains[c] '\(searchText)'")
         
            setUpFetchResultController(with: predicate)
        } else {
            setUpFetchResultController()
        }
        tableView.reloadData()
    }
}
