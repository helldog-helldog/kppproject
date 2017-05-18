//
//  HistoryTVC.swift
//  RahoovatorIOS
//
//  Created by MacBook Pro on 5/12/17.
//  Copyright © 2017 Helldog. All rights reserved.
//

protocol HistoryTVCDelegate {
    func didSelectHistoryItem(item: History)
}

import UIKit
import CoreData

class HistoryTVC: UITableViewController, NSFetchedResultsControllerDelegate {

    var delegate: HistoryTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewElements()
    }
    
    func registerTableViewElements() {
        tableView.register(UINib(nibName: "HistoryCellTableViewCell",
                                 bundle: nil), forCellReuseIdentifier: "HistoryCellTableViewCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCellTableViewCell",
                                                     for: indexPath) as! HistoryCellTableViewCell
        let historyItem = fetchedResultsController.object(at: indexPath)

        cell.inputPrice.text = (historyItem.inputValue ?? "") + (historyItem.inputValueMeasure ?? "")
        cell.inputVal.text = (historyItem.inputPrice ?? "") + (historyItem.inputPriceMeasure ?? "")
        cell.outputPrice.text = (historyItem.outputValue ?? "") + (historyItem.outputValueMeasure ?? "")
        cell.outputVal.text = (historyItem.outputPrice ?? "") + (historyItem.outputPriceMeasure ?? "")
        cell.pricePerUnit.text = historyItem.pricePerUnit
        
        return cell

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        
        let historyItem = fetchedResultsController.object(at: indexPath)
        
        delegate?.didSelectHistoryItem(item: historyItem)
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



