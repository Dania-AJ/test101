//
//  PhotosViewController+UI.swift
//  Virtual Tourist
//
//  Created by Dania A on 03/01/2019.
//  Copyright © Dania A. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

extension PhotosViewController : UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if fetchedResultsController.fetchedObjects?.count ?? 0 == 0 {
            return arbitraryItemCount
        } else {
            return fetchedResultsController.fetchedObjects?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! ImageCell
        
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            cell.placeImage.image = UIImage (named: "placeholder")
            return cell
        }
        
        let imageObject = fetchedResultsController.object(at: indexPath)
        let imageData = imageObject.image
        let uiImage = UIImage (data: imageData!)
        
        cell.placeImage.image = uiImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Set the columns to 3 and the rows to 5 in a rectangle area of the collection view (ususally the area visible on the secreen).
        
        let bounds = collectionView.bounds
        
        return CGSize(width: (bounds.width/3)-2 , height: bounds.height/5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        //Set the left and right spacing of a cell to be 0.5
        return UIEdgeInsets (top: 0, left: 0.5, bottom: 0.5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        //Set minimumLineSpacing to 0
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        //Set minimumInteritemSpacing to 0
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            self.showAlert("Deletion Error", "Please wait till the image is loaded")
            return
        }
        let imageToDelete = fetchedResultsController.object(at: indexPath)
        dataController.backgroundContext.delete(imageToDelete)
        guard (try? dataController.backgroundContext.save()) != nil else {
            self.showAlert("Deletion Error", "Couldn't delete the selected image")
            return
        }
        //Once the line above gets executed controllerWillChangeContent will be called and the collectionView will be reloaded.
    }
    
    func showOrHideActivityIndicator (show: Bool) {
        //I took the way of adding a loading indicator to the screen from Zee's answer here: https://stackoverflow.com/questions/46650183/show-activity-indicator-while-data-load-in-collectionview-swift
        if show {
            view.addSubview(loadingActivityIndicatorView)
            loadingActivityIndicatorView.startAnimating()
        } else {
            loadingActivityIndicatorView.stopAnimating()
        }
    }
    
    @IBAction func newCollectionIsClicked (_ sender: Any) {
        let locationObjectId = self.imagesLocation.objectID
        let locationOnBackgroundContext = self.dataController.backgroundContext.object(with: locationObjectId) as! Location
        let fetchRequest = NSFetchRequest <NSFetchRequestResult> (entityName: "Image")
        let predicate = NSPredicate (format: "location == %@", locationOnBackgroundContext)
        fetchRequest.predicate = predicate
        //I used these resources to know how to perform a batch deleted request: https://cocoacasts.com/how-to-delete-every-record-of-a-core-data-entity, Dave DeLong's answer here: https://stackoverflow.com/questions/1383598/core-data-quickest-way-to-delete-all-instances-of-an-entity
        let deleteRequest = NSBatchDeleteRequest (fetchRequest: fetchRequest)
        
        guard (try? dataController.backgroundContext.execute(deleteRequest)) != nil else {
            self.showAlert("Deletion Error", "Couldn't delete the previously installed images")
            return
        }
        
        //NSBatchDeleteRequest operates on the persistent store directly not on the context, so context is not aware of the resulted changes, since it's not aware also the fetched results controller associated with it won't be aware, that's why we need to call performFetch again.
        //I learned that batch delete are not observed by the context because they operate on the store from: https://stackoverflow.com/questions/33533750/core-data-nsbatchdeleterequest-appears-to-leave-objects-in-context,https://cocoacasts.com/how-to-delete-every-record-of-a-core-data-entity
        //I used this resource to know that I need to call performFetch again (rcedwards' comment): https://github.com/bignerdranch/CoreDataStack/issues/93
        
        guard (try? dataController.backgroundContext.save()) != nil else {
            self.showAlert("Persistence Error", "Database is unable to persist changes")
            return
        }
        guard (try? fetchedResultsController.performFetch()) != nil else {
            self.showAlert("Fetching Error", "Couldn't fetch images from the database")
            return
        }
        collectionView.reloadData()
        executeNewtorkRequests()
    }
    
    func showAlert (_ title: String, _ msg: String) {
        let alertController = UIAlertController (title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction (title: "OK", style: .default, handler: { _ in
            return
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
