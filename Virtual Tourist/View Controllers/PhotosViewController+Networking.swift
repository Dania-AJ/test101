//
//  PhotosViewController+Networking.swift
//  Virtual Tourist
//
//  Created by Dania A on 03/01/2019.
//  Copyright © Dania A. All rights reserved.
//

import Foundation

extension PhotosViewController {
    func executeNewtorkRequests () {
        if fetchedResultsController.fetchedObjects?.count ?? 0 == 0 {
            
            showOrHideActivityIndicator (show: true)
            newCollectionItem.isEnabled = false
            
            APICalls.getPhotosBasedOnLocation(String (coords.latitude), String (coords.longitude)) {photosArray, error in
                DispatchQueue.main.async {
                    if photosArray == nil {
                        
                        if error?.code == 0 {
                            self.showAlert("Error in network connectivity", "Couldn't connect to the network, please check your internet connection")
                            self.loadingActivityIndicatorView.stopAnimating()
                        } else {
                            self.showAlert("Error retrieving images", "Couldn't get images from the server")
                            self.loadingActivityIndicatorView.stopAnimating()
                        }
                    } else {
                        //Get an array that has the urls to download the images
                        APICalls.downloadImage(imagesUrl: self.buildPhotosUrlsArray (photosArray!)) { imagesArray in
                            DispatchQueue.main.async {
                                if imagesArray == nil {
                                    self.showAlert("Error downloading images", "Couldn't download images from the server")
                                } else {
                                    self.downloadedImages = imagesArray!
                                    self.showOrHideActivityIndicator (show: false)
                                    self.newCollectionItem.isEnabled = true
                                    //Store the images in the DB as binary
                                    self.saveImagesToDb()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func buildPhotosUrlsArray ( _ photosArray : [Photo]) -> [URL] {
        
        var urlsArray = [URL] ()
        for i in 0..<photosArray.count {
            
            let urlString = "https://farm\(photosArray[i].farm!).staticflickr.com/\(photosArray[i].serverId!)/\(photosArray[i].photoId!)_\(photosArray[i].secret!).jpg"
            urlsArray.append(URL (string: urlString)!)
        }
        
        return urlsArray
    }
}
