//
//  PhotosViewController+MapKit.swift
//  Virtual Tourist
//
//  Created by Dania A on 03/01/2019.
//  Copyright © Dania A. All rights reserved.
//

import Foundation
import MapKit

extension PhotosViewController : MKMapViewDelegate {
    
    //This method was taken from the mapkit sample code Udacity provided in iOS developer Nanodegree
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reusableId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusableId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView (annotation: annotation, reuseIdentifier: reusableId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        //Resource for the code below: https://www.youtube.com/watch?v=B6VIUWfuiOs
        let region = MKCoordinateRegion (center: coords, span: MKCoordinateSpan (latitudeDelta: 1, longitudeDelta: 1))
        mapView.region = region
    }
}
