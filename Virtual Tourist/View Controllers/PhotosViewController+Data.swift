//
//  PhotosViewController+DB.swift
//  Virtual Tourist
//
//  Created by Dania A on 03/01/2019.
//  Copyright © Dania A. All rights reserved.
//

import Foundation
import CoreData

extension PhotosViewController : NSFetchedResultsControllerDelegate {
    func saveImagesToDb () {
        
        //Store the image in the DB along with its location on the background thread
        dataController.backgroundContext.perform {
            for downloadedImage in self.downloadedImages {
                let imageOnBackgroundContext = Image (context: self.dataController.backgroundContext)
                
                let locationObjectId = self.imagesLocation.objectID
                let locationOnBackgroundContext = self.dataController.backgroundContext.object(with: locationObjectId) as! Location
                
                let imageData = NSData (data: downloadedImage.jpegData(compressionQuality: 0.5)!)
                imageOnBackgroundContext.image = imageData as Data
                imageOnBackgroundContext.location = locationOnBackgroundContext
                
                
                guard (try? self.dataController.backgroundContext.save ()) != nil else {
                    self.showAlert("Saving Error", "Couldn't store images in Database")
                    return
                }
            }
        }
        
    }
    
    func setUpFetchedResultsController () {
        //Build a request for the Image ManagedObject
        let fetchRequest : NSFetchRequest <Image> = Image.fetchRequest()
        //Fetch the images only related to the images location
        
        let locationObjectId = self.imagesLocation.objectID
        let locationOnBackgroundContext = self.dataController.backgroundContext.object(with: locationObjectId) as! Location
        let predicate = NSPredicate (format: "location == %@", locationOnBackgroundContext)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "location", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController (fetchRequest: fetchRequest, managedObjectContext: dataController.backgroundContext, sectionNameKeyPath: nil, cacheName: "\(latLongString) images")
        
        fetchedResultsController.delegate = self
        
        
        guard (try? fetchedResultsController.performFetch ()) != nil else {
            self.showAlert("Deletion Error", "Couldn't delete the selected image")
            return
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
