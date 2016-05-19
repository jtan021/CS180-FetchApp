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
    var didCancel: Bool = false
    var currentUser = PFUser.currentUser()
    var pickupAddress: String?
    var pickupCoordinate: CLLocationCoordinate2D?
    var dropoffAddress: String?
    var dropoffCoordinate: CLLocationCoordinate2D?
    var distance: Double = 0
    var sawRiderAlert: Bool = false
    
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
        if (!didMove) {
            mapPin.center.y -= 10
            didMove = true
        }
        if gestureRecognizer.state == .Ended {
            mapPin.center.y += 10
            didMove = false
            print("panning ended")
        }
    }
    
    @IBAction func setLocationDidTouch(sender: AnyObject) {
        self.performSegueWithIdentifier("returnFromEditSegue", sender: self)
    }
    
    @IBAction func resetMapDidTouch(sender: AnyObject) {
        mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
    }
    
    @IBAction func cancelEditDidTouch(sender: AnyObject) {
        self.didCancel = true
        self.performSegueWithIdentifier("returnFromEditSegue", sender: self)
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
            /* 1) Check if user hit cancel edit button (didCancel = true?)
            *  1.a) If yes, pass all values to next  view controller without changing.
            *  1.b) If no, continue with edit...
            *       if pickupDropOff == false
            *           editing pickUpAddress & pickupCoordinate
            *       else if pickupDropOff == true
            *           editing dropoffAddress & dropoffCoordinate
            *       Pass unedited address & coordinate to next view controller for both cases
            */
            if(self.didCancel == true) {
                self.didCancel = false
                destinationVC.pickupAddress = self.pickupAddress!
                destinationVC.pickupCoordinate = self.pickupCoordinate!
                destinationVC.dropoffAddress = self.dropoffAddress!
                destinationVC.dropoffCoordinate = self.dropoffCoordinate!
            } else if (self.didCancel == false) {
                if(self.pickupDropOff == true) {
                    destinationVC.dropoffAddress = self.chosenAddress
                    destinationVC.dropoffCoordinate = CLLocationCoordinate2DMake(self.chosenPlaceMark!.coordinate.latitude, self.chosenPlaceMark!.coordinate.longitude)
                    destinationVC.pickupAddress = self.pickupAddress!
                    destinationVC.pickupCoordinate = self.pickupCoordinate!
                    
                } else if (self.pickupDropOff == false) {
                    destinationVC.pickupAddress = self.chosenAddress
                    destinationVC.pickupCoordinate = CLLocationCoordinate2DMake(self.chosenPlaceMark!.coordinate.latitude, self.chosenPlaceMark!.coordinate.longitude)
                    destinationVC.dropoffAddress = self.dropoffAddress!
                    destinationVC.dropoffCoordinate = self.dropoffCoordinate!
                }
            }
            destinationVC.sawRiderAlert = self.sawRiderAlert
            destinationVC.firstOpen = false
            destinationVC.returnFromEdit = true
            destinationVC.pickupDropOff = self.pickupDropOff!
        }
    }
}

extension mapSearchVC : CLLocationManagerDelegate {
    // Name: locationManager
    // Inputs: None
    // Outputs: None
    // Function: Request location of user
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
    
    // Name: locationManager
    // Inputs: None
    // Outputs: None
    // Function: Error manager
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
}

// Name: mapSearchHandler
// Inputs: None
// Outputs: None
// Function: Zooms into the selected address from the UISearchBar & updates chosenAddress & chosenPlaceMark to the selected location
extension mapSearchVC: mapSearchHandler {
    func getAddress(placemark:MKPlacemark) {
        self.chosenAddress = placemark.title!
        self.chosenPlaceMark = placemark
        self.mapView!.centerCoordinate = placemark.coordinate
        let reg = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 1500, 1500)
        self.mapView!.setRegion(reg, animated: true)
    }
}



