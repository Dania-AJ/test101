//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Dania A on 25/12/2018.
//  Copyright © Dania A. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView : MKMapView!
    var dataController : DataController!
    var pinsArray = [MKPointAnnotation] ()
    var tappedLocation : Location!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //The code of detecting a tap on the map view and extracting the coordinates was taken from Moriya answer here: https://stackoverflow.com/questions/34431459/ios-swift-how-to-add-pinpoint-to-map-on-touch-and-get-detailed-address-of-th, I just changed that to a long press gesture
        
        let mapLongPressGestureRecognizer = UILongPressGestureRecognizer (target: self, action: #selector (mapLongPressed))
        
        mapView.addGestureRecognizer(mapLongPressGestureRecognizer)
        FetchPinsFromDb()
    }
    
    //This method was taken from the mapkit sample code Udacity provided in iOS developer Nanodegree
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //The function of detecting taps on annotation was taken from H Patel's question here https://stackoverflow.com/questions/38667845/swift-mapkit-recognize-pin-tap
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let lat = view.annotation?.coordinate.latitude
        let long = view.annotation?.coordinate.longitude
        let latLongString = "\(lat!),\(long!)"
        let viewController = storyboard?.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        viewController.coords = view.annotation?.coordinate
        viewController.dataController = dataController
        fetchTappedLocation (latLongString)
        
        while true {
            if tappedLocation != nil {
                break
            }
        }
        viewController.imagesLocation = tappedLocation
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func mapLongPressed (gestureRecognizer : UILongPressGestureRecognizer) {
        //Get the long press position on map view
        let longPressPosition = gestureRecognizer.location(in: mapView)
        //convert the long press position on the map view to coordinates
        let coords = mapView.convert(longPressPosition, toCoordinateFrom: mapView)
        //Build a point annotation to add it to the map
        let annotation = MKPointAnnotation ()
        annotation.coordinate = coords
        mapView.addAnnotation(annotation)
        
        //I used these resources to know how to excute an action only at the end of a long press https://stackoverflow.com/questions/3319591/uilongpressgesturerecognizer-gets-called-twice-when-pressing-down, https://stackoverflow.com/questions/27685851/uilongpressgesturerecognizer-getting-fired-twice/27686018
        if gestureRecognizer.state == .ended {
            storePinCoordinates (annotation, coords)
        }
        
    }
    
    func showAlertController (_ title : String, _ msg : String, _ actionTitle : String) {
        let alertController = UIAlertController (title: title, message: msg, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction (title: actionTitle, style: .default, handler: { _ in
            return
        }))
        
    }
    
}


extension MapViewController {
    
    func storePinCoordinates (_ annotation : MKPointAnnotation, _ coords : CLLocationCoordinate2D) {
        //Add the annotation to the array
        pinsArray.append(annotation)
        
        //Add the location as a string to the DB and save the context
        let locationString = "\(coords.latitude),\(coords.longitude)"
        let location = Location (context: dataController.viewContext)
        location.location = locationString
        
        guard (try? dataController.viewContext.save ()) != nil else {
            showAlertController("Error adding location", "There was an error adding the location", "OK")
            return
        }
        
        //Add all the annotations to the map
        mapView.addAnnotations(pinsArray)
    }
    
    func FetchPinsFromDb () {
        //Fetch all locations from DB
        let fecthLocationsRequest : NSFetchRequest <Location> =  Location.fetchRequest()
        
        //results is an array of Locations
        guard let results = try? dataController.viewContext.fetch(fecthLocationsRequest) else {
            showAlertController("Error adding location", "There was an error adding the location", "OK")
            return
        }
        
        updatePinsOnTheMap (results)
    }
    
    func fetchTappedLocation (_ location : String) {
        let tappedLocationFetchRequest : NSFetchRequest <Location> = Location.fetchRequest()
        let predicate = NSPredicate (format: "location == %@", location)
        tappedLocationFetchRequest.predicate = predicate
        
        //results is an array of Locations
        guard let results = try? dataController.viewContext.fetch(tappedLocationFetchRequest) else {
            showAlertController("Error adding location", "There was an error adding the location", "OK")
            return
        }
        if results.count > 0 {
            tappedLocation =  results [0]
        }
    }
    func updatePinsOnTheMap ( _ results : [Location]) {
        //First clear any previous annotations
        pinsArray = []
        //Convert retrived Location NSObjects to PointAnnotations
        for locationInstance in results {
            let locationString = locationInstance.location
            let components = locationString?.components(separatedBy: ",")
            
            let coords = CLLocationCoordinate2D (latitude: Double (components?.first ?? "0") ?? 0, longitude: Double (components?.last ?? "0") ?? 0)
            let annotation = MKPointAnnotation ()
            annotation.coordinate = coords
            pinsArray.append(annotation)
        }
        
        mapView.addAnnotations(pinsArray)
    }
    
}
