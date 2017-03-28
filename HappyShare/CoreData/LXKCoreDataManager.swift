//
//  LXKCoreDataManager.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/15.
//  Copyright © 2016年 李现科. All rights reserved.
//

import Foundation
import CoreData

let fileName = "HappyShare"
let groupIdentifier = "group.test.HS"

class LXKCoreDataManager {
    
    let managedObjectContext: NSManagedObjectContext?
    let managedObjectModel: NSManagedObjectModel?
    let persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    init() {
        guard let momdURL = Bundle.main.url(forResource: fileName, withExtension: "mom") else {
            managedObjectContext = nil
            managedObjectModel = nil
            persistentStoreCoordinator = nil
            print(Bundle.main.bundlePath, " momd url not found")
            return
        }
        managedObjectModel = NSManagedObjectModel(contentsOf: momdURL)
        guard let managedObjectModel = managedObjectModel else {
            managedObjectContext = nil
            persistentStoreCoordinator = nil
            print(#file, "Managed Object Model init failed")
            return
        }
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)?.appendingPathComponent("\(fileName).sqlite")
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
            try persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch let error {
            fatalError("Unresolved error \(error)")
        }
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext?.performAndWait({ [weak self] in
            let undoManager = UndoManager()
            undoManager.groupsByEvent = false
            self?.managedObjectContext?.undoManager = undoManager
            self?.managedObjectContext?.persistentStoreCoordinator = self?.persistentStoreCoordinator
        })
    }
    
    // MARK: - Public Methods
    
    @discardableResult
    func saveContext() -> Bool {
        guard let managedObjectContext = managedObjectContext else {
            print("Managed Object Context is nil")
            return false
        }
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error {
                print("Unresolved error \(error)")
                return false
            }
        }
        return true
    }
    
    func undo() {
        
        managedObjectContext?.undo()
    }
    
    func redo() {
        managedObjectContext?.redo()
    }
    
    func rollback() {
        managedObjectContext?.rollback()
    }
    
    func reset() {
        managedObjectContext?.reset()
    }
    
}
