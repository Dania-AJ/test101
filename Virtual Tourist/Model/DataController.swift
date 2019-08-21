//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Dania A on 27/12/2018.
//  Copyright © Dania A. All rights reserved.
//while building some parts of this class I looked to Mooskine app made by Udacity to understand some concept and know how to construct this calss. 

import Foundation
import CoreData

class DataController {
    
    let persistentContainer : NSPersistentContainer
    let viewContext : NSManagedObjectContext
    let backgroundContext : NSManagedObjectContext
    
    //Initializer to initialize the container with a model name injected from another class and to get the view context through the container
    init ( _ modelName : String) {
        persistentContainer = NSPersistentContainer (name: modelName)
        viewContext = persistentContainer.viewContext
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    //Load the persistent store through the container with an optional completion handler for the method that can be optionally used once the loading is completed
    func loadPersistentStore (completion: (()-> Void)? = nil) {
        
        persistentContainer.loadPersistentStores {(persistentStoreDescription, error) in
            guard error == nil else {
                fatalError()
            }
            //Once the store is loaded, keep checking for view context changes and save them if there is any (it's important to autosave so that if the app exits unexpectedly changes will be saved for at least the last 30 seconds)
            self.autoSaveViewContext()
            self.configureContexts()
            completion? ()
        }
    }
    
    func configureContexts () {
        //Configure automatic merge from parent (persistent store)
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        //Configure merge policy
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
}

extension DataController {
    func autoSaveViewContext (duration : TimeInterval = 30) {
        print ("autosaving..")
        if duration < 1 {
            print ("Interval should be greater than 0")
            return
        }
        
        //first check if the view context has any changes, so we don't perform save even if there are no changes
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now () + duration) {
            self.autoSaveViewContext()
        }
        
    }
}
