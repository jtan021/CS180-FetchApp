//
//  locationSearchVC.swift
//  FetchAppV2
//
//  Created by Jonathan Tan on 5/5/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import QuartzCore

class locationSearchVC: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UIGestureRecognizerDelegate {
    /*
    * Constants
    */
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil

    var geoCoder: CLGeocoder?
    var searchBar: UISearchBar?
    var previousAddress: String?
    
    /*
     * Outlets
     */
    @IBOutlet weak var mapView: MKMapView!
    
    /*
     * Action functions
     */
    
    /*
     * Custom functions
     */

    
    /*
     * Overrided functions
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup locationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
//        // Setup location search results table
//        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("locationSearchTable") as! locationSearchTable
//        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
//        resultSearchController?.searchResultsUpdater = locationSearchTable
//        
//        // Setup search bar
//        let searchBar = resultSearchController!.searchBar
//        searchBar.sizeToFit()
//        searchBar.placeholder = "Search for places"
//        navigationItem.titleView = resultSearchController?.searchBar
//        resultSearchController?.hidesNavigationBarDuringPresentation = false
//        resultSearchController?.dimsBackgroundDuringPresentation = true
//        definesPresentationContext = true
//
//
////
////        // Search for locations using MKLocalSearchRequest
////        LocationSearchTable.mapView = mapView
////        LocationSearchTable.handleMapSearchDelegate = self
    }
}

//extension locationSearchVC : CLLocationManagerDelegate {
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if status == .AuthorizedWhenInUse {
//            locationManager.requestLocation()
//        }
//    }
//    
//    // Name: locationManager
//    // Inputs: None
//    // Outputs: None
//    // Function: Zooms into map
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            let span = MKCoordinateSpanMake(0.05, 0.05)
//            let region = MKCoordinateRegion(center: location.coordinate, span: span)
//            mapView.setRegion(region, animated: true)
//        }
//    }
//    
//    // Name: locationManager
//    // Inputs: None
//    // Outputs: None
//    // Function: Managers errors with locationManager
//    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        print("error:: \(error)")
//    }
//}

