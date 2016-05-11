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
    var activeUser: User = User()
    var distance: Double?
    var requestCancel: Bool = false // request = false, cancel = true
    
    var updatedPickUp:Bool = false
    var updatedDropOff:Bool = false
    var firstOpen:Bool = true
    var returnFromEdit: Bool = false
    var currentUser = PFUser.currentUser()
    var pickupCoordinateLAT: Double?
    var pickupCoordinateLONG: Double?
    var dropoffCoordinateLAT: Double?
    var dropoffCoordinateLONG: Double?
    var pickupAddressVar: String?
    var dropoffAddressVar: String?
    var pickupCoordinate: CLLocationCoordinate2D?
    var dropoffCoordinate: CLLocationCoordinate2D?
    var chosenPlaceMark: MKPlacemark? = nil
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
            self.activeUser.pickupAddress = address
            self.locationManager.stopUpdatingLocation()
            self.activeUser.pickupCoordinate = location.coordinate
            
            self.pickupAddress.text = address
            self.pickupAddressVar = address
            self.pickupCoordinateLAT = location.coordinate.latitude
            self.pickupCoordinateLONG = location.coordinate.longitude
            
            // Save pickup to ParseDB
            self.saveStringToParseDB("rider", dataName: "pickupAddress", newValue: address)
            self.saveDoubleToParseDB("rider", dataName: "pickupCoordinateLAT", newValue: self.pickupCoordinateLAT!)
            self.saveDoubleToParseDB("rider", dataName: "pickupCoordinateLONG", newValue: self.pickupCoordinateLONG!)
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
    
    func searchParseDBforString(className:String, dataName: String) -> String {
        var foundValue: String = ""
        if currentUser != nil {
            // 2) Check if user has used the application before and a user object exists in the database already.
            let query = PFQuery(className: className)
            query.whereKey("username", equalTo:currentUser!.username!)
            query.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error != nil || object == nil {
                    // Error occured
                    print("Error: \(error!) \(error!.description)")
                } else {
                    // The find succeeded.
                    foundValue = object![dataName] as! String
                    print("Found value = \(foundValue)")
                }
            }
        }
        
        if(foundValue != "") {
            return foundValue
        } else {
            return "Error: Username not authorized."
        }
    }
    
    func updateInfoFromDB() -> Void {
        if currentUser != nil {
            // 2) Check if user has used the application before and a user object exists in the database already.
            let query = PFQuery(className: "rider")
            query.whereKey("username", equalTo:currentUser!.username!)
            query.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error != nil || object == nil {
                    // Error occured
                    print("Error: \(error!) \(error!.description)")
                } else {
                    self.pickupAddressVar = (object!["pickupAddress"] as! String)
                    self.pickupCoordinateLAT = (object!["pickupCoordinateLAT"] as! Double)
                    self.pickupCoordinateLONG = (object!["pickupCoordinateLONG"] as! Double)
                    self.dropoffAddressVar = (object!["dropoffAddress"] as! String)
                    self.dropoffCoordinateLAT = (object!["dropoffCoordinateLAT"] as! Double)
                    self.dropoffCoordinateLONG = (object!["dropoffCoordinateLONG"] as! Double)
                    print("New local variables: \n")
                    print("pickupAddress = \(self.pickupAddressVar)\npickupCoordinateLAT = \(self.pickupCoordinateLAT)\npickupCoordinateLONG = \(self.pickupCoordinateLONG)\n")
                    print("dropoffAddress = \(self.dropoffAddressVar)\ndropoffCoordinateLAT = \(self.dropoffCoordinateLAT)\ndropoffCoordinateLONG = \(self.dropoffCoordinateLONG)\n")
                    
                    self.pickupAddress.text = self.pickupAddressVar
                    self.dropoffAddress.text = self.dropoffAddressVar
                    self.pickupCoordinate = CLLocationCoordinate2DMake(self.pickupCoordinateLAT!, self.pickupCoordinateLONG!)
                    self.dropoffCoordinate = CLLocationCoordinate2DMake(self.dropoffCoordinateLAT!, self.dropoffCoordinateLONG!)
                    
                    print("pickup:\(self.pickupAddress.text!)")
                    print("drop:\(self.dropoffAddress.text!)")
                    if(self.pickupCoordinate != nil && self.dropoffCoordinate != nil) {
                        self.updateDistance(self.pickupCoordinate!, coordinate2: self.dropoffCoordinate!)
                    }
                }
            }
        }
    }
    
    func searchParseDBforDouble(className:String, dataName: String) -> Double {
        var foundValue: Double = 0
        if currentUser != nil {
            // 2) Check if user has used the application before and a user object exists in the database already.
            let query = PFQuery(className: className)
            query.whereKey("username", equalTo:currentUser!.username!)
            query.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error != nil || object == nil {
                    // Error occured
                    print("Error: \(error!) \(error!.description)")
                } else {
                    // The find succeeded.
                    foundValue = object![dataName] as! Double
                }
            }
        }
        
        if(foundValue != 0) {
            return foundValue
        } else {
            return 0
        }
    }
    
    func saveDoubleToParseDB(className:String, dataName: String, newValue: Double) -> Void {
        // 1) Verify user
        if currentUser != nil {
            // 2) Check if user has used the application before and a user object exists in the database already.
            var query = PFQuery(className: "rider")
            query.whereKey("username", equalTo:currentUser!.username!)
            query.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error != nil || object == nil {
                    // Error
                    print("Error: \(error!) \(error!.description)")
                } else {
                    // The search succeeded.
                    object![dataName] = newValue
                    object!.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("\(dataName) has been saved")
                        } else {
                            print("Error: \(error!) \(error!.description)")
                        }
                    }
                }
            }
        }
    }
    
    func saveStringToParseDB(className:String, dataName: String, newValue: String) -> Void {
        // 1) Verify user
        if currentUser != nil {
            // 2) Check if user has used the application before and a user object exists in the database already.
            var query = PFQuery(className: "rider")
            query.whereKey("username", equalTo:currentUser!.username!)
            query.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error != nil || object == nil {
                    // Error
                    print("Error: \(error!) \(error!.description)")
                } else {
                    // The search succeeded.
                    object![dataName] = newValue
                    object!.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("\(dataName) has been saved")
                        } else {
                            print("Error: \(error!) \(error!.description)")
                        }
                    }
                }
            }
        }
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
        if (self.firstOpen == true) {
//            activeUser = User()
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            geoCoder = CLGeocoder()
            
            // 1) Check that user exists
            if currentUser != nil {
                // 2) Check if user has used the application before and a user object exists in the database already.
                let request = PFObject(className: "rider")
                request["username"] = currentUser!.username!
                request["pickupAddress"] = ""
                request["pickupCoordinateLAT"] = 0
                request["pickupCoordinateLONG"] = 0
                request["dropoffAddress"] = ""
                request["dropoffCoordinateLAT"] = 0
                request["dropoffCoordinateLONG"] = 0
                request["driver"] = ""
                request["status"] = "inactive"
                
                
                /* Uncomment on first run to create class
                request.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("Object has been saved")
                    } else {
                        print("Error: \(error!) \(error!.description)")
                    }
                }
                */
                
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
                        request.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                print("Object has been saved")
                            } else {
                                print("Error: \(error!) \(error!.description)")
                            }
                        }
                    } else {
                        // The find succeeded.
                        print("User has used the application before.")
                    }
                }
            }
            self.firstOpen = false
            
        } else if (self.returnFromEdit == true) {
            self.updateInfoFromDB()
            self.returnFromEdit = false
//            pickupAddress.text = self.pickupAddressVar
//            dropoffAddress.text = self.dropoffAddressVar
//            pickupCoordinate = CLLocationCoordinate2DMake(self.pickupCoordinateLAT!, self.pickupCoordinateLONG!)
//            dropoffCoordinate = CLLocationCoordinate2DMake(self.dropoffCoordinateLAT!, self.dropoffCoordinateLONG!)
//            self.returnFromEdit = false
        }
//        
//        print("pickup:\(pickupAddress.text)")
//        print("drop:\(dropoffAddress.text)")
//        if(self.activeUser.pickupCoordinate != nil && self.activeUser.dropoffCoordinate != nil) {
//            self.updateDistance(self.activeUser.pickupCoordinate!, coordinate2: self.activeUser.dropoffCoordinate!)
//        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if(self.returnFromEdit == true) {
            print("Updated will")
            self.updateInfoFromDB()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if(self.returnFromEdit == true) {
            print("Updated did")
            self.updateInfoFromDB()
        }
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
            if(PickUpDropOff == true) {
                // User selected to edit drop-off so set placemark to current dropoff
                // First check if there is a previously selected dropoff location
                // If yes, use that one
                // If no, use default current location (AKA Do nothing)
                if(dropoffAddress.text != "") {
                    targetController.chosenAddress = dropoffAddress.text!
                    print(self.dropoffCoordinateLAT!)
                    print(self.dropoffCoordinateLONG!)
                    targetController.chosenCoordinate = CLLocationCoordinate2DMake(self.dropoffCoordinateLAT!, self.dropoffCoordinateLONG!)
                }
            } else if (PickUpDropOff == false) {
                // User selected to edit pick-up so set placemark to current placemark
                // First check if there is a previously selected pickup location
                // If yes, use that one
                // If no, use default current location (AKA Do nothing)
                if(pickupAddress.text != "") {
                    targetController.chosenAddress = pickupAddress.text!
                    print(self.pickupCoordinateLAT!)
                    print(self.pickupCoordinateLONG!)
                    targetController.chosenCoordinate = CLLocationCoordinate2DMake(self.pickupCoordinateLAT!, self.pickupCoordinateLONG!)
                }
            }
        }
    }
}


