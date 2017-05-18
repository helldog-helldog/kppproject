//
//  CoreDataManager.swift
//  NewsApp
//
//  Created by Macbook on 1/26/17.
//  Copyright © 2017 LembergSun. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    func add(param1: String,
             param2: String,
             param3: String,
             param4: String,
             param5: String,
             param6: String,
             param7: String,
             param8: String,
             param9: String) {
        let historyEntity    = NSEntityDescription.entity(forEntityName: "History", in: managedObjectContext)
    
        let objectToInsert = History(entity: historyEntity!,
                                     insertInto: managedObjectContext)
        
        objectToInsert.inputPrice = param1
        objectToInsert.inputPriceMeasure = param2
        objectToInsert.inputValue = param3
        objectToInsert.inputValueMeasure = param4
        objectToInsert.outputPrice = param5
        objectToInsert.outputPriceMeasure = param6
        objectToInsert.outputValue = param7
        objectToInsert.outputValueMeasure = param8
        objectToInsert.pricePerUnit = param9
        
        save()
    }
    
    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
// MARK : Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = Bundle.main.url(forResource: "RahoovatorIOS", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("HistoryDB.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: url,
                                               options: nil)
        } catch {
            print("Unresolved error loading data")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
}
