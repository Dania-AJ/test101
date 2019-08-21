//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Dania A on 25/12/2018.
//  Copyright © Dania A. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var newCollectionItem: UIBarButtonItem!
    
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var collectionView : UICollectionView!
    var coords : CLLocationCoordinate2D!
    //Convert the coords to a string so it can be stored easily in the DB
    var latLongString = ""
    var downloadedImages = [UIImage] ()
    var fetchedResultsController : NSFetchedResultsController <Image>!
    var imagesLocation : Location!
    var dataController : DataController!
    var saveObserverToken: Any?
    let arbitraryItemCount = 15
    let loadingActivityIndicatorView = UIActivityIndicatorView (style: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //Make a point annotation
        let annotation = MKPointAnnotation ()
        //Set its coordinates
        annotation.coordinate = coords
        mapView.addAnnotation(annotation)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        latLongString = "\(String(coords.latitude)),\(String(coords.longitude))"
        
        //set up the fetched results controller
        setUpFetchedResultsController()
        
        //Set up the loading indicator that will be used in PhotosViewController+UI
        //I took the way of adding a loading indicator to the screen from Zee's answer here: https://stackoverflow.com/questions/46650183/show-activity-indicator-while-data-load-in-collectionview-swift
        loadingActivityIndicatorView.hidesWhenStopped = true
        loadingActivityIndicatorView.center = CGPoint (x: view.frame.width/2, y: view.frame.height/2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        executeNewtorkRequests()
    }
    
}
