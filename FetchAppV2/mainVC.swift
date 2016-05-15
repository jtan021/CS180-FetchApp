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
import MessageUI

protocol HandleMapSearch {
    func newLocationZoomIn(placemark:MKPlacemark)
}

class mainVC: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UIGestureRecognizerDelegate, MFMessageComposeViewControllerDelegate {

    /*
     * Constants
     */
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var geoCoder: CLGeocoder?
    var PickUpDropOff: Bool = false // pickUp = false, dropOff = true
    var distance: Double = 0
    var requestCancel: Bool = false // request = false, cancel = true
    var updatedPickUp:Bool = false
    var updatedDropOff:Bool = false
    var firstOpen:Bool = true
    var returnFromEdit: Bool = false
    var currentUser = PFUser.currentUser()
    var pickupCoordinateLAT: Double = 0
    var pickupCoordinateLONG: Double = 0
    var dropoffCoordinateLAT: Double = 0
    var dropoffCoordinateLONG: Double = 0
    var userLocationLAT:Double = 0
    var userLocationLONG:Double = 0
    var pickupAddressVar: String?
    var dropoffAddressVar: String?
    var pickupCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var dropoffCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var chosenPlaceMark: MKPlacemark? = nil
    var status:String = ""
    var pendingList: String = ""
    var pendingListArray = [String]()
    var friendPhoneNumberArray = [String]()
    
    var pendingFriendFullNameArray = [String]()
    var pendingFriendUsernameArray = [String]()
    var pendingFriendLevelArray = [String]()
    var pendingFriendDistanceArray = [String]()
    var pendingDriversArray = [String]()
    var pendingDistance:Double = 0
    var friendLocationLAT:Double = 0
    var friendLocationLONG:Double = 0
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
    // displayYesNoAlert
    // Inputs: Title: String, Message: String
    // Output: UIAlertController
    // Function: Displays a UIAlertController with "Yes" "No" buttons to ask the user a "Yes/No" Question.
    // Currently is not being used.
    func displayYesNoAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            //Do set location
            print("Location set.")
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // displayOkayAlert
    // Inputs: Title: String, Message: String
    // Output: UIAlertController
    // Function: Displays a UIAlertController with an "Okay" button to show information to the user
    func displayOkayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // DismissKeyboard()
    // Function: Dismisses the keyboard if areas outside of editable text are tapped
    func DismissKeyboard() {
        view.endEditing(true)
    }
    
    // initStoryboard
    // Inputs: UIViewController, Storyboardname
    // Outputs: None
    // Function: Takes view from storyboard and shows as a subview
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
    // Function: Geocodes current location to obtain starting pick up address and updates the pickupCoordinate with the coordinates of the current location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let location: CLLocation = locations.first!
        let coordinate: CLLocationCoordinate2D = location.coordinate
        pickupCoordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        
        // Get user's current location in latitude and longitude
        let cuurrlocation = locations.last! as CLLocation
        self.userLocationLAT = cuurrlocation.coordinate.latitude
        self.userLocationLONG = cuurrlocation.coordinate.longitude
        // Save user's latitude and longitude to ParseDB
        PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
            if let currentUser = currentUser as? PFUser {
                currentUser["currentLAT"] = "\(self.userLocationLAT)"
                currentUser["currentLONG"] = "\(self.userLocationLONG)"
                currentUser.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("User currentLAT & currentLONG has been updated.")
                    } else {
                        print("Error: \(error!) \(error!.description)")
                    }
                }
            }
        })
        
        geoCode(location)
    }
    
    // updateDistance
    // Inputs: CLLocationCoordinate2D, CLLocationCoordinate2D
    // Outputs: None
    // Function: Updates the distance variable and distanceLabel with the driving distance between two CLLocationCooordinate2D objects
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
            self.distanceLabel.text = "Approximate distance: \(self.distance) miles"
            print("distance = \(self.distance)")
        }
    }
    
    func updatePendingDistance(coordinate1:CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> Void {
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
            self.pendingDistance = Double(round(100*realDistance)/100)
        }
    }
    
    // Name: geoCode
    // Inputs: None
    // Outputs: None
    // Function: reverseGeocodes the current location and updates the pickupAddress label
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
        })
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Sets the numberOfRowsInSection of table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pendingFriendFullNameArray.count
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Updates the tableView cell with information
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("driverCell", forIndexPath: indexPath) as! availableDriverCell
        cell.driverName.text = self.pendingFriendFullNameArray[indexPath.row]
        cell.driverLevel.text = self.pendingFriendLevelArray[indexPath.row]
        cell.driverDistance.text = self.pendingFriendDistanceArray[indexPath.row]
        return cell
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Indicates what happens when a user selects a cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // do select for driver
        print("selected pending user")
    }
    
    func checkForPendingFriends() -> Void {
        if currentUser != nil {
            let userQuery = PFQuery(className: "friends")
            userQuery.whereKey("username", equalTo: (self.currentUser?.username!)!)
            userQuery.getFirstObjectInBackgroundWithBlock {
                (userObject: PFObject?, error: NSError?) -> Void in
                if error != nil || userObject == nil {
                    // Error occured
                    print("Error12: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
                } else {
                    let pendingList:String = userObject!["pendingFrom"] as! String
                    if(pendingList != "") {
                        var pendingArray = [String]()
                        pendingArray = pendingList.componentsSeparatedByString(",")
                        for pendingFriend in pendingArray {
                            if(pendingFriend != "") {
                                let alert = UIAlertController(title: "New friend pending", message: "\(pendingFriend) requested to add you to their friend's list.", preferredStyle:  UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Accept", style: .Default, handler: { (action: UIAlertAction!) in
                                    self.updateFriendsList(pendingFriend)
                                }))
                                alert.addAction(UIAlertAction(title: "Ignore", style: .Default, handler: { (action: UIAlertAction!) in
                                    print("ignored")
                                }))
                                alert.addAction(UIAlertAction(title: "Decline", style: .Default, handler: { (action: UIAlertAction!) in
                                    self.removePendingFriend(pendingFriend)
                                }))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateFriendsList(friendUser: String) -> Void {
        // 1) Update user's friendList with new friend
        let userQuery = PFQuery(className: "friends")
        userQuery.whereKey("username", equalTo: (self.currentUser?.username!)!)
        userQuery.getFirstObjectInBackgroundWithBlock {
            (userObject: PFObject?, error: NSError?) -> Void in
            if error != nil || userObject == nil {
                // Error occured
                print("Error13: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
            } else {
                var friendList:String = userObject!["friendsList"] as! String
                if(friendList == "") {
                    friendList = "\(friendUser)"
                } else {
                    friendList = "\(friendList),\(friendUser)"
                }
                userObject!["friendsList"] = friendList
                userObject!.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("userObject updated")
                        self.displayOkayAlert("Friend list updated", message: "You and \(friendUser) are now friends.")
                    } else {
                        print("Error updating user's friend list: \(error!) \(error!.description)")
                    }
                }
            }
        }
        
        // 2) Update friend's friend list with user
        let friendQuery = PFQuery(className: "friends")
        friendQuery.whereKey("username", equalTo: friendUser)
        friendQuery.getFirstObjectInBackgroundWithBlock {
            (friendObject: PFObject?, error: NSError?) -> Void in
            if error != nil || friendObject == nil {
                // Error occured
                print("Error14: Username: \(friendUser) -- \(error!) \(error!.description)")
            } else {
                var friendList:String = friendObject!["friendsList"] as! String
                if(friendList == "") {
                    friendList = "\(self.currentUser!.username!)"
                } else {
                    friendList = "\(friendList),\(self.currentUser!.username!)"
                }
                friendObject!["friendsList"] = friendList
                friendObject!.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("friendObject updated")
                    } else {
                        print("Error updating friend's friendlist: \(error!) \(error!.description)")
                    }
                }
            }
        }
        
        self.removePendingFriend(friendUser)
    }
    
    func removePendingFriend(friendUser: String) -> Void {
        // 1) Remove pending user from user's pending
        let userQuery = PFQuery(className: "friends")
        userQuery.whereKey("username", equalTo: (self.currentUser?.username!)!)
        userQuery.getFirstObjectInBackgroundWithBlock {
            (userObject: PFObject?, error: NSError?) -> Void in
            if error != nil || userObject == nil {
                // Error occured
                print("Error13: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
            } else {
                let pendingList:String = userObject!["pendingFrom"] as! String
                let newPendingList1:String = pendingList.stringByReplacingOccurrencesOfString(friendUser, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let newPendingList2:String = pendingList.stringByReplacingOccurrencesOfString(",\(friendUser)", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                if(newPendingList2 == pendingList) {
                    userObject!["pendingFrom"] = newPendingList1
                } else {
                    userObject!["pendingFrom"] = newPendingList2
                }
                
                userObject!.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("userObject deleted pending friend \(friendUser)")
                    } else {
                        print("Error deleting user's prending friend: \(error!) \(error!.description)")
                    }
                }
            }
        }
        
        // 2) Remove pending user from friend's pending
        let friendQuery = PFQuery(className: "friends")
        friendQuery.whereKey("username", equalTo: friendUser)
        friendQuery.getFirstObjectInBackgroundWithBlock {
            (friendObject: PFObject?, error: NSError?) -> Void in
            if error != nil || friendObject == nil {
                // Error occured
                print("Error14: Username: \(friendUser) -- \(error!) \(error!.description)")
            } else {
                let pendingList:String = friendObject!["pendingTo"] as! String
                let newPendingList1:String = pendingList.stringByReplacingOccurrencesOfString((self.currentUser!.username!), withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let newPendingList2:String = pendingList.stringByReplacingOccurrencesOfString(",\(self.currentUser!.username!)", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                if(newPendingList2 == pendingList) {
                    friendObject!["pendingTo"] = newPendingList1
                } else {
                    friendObject!["pendingTo"] = newPendingList2
                }
                friendObject!.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("friendObject deleted pending user \(self.currentUser?.username!)")
                    } else {
                        print("Error deleting friend's pending friend: \(error!) \(error!.description)")
                    }
                }
            }
        }
    }
    
    // refresh
    // Input: UIRefreshControl
    // Output: None
    // Function: Function for refreshing the tableview
    func refresh(refreshControl: UIRefreshControl) {
        self.populatePendingDriversTable()
        self.driverTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    /*
     * Action Functions
     */
    @IBAction func editPickUpDidTouch(sender: AnyObject) {
        // Check that the user is not currently searching for a rider
        // If user is, then display an alert
        // Else, allow edit
        if(requestCancel == true) { // If request has been set
            self.displayOkayAlert("Request pending", message: "You must cancel the current request and submit a new one to change the pick-up address")
            return
        }
        PickUpDropOff = false // false = pickUp
        self.performSegueWithIdentifier("editAddressSegue", sender: self)
    }
    
    @IBAction func editDropOffDidTouch(sender: AnyObject) {
        // Check that the user is not currently searching for a rider
        // If user is, then display an alert
        // Else, allow edit
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
        // Check that the pickupAddress & dropoffAddress are specified
        // If not, display an alert
        if(pickupAddress.text == "" && dropoffAddress.text == "") {
            self.displayOkayAlert("Missing field(s)", message: "Please select a pick-up and drop-off adddress to continue.")
            return
        }
        if(pickupAddress.text == "") {
            self.displayOkayAlert("Missing field(s)", message: "Please select a pick-up adddress to continue.")
            return
        }
        if(dropoffAddress.text == "") {
            self.displayOkayAlert("Missing field(s)", message: "Please select a drop-off address to continue.")
            return
        }
        
        // Save current info to database
        // 1) Authenticate user
        if currentUser != nil {
            // 2) Search for user object in "rider" class of database
            let query = PFQuery(className: "rider")
            query.whereKey("username", equalTo:currentUser!.username!)
            query.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error != nil || object == nil {
                    // Error occured
                    print("Error: \(error!) \(error!.description)")
                } else {
                    // 3) User object has been found, update information in database
                    object!["pickupAddress"] = self.pickupAddress.text!
                    object!["pickupCoordinateLAT"] = self.pickupCoordinate.latitude
                    object!["pickupCoordinateLONG"] = self.pickupCoordinate.longitude
                    object!["dropoffAddress"] = self.dropoffAddress.text
                    object!["dropoffCoordinateLAT"] = self.dropoffCoordinate.latitude
                    object!["dropoffCoordinateLONG"] = self.dropoffCoordinate.longitude
                    object!["driver"] = ""
                    object!["pendingDriver"] = ""
                    object!["status"] = "Searching for driver."
                    object!["distance"] = "\(self.distance)"
                    self.status = object!["status"] as! String
                    self.primaryStatusLabel.text = self.status
                    object!.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("Object has been saved")
                            
                            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                                if let currentUser = currentUser as? PFUser {
                                    currentUser["status"] = "red"
                                    currentUser.saveInBackgroundWithBlock {
                                        (success: Bool, error: NSError?) -> Void in
                                        if (success) {
                                            print("User status has been updated.")
                                            self.locationManager.startUpdatingLocation()
                                            self.populatePendingDriversTable()
                                        } else {
                                            print("Error: \(error!) \(error!.description)")
                                        }
                                    }
                                }
                            })

                        } else {
                            print("Error: \(error!) \(error!.description)")
                        }
                    }
                }
            }
        }
        
        primaryStatusLabel.text = self.status
        driverArrivedButton.hidden = true
        cancelRideButton.hidden = false
        requestRideButton.hidden = true
        driverTableView.hidden = false
        selectADriverLabel.hidden = false
        requestCancel = true
        self.displayOkayAlert("Ride request sent", message: "Searching for a friendly driver.")
        
        /*  Simulator cannot sendTexts so currently nulled
        *   self.sendTextToFriends()
        */
    }
    
    func sendTextToFriends() -> Void {
        self.friendPhoneNumberArray.removeAll()
        if currentUser != nil {
            let userQuery = PFQuery(className: "friends")
            userQuery.whereKey("username", equalTo: (self.currentUser?.username!)!)
            userQuery.getFirstObjectInBackgroundWithBlock {
                (userObject: PFObject?, error: NSError?) -> Void in
                if error != nil || userObject == nil {
                    // Error occured
                    print("Error12: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
                } else {
                    self.pendingList = userObject!["friendsList"] as! String
                    self.pendingListArray = self.pendingList.componentsSeparatedByString(",")
                    for friendUser in self.pendingListArray {
                        let friendQuery = PFQuery(className: "_User")
                        friendQuery.whereKey("username", equalTo: friendUser)
                        friendQuery.getFirstObjectInBackgroundWithBlock {
                            (userObject: PFObject?, error: NSError?) -> Void in
                            if error != nil || userObject == nil {
                                // Error occured
                                print("Error12: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
                            } else {
                                let phoneNumber = userObject!["phoneNumber"] as! String
                                print("message to be sent to \(phoneNumber)")
                                if (MFMessageComposeViewController.canSendText()) {
                                    let controller = MFMessageComposeViewController()
                                    controller.body = "\(self.currentUser!.username!) needs a ride from \(self.pickupAddress.text) to \(self.dropoffAddress.text). Approximate distance is \(self.distanceLabel.text). Open FetchApp to give them a ride!"
                                    controller.recipients = [phoneNumber]
                                    controller.messageComposeDelegate = self
                                    self.presentViewController(controller, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func populatePendingDriversTable() -> Void {
        self.pendingFriendFullNameArray.removeAll()
        self.pendingFriendDistanceArray.removeAll()
        self.pendingFriendLevelArray.removeAll()
        self.pendingFriendUsernameArray.removeAll()
        if currentUser != nil {
            let userQuery = PFQuery(className: "rider")
            userQuery.whereKey("username", equalTo: currentUser!.username!)
            userQuery.getFirstObjectInBackgroundWithBlock {
                (userObject: PFObject?, error: NSError?) -> Void in
                if error != nil || userObject == nil {
                    // Error occured
                    print("Error: \(error!) \(error!.description)")
                } else {
                    let allPendingDrivers = userObject!["pendingDriver"] as! String
                    self.pendingDriversArray = allPendingDrivers.componentsSeparatedByString(",")
                    for driverUser in self.pendingDriversArray {
                        let query = PFQuery(className: "_User")
                        query.whereKey("username", equalTo: driverUser)
                        query.getFirstObjectInBackgroundWithBlock {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error != nil || object == nil {
                                // Error occured
                                print("Error000: Username: \(driverUser) -- \(error!) \(error!.description)")
                            } else {
                                // Success
                                let firstName = object!["firstName"] as! String
                                let lastName = object!["lastName"] as! String
                                let fullName = "\(firstName) \(lastName)"
                                let level = object!["level"] as! String
                                let friendLAT:String = object!["currentLAT"] as! String
                                let friendLONG:String = object!["currentLONG"] as! String
                                self.friendLocationLAT = Double(friendLAT)!
                                self.friendLocationLONG = Double(friendLONG)!
                                let userCoordinate = CLLocationCoordinate2DMake(self.userLocationLAT, self.userLocationLONG)
                                let friendCoordinate = CLLocationCoordinate2DMake(self.friendLocationLAT, self.friendLocationLONG)
                                if(CLLocationCoordinate2DIsValid(userCoordinate) && CLLocationCoordinate2DIsValid(friendCoordinate)) {
                                    print("both coordinates valid")
                                    self.updatePendingDistance(userCoordinate, coordinate2: friendCoordinate)
                                } else {
                                    print("something went wrong")
                                }
                                self.pendingFriendFullNameArray.append(fullName)
                                self.pendingFriendDistanceArray.append("\(self.pendingDistance) miles")
                                self.pendingFriendLevelArray.append("Level \(level)")
                                self.pendingFriendUsernameArray.append(driverUser)
                                self.driverTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }

    
    @IBAction func cancelRideDidTouch(sender: AnyObject) {
        // Set the status of user to "Waiting for user." in database
        // 1) Authenticate user
        if currentUser != nil {
            // 2) Search for user in rider class
            let query = PFQuery(className: "rider")
            query.whereKey("username", equalTo:currentUser!.username!)
            query.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error != nil || object == nil {
                    // Error occured
                    print("Error: \(error!) \(error!.description)")
                } else {
                    // 3) Set status to Waiting for user.
                    object!["status"] = "Waiting for user."
                    self.status = object!["status"] as! String
                    self.primaryStatusLabel.text = self.status
                    object!.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("Status has been set to Waiting for user.")
                            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                                if let currentUser = currentUser as? PFUser {
                                    currentUser["status"] = "green"
                                    currentUser.saveInBackgroundWithBlock {
                                        (success: Bool, error: NSError?) -> Void in
                                        if (success) {
                                            print("User status has been updated.")
                                            
                                        } else {
                                            print("Error: \(error!) \(error!.description)")
                                        }
                                    }
                                }
                            })
                        } else {
                            print("Error: \(error!) \(error!.description)")
                        }
                    }
                }
            }
        }
        
        // Change all necessary labels & buttons
        primaryStatusLabel.text = "Waiting for user."
        driverArrivedButton.hidden = true
        cancelRideButton.hidden = true
        requestRideButton.hidden = false
        driverTableView.hidden = true
        selectADriverLabel.hidden = true
        requestCancel = false
        requestRideButton.setTitle("Request a ride?", forState: .Normal)
    }
    
    @IBAction func driverArrivedDidTouch(sender: AnyObject) {
        print("driver arrived")
    }
    
    /*
     * Overrided Functions
     */
    override func viewDidLoad() {
        // Implement slide-out menu button
        if self.revealViewController() != nil {
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        // If this is the first time the application has been opened...
        if (self.firstOpen == true) {
            // 1) Set pickup address & coordinate to current location
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            geoCoder = CLGeocoder()

            // 2) Check if the user has used the application before and therefore has a object in the "rider" class already
            // 2.1) Authenticate user
            if currentUser != nil {
                // 2.2) Set default values for rider database variables
                let request = PFObject(className: "rider")
                request["username"] = currentUser!.username!
                request["pickupAddress"] = ""
                request["pickupCoordinateLAT"] = "0"
                request["pickupCoordinateLONG"] = "0"
                request["dropoffAddress"] = ""
                request["dropoffCoordinateLAT"] = "0"
                request["dropoffCoordinateLONG"] = "0"
                request["driver"] = ""
                request["pendingDriver"] = ""
                request["distance"] = "0"
                request["status"] = "Waiting for user."
                
                // 2.3) Search the "rider" class in database for the user
                let query = PFQuery(className: "rider")
                query.whereKey("username", equalTo:currentUser!.username!)
                query.getFirstObjectInBackgroundWithBlock {
                    (object: PFObject?, error: NSError?) -> Void in
                    if error == nil || object != nil {
                        // 2.3a) User has used the application before so do not create a "rider" object for the user
                        print("User has used the application before.")
                    } else {
                        // 2.3b) User has not used the application before and thus a user object does not yet exist
                        // Create the user a "rider" object
                        print("User has not used the application yet. Creating new object in database...")
                        request.saveInBackgroundWithBlock {
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
            
            // Set firstOpen to false
            self.firstOpen = false
            
        // If application is returning from edit view
        } else if (self.returnFromEdit == true) {
            // 1) Set returnFromEdit back to false
            self.returnFromEdit = false
            
            // 2) Update the pickup and dropoff label
            self.pickupAddress.text = self.pickupAddressVar
            self.dropoffAddress.text = self.dropoffAddressVar
            
            // 3) Calculate distance if possible between pick up and drop off location
            if(CLLocationCoordinate2DIsValid(self.pickupCoordinate) && CLLocationCoordinate2DIsValid(self.dropoffCoordinate)) {
                self.updateDistance(self.pickupCoordinate, coordinate2: self.dropoffCoordinate)
            }
        } else {
            // Set pickup and dropoff address to previous set locations
            self.pickupAddress.text = self.pickupAddressVar
            self.dropoffAddress.text = self.dropoffAddressVar
            self.distanceLabel.text = "Approximate distance: \(String(format:"%f", self.distance))"
            self.updateDistance(self.pickupCoordinate, coordinate2: self.dropoffCoordinate)
            // Check if user is currently using the application
            // 1) Authenticate user
            if currentUser != nil {
                // 2) Search for user in rider class
                let query = PFQuery(className: "rider")
                query.whereKey("username", equalTo:currentUser!.username!)
                query.getFirstObjectInBackgroundWithBlock {
                    (object: PFObject?, error: NSError?) -> Void in
                    if error != nil || object == nil {
                        // Error occured
                        print("Error: \(error!) \(error!.description)")
                    } else {
                        // 3) Set status to Waiting for user.
                        self.status = object!["status"] as! String
                        self.primaryStatusLabel.text = self.status
                        
                        // Hide/Show buttons depending on status
                        if(self.status == "Waiting for user.") {
                            self.driverArrivedButton.hidden = true
                            self.cancelRideButton.hidden = true
                            self.requestRideButton.hidden = false
                        } else {
                            self.driverTableView.hidden = false
                            self.selectADriverLabel.hidden = false
                            self.pickupAddress.text = object!["pickupAddress"] as? String
                            self.pickupAddressVar = object!["pickupAddress"] as? String
                            self.pickupCoordinateLAT = object!["pickupCoordinateLAT"] as! Double
                            self.pickupCoordinateLONG = object!["pickupCoordinateLONG"] as! Double
                            self.dropoffAddress.text = object!["dropoffAddress"] as? String
                            self.dropoffAddressVar = object!["pickupAddress"] as? String
                            self.pickupCoordinateLAT = object!["dropoffCoordinateLAT"] as! Double
                            self.pickupCoordinateLAT = object!["dropoffCoordinateLONG"] as! Double
                            self.pickupCoordinate = CLLocationCoordinate2DMake(self.pickupCoordinateLAT, self.pickupCoordinateLONG)
                            self.dropoffCoordinate = CLLocationCoordinate2DMake(self.dropoffCoordinateLAT, self.dropoffCoordinateLONG)
                            if(CLLocationCoordinate2DIsValid(self.pickupCoordinate) && CLLocationCoordinate2DIsValid(self.dropoffCoordinate)) {
                                print("update distance")
                                self.updateDistance(self.pickupCoordinate, coordinate2: self.dropoffCoordinate)
                            }
                            
                            if (self.status == "Searching for driver.") {
                                print("searching")
                                self.driverArrivedButton.hidden = true
                                self.cancelRideButton.hidden = false
                                self.requestRideButton.hidden = true
                            } else if (self.status == "Waiting for driver.") {
                                self.driverArrivedButton.hidden = false
                                self.cancelRideButton.hidden = true
                                self.requestRideButton.hidden = true
                            }
                        }
                    }
                }
            }
        }
        if(primaryStatusLabel.text == "Waiting for user.") {
            self.driverArrivedButton.hidden = true
            self.cancelRideButton.hidden = true
            self.requestRideButton.hidden = false
        }
        
        // Add refresh action to driverTableView
        // Pull down to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(mainVC.refresh(_:)), forControlEvents: .ValueChanged)
        driverTableView.addSubview(refreshControl)
        
        // Hide driverTableView and corresponding label at start
        if(primaryStatusLabel.text == "Waiting for user.") {
            driverTableView.hidden = true
            selectADriverLabel.hidden = true
        } else {
            driverTableView.hidden = false
            selectADriverLabel.hidden = false
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "editAddressSegue") {
            // When performing segue to mapSearchVC
            // Pass current pickup & dropoff address and coordinate
            // Pass "pickupDropOff" boolean to indicate which textfield the user is editting
            let DestViewController = segue.destinationViewController as! UINavigationController
            let targetController = DestViewController.topViewController as! mapSearchVC
            targetController.pickupDropOff = self.PickUpDropOff
            targetController.pickupAddress = self.pickupAddressVar
            targetController.pickupCoordinate = self.pickupCoordinate
            targetController.dropoffAddress = self.dropoffAddressVar
            targetController.dropoffCoordinate = self.dropoffCoordinate
            
            if(self.distance > 0) {
                targetController.distance = self.distance
            }
            // Attempt to set address in next controller
            if(PickUpDropOff == true) {
                // User selected to edit drop-off so set placemark to current dropoff
                // First check if there is a previously selected dropoff location
                // If yes, use that one
                // If no, use default current location (AKA Do nothing)
                if(dropoffAddress.text != "") {
                    targetController.chosenAddress = dropoffAddress.text!
                    print("dropoffLAT = \(self.dropoffCoordinateLAT)")
                    print("dropoffLONG = \(self.dropoffCoordinateLONG)")
                    targetController.chosenCoordinate = CLLocationCoordinate2DMake(self.dropoffCoordinateLAT, self.dropoffCoordinateLONG)
                }
            } else if (PickUpDropOff == false) {
                // User selected to edit pick-up so set placemark to current placemark
                // First check if there is a previously selected pickup location
                // If yes, use that one
                // If no, use default current location (AKA Do nothing)
                if(pickupAddress.text != "") {
                    targetController.chosenAddress = pickupAddress.text!
                    print("pickupLAT = \(self.pickupCoordinateLAT)")
                    print("pickupLAT = \(self.pickupCoordinateLONG)")
                    targetController.chosenCoordinate = CLLocationCoordinate2DMake(self.pickupCoordinateLAT, self.pickupCoordinateLONG)
                }
            }
        }
    }
}


