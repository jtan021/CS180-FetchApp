//
//  mainVC.swift
//  FetchAppV2
//
//  Created by Jonathan Tan on 5/3/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation
import QuartzCore

protocol HandleMapSearch {
    func newLocationZoomIn(placemark:MKPlacemark)
}

class mainVC: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UIGestureRecognizerDelegate {
    /*
     * Constants
     */
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var geoCoder: CLGeocoder?
    var PickUpDropOff: Bool = false // pickUp = false, dropOff = true
    var pickupAddressVar: String?
    var dropoffAddressVar: String?
    var updatedPickUp:Bool = false
    var updatedDropOff:Bool = false
    var firstTime:Bool = true
    var activeUser: User!
    var pickupCoordinate: CLLocationCoordinate2D?
    var dropoffCoordinate: CLLocationCoordinate2D?
    var distance: Double?
    var requestCancel: Bool = false // request = false, cancel = true
    var returnFromEdit: Bool = false
    /*
     * Outlets
     */
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pickupAddress: UITextField!
    @IBOutlet weak var dropoffAddress: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var primaryStatusLabel: UILabel!
    @IBOutlet weak var driverArrivedButton: UIButton!
    @IBOutlet weak var requestRideButton: UIButton!
    @IBOutlet weak var cancelRideButton: UIButton!
    @IBOutlet weak var selectADriverLabel: UILabel!
    @IBOutlet weak var driverTableView: UITableView!


    /*
     * Custom functions
     */
    // displayAlert
    // Inputs: title:String, message:String
    // Output: UIAlertAction
    func displayYesNoAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            //Do set location
            print("Location set.")
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayOkayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // DismissKeyboard()
    // Dismisses the keyboard if areas outside of editable text are tapped
    func DismissKeyboard() {
        view.endEditing(true)
    }
    
    // initStoryboard
    // Inputs: UIViewController, Storyboardname
    // Outputs: None
    // Takes view from storyboard and shows as a subview
    func initStoryboard(controller: UIViewController, storyboardName: String)
    {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let childController = storyboard.instantiateInitialViewController() as UIViewController!
        addChildViewController(childController)
        childController.view.backgroundColor = UIColor.redColor()
        controller.view.addSubview(childController.view)
        controller.didMoveToParentViewController(childController)
    }
    
    // locationManager
    // Inputs: None
    // Outputs: None
    // Geocodes current location to obtain starting pick up address
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.first!
        geoCode(location)
    }

    // calculateDistance
    // Inputs: Address 1, Address 2
    // Outputs: Distance
    //
    func calculateDistance(coordinates1:CLLocationCoordinate2D, coordinates2:CLLocationCoordinate2D) -> Double {
        var location1: CLLocation = CLLocation(latitude: coordinates1.latitude, longitude:  coordinates1.longitude)
        var location2: CLLocation = CLLocation(latitude: coordinates2.latitude, longitude:  coordinates2.longitude)
        return location2.distanceFromLocation(location1)
    }
    
    
    // updateDistance
    // Inputs: CLLocationCoordinate2D, CLLocationCoordinate2D
    // Outputs: None
    // Updates the distance variable and distanceLabel with the driving distance between two CLLocationCooordinate2D objects
    func updateDistance(coordinate1:CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> Void {
        var routeDetails: MKRoute?
        let directionsRequest: MKDirectionsRequest = MKDirectionsRequest()
        let placemark1: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(coordinate1.latitude, coordinate1.longitude), addressDictionary: nil)
        let placemark2: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(coordinate2.latitude, coordinate2.longitude), addressDictionary: nil)
        directionsRequest.source = MKMapItem(placemark: placemark1)
        directionsRequest.destination = MKMapItem(placemark: placemark2)
        directionsRequest.transportType = .Automobile
        let directions: MKDirections = MKDirections(request: directionsRequest)
        directions.calculateDirectionsWithCompletionHandler {
            response, error in
            guard let response = response else {
                print("Error %@", error!.description)
                return
            }
            routeDetails = response.routes.first!;
            let realDistance = (routeDetails!.distance / 1609.344)
            self.distance = Double(round(100*realDistance)/100)
            self.distanceLabel.text = "Approximate distance: \(self.distance!) miles"
            print("distance = \(self.distance!)")
        }
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
            let addressDict : [NSString:NSObject] = loc.addressDictionary as! [NSString:NSObject]
            let addrList = addressDict["FormattedAddressLines"] as! [String]
            let address = addrList.joinWithSeparator(", ")
            print(address)
            self.pickupAddress.text = address
            self.pickupAddressVar = address
            self.activeUser!.pickupAddress = address
            self.locationManager.stopUpdatingLocation()
            self.activeUser.pickupCoordinate = location.coordinate
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("driverCell", forIndexPath: indexPath) as! availableDriverCell
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // do select
    }
    
    /*
     * Action Functions
     */
    @IBAction func editPickUpDidTouch(sender: AnyObject) {
        if(requestCancel == true) { // If request has been set
            self.displayOkayAlert("Request pending", message: "You must cancel the current request and submit a new one to change the pick-up address")
            return
        }
        PickUpDropOff = false // false = pickUp
        self.performSegueWithIdentifier("editAddressSegue", sender: self)
    }
    
    @IBAction func editDropOffDidTouch(sender: AnyObject) {
        if(requestCancel == true) { // If request has been set
            self.displayOkayAlert("Request pending", message: "You must cancel the current request and submit a new one to change the drop-off address")
            return
        }
        PickUpDropOff = true // true = dropOff
        self.performSegueWithIdentifier("editAddressSegue", sender: self)
    }

    @IBAction func hasDriverArrivedDidTouch(sender: AnyObject) {
    }
    
    @IBAction func requestRideDidTouch(sender: AnyObject) {
        if(pickupAddress.text == "") {
            self.displayOkayAlert("Missing pick-up location", message: "Please select a pick-up adddress to continue.")
            return
        }
        if(dropoffAddress.text == "") {
            self.displayOkayAlert("Missing drop-off location", message: "Please select a drop-off address to continue.")
            return
        }
        primaryStatusLabel.text = "Searching for a driver..."
        driverArrivedButton.hidden = true
        cancelRideButton.hidden = false
        requestRideButton.hidden = true
        driverTableView.hidden = false
        selectADriverLabel.hidden = false
        requestCancel = true
        print("request touched")
        self.displayOkayAlert("Ride request sent", message: "Searching for a friendly driver.")
        // Do request stuff
    }
    
    @IBAction func cancelRideDidTouch(sender: AnyObject) {
        primaryStatusLabel.text = "Waiting for user."
        driverArrivedButton.hidden = true
        cancelRideButton.hidden = true
        requestRideButton.hidden = false
        driverTableView.hidden = true
        selectADriverLabel.hidden = true
        requestCancel = false
        requestRideButton.setTitle("Request a ride?", forState: .Normal)
        print("cancel touched")
    }
    
    @IBAction func driverArrivedDidTouch(sender: AnyObject) {
        print("driver arrived")
    }
    
    /*
     * Overrided Functions
     */
    override func viewDidLoad() {
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        driverTableView.hidden = true
        selectADriverLabel.hidden = true
        
        if(primaryStatusLabel.text == "Waiting for driver.") {
            driverArrivedButton.hidden = false
            cancelRideButton.hidden = true
            requestRideButton.hidden = true
        } else if(primaryStatusLabel.text == "Waiting for user.") {
            driverArrivedButton.hidden = true
            cancelRideButton.hidden = true
            requestRideButton.hidden = false
        } else if(primaryStatusLabel.text == "Searching for driver..."){
            driverArrivedButton.hidden = true
            cancelRideButton.hidden = false
            requestRideButton.hidden = true
        } else {
            driverArrivedButton.hidden = true
            cancelRideButton.hidden = true
            requestRideButton.hidden = false
        }
        // Setup slide out menu
        // Get user's current location
        if(self.activeUser.updatedPickUp == true) {
            pickupAddress.text = activeUser!.pickupAddress
            dropoffAddress.text = activeUser!.dropoffAddress
            self.activeUser.updatedPickUp = false
        } else if (self.activeUser.updatedDropOff == true) {
            pickupAddress.text = activeUser!.pickupAddress
            dropoffAddress.text = activeUser!.dropoffAddress
            self.activeUser.updatedDropOff = false
        } else if (self.activeUser.firstOpen == true) {
//            activeUser = User()
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            geoCoder = CLGeocoder()
            self.activeUser.firstOpen = false
        }
        
        print("pickup:\(self.activeUser.pickupCoordinate)")
        print("drop:\(self.activeUser.dropoffCoordinate)")
        if(self.activeUser.pickupCoordinate != nil && self.activeUser.dropoffCoordinate != nil) {
            self.updateDistance(self.activeUser!.pickupCoordinate!, coordinate2: self.activeUser!.dropoffCoordinate!)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
//        if(updatedPickUp == true) {
//            pickupAddress.text = pickupAddressVar
//            updatedPickUp = false
//        } else if (updatedDropOff == true) {
//            dropoffAddress.text = dropoffAddressVar
//            updatedDropOff = false
//        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if (segue.identifier == "editAddressSegue") {
            //get a reference to the destination view controller
            //let destinationVC:mapSearchVC = segue.destinationViewController as! mapSearchVC
            var DestViewController = segue.destinationViewController as! UINavigationController
            let targetController = DestViewController.topViewController as! mapSearchVC
            targetController.pickupDropOff = self.PickUpDropOff
            targetController.activeUser = self.activeUser
        }
    }
}


