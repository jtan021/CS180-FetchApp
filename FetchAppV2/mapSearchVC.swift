//
//  mapSearchVC.swift
//  FetchAppV2
//
//  Created by Jonathan Tan on 5/5/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import MapKit
import Parse

protocol mapSearchHandler {
    func getAddress(placemark:MKPlacemark)
}

class mapSearchVC: UIViewController, UIGestureRecognizerDelegate {
    let locationManager = CLLocationManager()
    var searchBar: UISearchBar?
    var chosenAddress:String = ""
    var chosenCoordinate: CLLocationCoordinate2D?
    var chosenPlaceMark: MKPlacemark? = nil
    var resultSearchController:UISearchController? = nil
    var geoCoder: CLGeocoder?
    var didMove:Bool = false
    var pickupDropOff: Bool?
    var activeUser: User!
    var currentUser = PFUser.currentUser()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPin: UIImageView!
    
    // Name: didDismissSearchController
    // Inputs: None
    // Outputs: None
    // Function: If searchController was dismissed, reset address to previously set address
    func didDismissSearchController(searchController: UISearchController) {
        print("Search bar was dismissed.")
        self.searchBar!.text = chosenAddress
    }
    
    // DismissKeyboard()
    // Dismisses the keyboard if areas outside of editable text are tapped
    func DismissKeyboard() {
        view.endEditing(true)
    }
    
    // Name: gestureRecognizer
    // Inputs: None
    // Outputs: None
    // Function: Returns true if user pans views
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Name: didDragMap
    // Inputs: gestureRecognizer
    // Outputs: None
    // Function: If gestureRecognizer returns true, user is panning the map so hide the postJobButton. If false or panning ends, unhide the postJobButton
    func didDragMap(gestureRecognizer: UIGestureRecognizer) {
        //        postJobButton.hidden = true
        if (!didMove) {
            mapPin.center.y -= 10
            didMove = true
            //            mapRequestButton.hidden = true
        }
        if gestureRecognizer.state == .Ended {
            //            postJobButton.hidden = false
            mapPin.center.y += 10
            didMove = false
            //            mapRequestButton.hidden = false
            print("panning ended")
        }
    }
    
    @IBAction func setLocationDidTouch(sender: AnyObject) {
        self.performSegueWithIdentifier("returnFromEditSegue", sender: self)
    }
    
    @IBAction func resetMapDidTouch(sender: AnyObject) {
        mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup search bar and link to mapSearchTable
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        geoCoder = CLGeocoder()
        if(self.chosenAddress != "") {
            searchBar?.text = self.chosenAddress
            print(self.chosenAddress)
            print(self.chosenCoordinate)
            self.mapView!.centerCoordinate = self.chosenCoordinate!
            let reg = MKCoordinateRegionMakeWithDistance(self.chosenCoordinate!, 1500, 1500)
            self.mapView!.setRegion(reg, animated: true)
        }
        
        // Setup search bar and locationSearchTable and link them
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("mapSearchTable") as! mapSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        searchBar = resultSearchController!.searchBar
        searchBar!.sizeToFit()
        searchBar!.placeholder = "Search for address"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self

        // Detect if user panned through mapView
        let panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(mapSearchVC.didDragMap(_:)))
        panRecognizer.delegate = self
        self.mapView.addGestureRecognizer(panRecognizer)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "returnFromEditSegue") {
            let destinationVC:SWRevealViewController = segue.destinationViewController as! SWRevealViewController
            
            // 1) Verify user
            if currentUser != nil {
                // 2) Check if user has used the application before and a user object exists in the database already.
                var query = PFQuery(className: "rider")
                query.whereKey("username", equalTo:currentUser!.username!)
                query.getFirstObjectInBackgroundWithBlock {
                    (object: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        // Error occured
                        print("Error: \(error!) \(error!.description)")
                    } else if object == nil {
                        // User has not used the application before and thus a user object does not yet exist
                        // Create the user an object
                        print("User has not used the application yet. Creating new object in database...")
                    } else {
                        // The search succeeded.
                        if(self.pickupDropOff == true) { // Pickup = false, drop off = true
                            //destinationVC.dropoffLabel.text = self.chosenAddress!
                            object!["dropoffAddress"] = self.chosenAddress
                            object!["dropoffCoordinateLAT"] = self.chosenPlaceMark!.coordinate.latitude
                            object!["dropoffCoordinateLONG"] = self.chosenPlaceMark!.coordinate.longitude
//                            destinationVC.updatedDropOff = true
                        } else if (self.pickupDropOff == false) {
                            //destinationVC.pickupLabel.text = self.chosenAddress!
                            object!["pickupAddress"] = self.chosenAddress
                            object!["pickupCoordinateLAT"] = self.chosenPlaceMark!.coordinate.latitude
                            object!["pickupCoordinateLONG"] = self.chosenPlaceMark!.coordinate.longitude
//                            destinationVC.updatedPickUp = true
                        }
                        
                        print("User has used the application before. Saving object in database.")
                        object!.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                print("Object has been saved")
                            } else {
                                print("Error: \(error!) \(error!.description)")
                            }
                        }
                    }
                }
            }
            destinationVC.firstOpen = false
            destinationVC.returnFromEdit = true
        }
    }
}

extension mapSearchVC : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    // Name: locationManager
    // Inputs: None
    // Outputs: None
    // Function: Zooms into map
    func locationManager(manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.first!
        self.mapView!.centerCoordinate = location.coordinate
        let reg = MKCoordinateRegionMakeWithDistance(location.coordinate, 1500, 1500)
        self.mapView!.setRegion(reg, animated: true)
        geoCode(location)
    }
    
    // Name: locationManager
    // Inputs: None
    // Outputs: None
    // Function: Obtains coordinates of current location and sends it to be geoCode
    func mapView(mapView: MKMapView, regionDidChangeAnimated animate: Bool) {
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        geoCode(location)
    }
    
    // Name: geoCode
    // Inputs: None
    // Outputs: None
    // Function: reverseGeocodes the current location and updates the searchBar address
    func geoCode(location : CLLocation!) {
        geoCoder!.cancelGeocode()
        geoCoder!.reverseGeocodeLocation(location, completionHandler: { (data, error) -> Void in
            guard let placeMarks = data as [CLPlacemark]! else {
                return
            }
            let loc: CLPlacemark = placeMarks[0]
            let addressDict : [String: AnyObject] = loc.addressDictionary as! [String: AnyObject]
            let addrList = addressDict["FormattedAddressLines"] as! [String]
            let address = addrList.joinWithSeparator(", ")
            //print(address)
            self.chosenAddress = address
            let coordinate = loc.location!.coordinate
            self.chosenPlaceMark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
            print("ChosenAddress:\(self.chosenAddress)")
            self.searchBar!.text = address
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
}

extension mapSearchVC: mapSearchHandler {
    func getAddress(placemark:MKPlacemark) {
        self.chosenAddress = placemark.title!
        self.chosenPlaceMark = placemark
        self.mapView!.centerCoordinate = placemark.coordinate
        let reg = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 1500, 1500)
        self.mapView!.setRegion(reg, animated: true)
    }
}



