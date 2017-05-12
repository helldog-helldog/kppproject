//
//  HistoryTVC.swift
//  RahoovatorIOS
//
//  Created by MacBook Pro on 5/12/17.
//  Copyright © 2017 Helldog. All rights reserved.
//

protocol HistoryTVCDelegate {
    func didSelectHistoryItem()
}

import UIKit
import CoreData

class HistoryTVC: UITableViewController, NSFetchedResultsControllerDelegate {

    var delegate: HistoryTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let historyItem = fetchedResultsController.object(at: indexPath)
        
        // warning: configure cell
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        delegate?.didSelectHistoryItem()
    }
    
//MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<History> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<History>(entityName: "History")
        fetchRequest.fetchBatchSize = 12
        
        //let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = []
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: CoreDataManager.shared.managedObjectContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            print(nserror.description)
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<History>? = nil
}



