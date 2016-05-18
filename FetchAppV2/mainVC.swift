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
    var pendingDistance:Double = -1
    var friendLocationLAT:Double = 0
    var friendLocationLONG:Double = 0
    var selectedDriver:String = ""
    var riderUser: String = ""
    var riderPickupAddress: String = ""
    var riderDropoffAddress: String = ""
    //var isADriver: Bool = false
    /*
     * Outlets
     */
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pickupAddress: UITextField!
    @IBOutlet weak var dropoffAddress: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var primaryStatusLabel: UILabel!
    @IBOutlet weak var requestRideButton: UIButton!
    @IBOutlet weak var cancelRideButton: UIButton!
    @IBOutlet weak var selectADriverLabel: UILabel!
    @IBOutlet weak var driverTableView: UITableView!
    @IBOutlet weak var viewToDim: UIView!
    @IBOutlet weak var driverView: UIView!
    @IBOutlet weak var driverViewPic: UIImageView!
    @IBOutlet weak var driverViewFullName: UILabel!
    @IBOutlet weak var driverViewUsername: UILabel!
    @IBOutlet weak var driverViewLevel: UILabel!
    @IBOutlet weak var letUsKnowLabel: UILabel!
    @IBOutlet weak var driverArrived2Button: UIButton!
    @IBOutlet weak var taskDriverLabel: UILabel!
    @IBOutlet weak var taskDriverInfoLabel: UILabel!
    @IBOutlet weak var taskPickupAddress: UILabel!
    @IBOutlet weak var taskDropoffAddress: UILabel!
    @IBOutlet weak var taskView: UIView!
    @IBOutlet weak var travellingView: UIView!
    @IBOutlet weak var travellingMapView: MKMapView!
    @IBOutlet weak var travellingLabel: UILabel!

    /*
     * Custom functions
     * *Functions not being used
     */
    // *displayYesNoAlert
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
    
    func displayRiderAlert() {
        let alert = UIAlertController(title: "\(self.riderUser) accepted your driver request.", message: "Please proceed to \(riderPickupAddress) to pick up \(self.riderUser).", preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action: UIAlertAction!) in
            self.taskView.hidden = false
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // DismissKeyboard()
    // Inputs: None
    // Outputs; None
    // Function: Dismisses the keyboard
    func DismissKeyboard() {
        view.endEditing(true)
    }
    
    // locationManager
    // Inputs: None
    // Outputs: None
    // Function: First gets user's current location to initialize pickupCoordinate at startup and update currentLAT and currentLONG in database. Then geocodes user's current location.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Stop getting User's location
        self.locationManager.stopUpdatingLocation()
        // Get coordinates from location and update pickupCoordinate
        let location: CLLocation = locations.first!
        let coordinate: CLLocationCoordinate2D = location.coordinate
        pickupCoordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        
        // Get user's current location in latitude and longitude and initializes userLocationLAT and userLocationLONG
        let currlocation = locations.last! as CLLocation
        self.userLocationLAT = currlocation.coordinate.latitude
        self.userLocationLONG = currlocation.coordinate.longitude
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
                        print("Error1 - locationManager: \(error!) \(error!.description)")
                    }
                }
            }
        })
        
        // geoCode location
        geoCode(location)
    }
    
    func checkIfDriving() -> Void {
        let riderQuery = PFQuery(className: "rider")
        riderQuery.whereKey("driver", equalTo: (self.currentUser!.username!))
        if(self.firstOpen == true) {
            riderQuery.getFirstObjectInBackgroundWithBlock {
                (riderObject: PFObject?, error: NSError?) -> Void in
                if error != nil || riderObject == nil {
                    // Error occured or user is not a driver
                    print("Error14 - checkIfDriving: \(error!) \(error!.description)")
                    self.taskDriverLabel.text = "No driving task"
                    self.taskDriverInfoLabel.text = "You currently are not driving anyone. Check your friend's list to see if anyone needs a ride."
                    self.taskPickupAddress.text = "N/A"
                    self.taskDropoffAddress.text = "N/A"
                } else {
                    // User is a driver
                    self.riderUser = riderObject!["username"] as! String
                    self.riderPickupAddress = riderObject!["pickupAddress"] as! String
                    self.riderDropoffAddress = riderObject!["dropoffAddress"] as! String
                    self.taskDriverLabel.text = "You are \(self.riderUser)'s Driver"
                    self.taskDriverInfoLabel.text = "Please proceed to the pick-up address and \(self.riderUser) will notify us when you have finished this task."
                    self.taskPickupAddress.text = "\(self.riderPickupAddress)"
                    self.taskDropoffAddress.text = "\(self.riderDropoffAddress)"
                    self.displayRiderAlert()
                }
            }
        } else {
            riderQuery.getFirstObjectInBackgroundWithBlock {
                (riderObject: PFObject?, error: NSError?) -> Void in
                if error != nil || riderObject == nil {
                    // Error occured or user is not a driver
                    print("Error14 - checkIfDriving: \(error!) \(error!.description)")
                    self.taskDriverLabel.text = "No driving task"
                    self.taskDriverInfoLabel.text = "You currently are not driving anyone. Check your friend's list to see if anyone needs a ride."
                    self.taskPickupAddress.text = "N/A"
                    self.taskDropoffAddress.text = "N/A"
                } else {
                    // User is a driver
                    self.riderUser = riderObject!["username"] as! String
                    self.riderPickupAddress = riderObject!["pickupAddress"] as! String
                    self.riderDropoffAddress = riderObject!["dropoffAddress"] as! String
                    self.taskDriverLabel.text = "You are \(self.riderUser)'s Driver"
                    self.taskDriverInfoLabel.text = "Please proceed to the pick-up address and \(self.riderUser) will notify us when you have finished this task."
                    self.taskPickupAddress.text = "\(self.riderPickupAddress)"
                    self.taskDropoffAddress.text = "\(self.riderDropoffAddress)"
                }
            }
        }
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
    
    // updatePendingDistance
    // Inputs: CLLocationCoordinate2D, CLLocationCoordinate2D
    // Outputs: None
    // Function: Updates the pendingDistance variable with the driving distance between two CLLocationCooordinate2D objects. Used for calculating distance between user and pending driver.
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
    // Function: reverseGeocodes the current location to obtain a string from coordinates and updates the pickupAddress label
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
    // Function: Sets the numberOfRowsInSection of table to pendingFriendFullNameArray.count
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pendingFriendFullNameArray.count
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Updates the tableView availableDriverCells with their specific information given by pending*Arrays
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("driverCell", forIndexPath: indexPath) as! availableDriverCell
        cell.driverName.text = self.pendingFriendFullNameArray[indexPath.row]
        cell.driverLevel.text = self.pendingFriendLevelArray[indexPath.row]
        cell.driverDistance.text = self.pendingFriendDistanceArray[indexPath.row]
        if(cell.driverDistance.text == "Getting distance...") {
            self.refresh(UIRefreshControl())
        }
        return cell
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Indicates what happens when a user selects a cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // do select for driver
        print("selected pending user")
        self.selectedDriver = self.pendingFriendUsernameArray[indexPath.row]
        self.driverViewFullName.text = self.pendingFriendFullNameArray[indexPath.row]
        self.driverViewUsername.text = self.pendingFriendUsernameArray[indexPath.row]
        self.driverViewLevel.text = self.pendingFriendLevelArray[indexPath.row]
        self.viewToDim.hidden = false
        self.driverView.hidden = false
        
    }
    
//    // Name: checkForPendingFriends
//    // Inputs: None
//    func checkForPendingFriends() -> Void {
//        if currentUser != nil {
//            let userQuery = PFQuery(className: "friends")
//            userQuery.whereKey("username", equalTo: (self.currentUser?.username!)!)
//            userQuery.getFirstObjectInBackgroundWithBlock {
//                (userObject: PFObject?, error: NSError?) -> Void in
//                if error != nil || userObject == nil {
//                    // Error occured
//                    print("Error12: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
//                } else {
//                    let pendingList:String = userObject!["pendingFrom"] as! String
//                    if(pendingList != "") {
//                        var pendingArray = [String]()
//                        pendingArray = pendingList.componentsSeparatedByString(",")
//                        for pendingFriend in pendingArray {
//                            if(pendingFriend != "") {
//                                let alert = UIAlertController(title: "New friend pending", message: "\(pendingFriend) requested to add you to their friend's list.", preferredStyle:  UIAlertControllerStyle.Alert)
//                                alert.addAction(UIAlertAction(title: "Accept", style: .Default, handler: { (action: UIAlertAction!) in
//                                    self.updateFriendsList(pendingFriend)
//                                }))
//                                alert.addAction(UIAlertAction(title: "Ignore", style: .Default, handler: { (action: UIAlertAction!) in
//                                    print("ignored")
//                                }))
//                                alert.addAction(UIAlertAction(title: "Decline", style: .Default, handler: { (action: UIAlertAction!) in
//                                    self.removePendingFriend(pendingFriend)
//                                }))
//                                self.presentViewController(alert, animated: true, completion: nil)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func updateFriendsList(friendUser: String) -> Void {
//        // 1) Update user's friendList with new friend
//        let userQuery = PFQuery(className: "friends")
//        userQuery.whereKey("username", equalTo: (self.currentUser?.username!)!)
//        userQuery.getFirstObjectInBackgroundWithBlock {
//            (userObject: PFObject?, error: NSError?) -> Void in
//            if error != nil || userObject == nil {
//                // Error occured
//                print("Error13: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
//            } else {
//                var friendList:String = userObject!["friendsList"] as! String
//                if(friendList == "") {
//                    friendList = "\(friendUser)"
//                } else {
//                    friendList = "\(friendList),\(friendUser)"
//                }
//                userObject!["friendsList"] = friendList
//                userObject!.saveInBackgroundWithBlock {
//                    (success: Bool, error: NSError?) -> Void in
//                    if (success) {
//                        print("userObject updated")
//                        self.displayOkayAlert("Friend list updated", message: "You and \(friendUser) are now friends.")
//                    } else {
//                        print("Error updating user's friend list: \(error!) \(error!.description)")
//                    }
//                }
//            }
//        }
//        
//        // 2) Update friend's friend list with user
//        let friendQuery = PFQuery(className: "friends")
//        friendQuery.whereKey("username", equalTo: friendUser)
//        friendQuery.getFirstObjectInBackgroundWithBlock {
//            (friendObject: PFObject?, error: NSError?) -> Void in
//            if error != nil || friendObject == nil {
//                // Error occured
//                print("Error14: Username: \(friendUser) -- \(error!) \(error!.description)")
//            } else {
//                var friendList:String = friendObject!["friendsList"] as! String
//                if(friendList == "") {
//                    friendList = "\(self.currentUser!.username!)"
//                } else {
//                    friendList = "\(friendList),\(self.currentUser!.username!)"
//                }
//                friendObject!["friendsList"] = friendList
//                friendObject!.saveInBackgroundWithBlock {
//                    (success: Bool, error: NSError?) -> Void in
//                    if (success) {
//                        print("friendObject updated")
//                    } else {
//                        print("Error updating friend's friendlist: \(error!) \(error!.description)")
//                    }
//                }
//            }
//        }
//        
//        self.removePendingFriend(friendUser)
//    }
//    
//    func removePendingFriend(friendUser: String) -> Void {
//        // 1) Remove pending user from user's pending
//        let userQuery = PFQuery(className: "friends")
//        userQuery.whereKey("username", equalTo: (self.currentUser?.username!)!)
//        userQuery.getFirstObjectInBackgroundWithBlock {
//            (userObject: PFObject?, error: NSError?) -> Void in
//            if error != nil || userObject == nil {
//                // Error occured
//                print("Error13: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
//            } else {
//                let pendingList:String = userObject!["pendingFrom"] as! String
//                let newPendingList1:String = pendingList.stringByReplacingOccurrencesOfString(friendUser, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//                let newPendingList2:String = pendingList.stringByReplacingOccurrencesOfString(",\(friendUser)", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//                
//                if(newPendingList2 == pendingList) {
//                    userObject!["pendingFrom"] = newPendingList1
//                } else {
//                    userObject!["pendingFrom"] = newPendingList2
//                }
//                
//                userObject!.saveInBackgroundWithBlock {
//                    (success: Bool, error: NSError?) -> Void in
//                    if (success) {
//                        print("userObject deleted pending friend \(friendUser)")
//                    } else {
//                        print("Error deleting user's prending friend: \(error!) \(error!.description)")
//                    }
//                }
//            }
//        }
//        
//        // 2) Remove pending user from friend's pending
//        let friendQuery = PFQuery(className: "friends")
//        friendQuery.whereKey("username", equalTo: friendUser)
//        friendQuery.getFirstObjectInBackgroundWithBlock {
//            (friendObject: PFObject?, error: NSError?) -> Void in
//            if error != nil || friendObject == nil {
//                // Error occured
//                print("Error14: Username: \(friendUser) -- \(error!) \(error!.description)")
//            } else {
//                let pendingList:String = friendObject!["pendingTo"] as! String
//                let newPendingList1:String = pendingList.stringByReplacingOccurrencesOfString((self.currentUser!.username!), withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//                let newPendingList2:String = pendingList.stringByReplacingOccurrencesOfString(",\(self.currentUser!.username!)", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//                
//                if(newPendingList2 == pendingList) {
//                    friendObject!["pendingTo"] = newPendingList1
//                } else {
//                    friendObject!["pendingTo"] = newPendingList2
//                }
//                friendObject!.saveInBackgroundWithBlock {
//                    (success: Bool, error: NSError?) -> Void in
//                    if (success) {
//                        print("friendObject deleted pending user \(self.currentUser?.username!)")
//                    } else {
//                        print("Error deleting friend's pending friend: \(error!) \(error!.description)")
//                    }
//                }
//            }
//        }
//    }
    
    // refresh
    // Input: UIRefreshControl
    // Output: None
    // Function: Gets driverTableView data from database and then refreshes the driverTableView.
    func refresh(refreshControl: UIRefreshControl) {
        self.populatePendingDriversTable()
        self.driverTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // *sendTextToFriends
    // Input: None
    // Output: None
    // Function: Queries user's friendlist and sends a text to all friends that the user needs a ride. Currently not in use because not runnable in simulator.
    func sendTextToFriends() -> Void {
        self.friendPhoneNumberArray.removeAll()
        if currentUser != nil {
            let userQuery = PFQuery(className: "friends")
            userQuery.whereKey("username", equalTo: (self.currentUser?.username!)!)
            userQuery.getFirstObjectInBackgroundWithBlock {
                (userObject: PFObject?, error: NSError?) -> Void in
                if error != nil || userObject == nil {
                    // Error occured
                    print("Error12 - sendTextToFriends: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
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
                                print("Error13 - sendTextToFriends: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
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
    
    // messageComposeViewController
    // Input: None
    // Output: None
    // Function: Used to handle sending messages to phone numbers. Currently not in use because sending texts to phone numbers is not possible in simulator.
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // populatePendingDriversTable
    // Input: None
    // Output: None
    // Function: Queries database for pending drivers and updates the pending*arrays with the corresponding information for each pending driver.
    func populatePendingDriversTable() -> Void {
        // Clear pending*arrays
        self.pendingFriendFullNameArray.removeAll()
        self.pendingFriendDistanceArray.removeAll()
        self.pendingFriendLevelArray.removeAll()
        self.pendingFriendUsernameArray.removeAll()
        
        // Query database for pendingDrivers
        if currentUser != nil {
            let userQuery = PFQuery(className: "rider")
            userQuery.whereKey("username", equalTo: currentUser!.username!)
            userQuery.getFirstObjectInBackgroundWithBlock {
                (userObject: PFObject?, error: NSError?) -> Void in
                if error != nil || userObject == nil {
                    // Error occured
                    print("Error2 - populatePendingDriversTable: \(error!) \(error!.description)")
                } else {
                    // Get all pending drivers and store their individual usernames in pendingDriversArray
                    let allPendingDrivers = userObject!["pendingDriver"] as! String
                    self.pendingDriversArray = allPendingDrivers.componentsSeparatedByString(",")
                    
                    // Get information from database on each driver from pendingDriversArray
                    for driverUser in self.pendingDriversArray {
                        let query = PFQuery(className: "_User")
                        query.whereKey("username", equalTo: driverUser)
                        query.getFirstObjectInBackgroundWithBlock {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error != nil || object == nil {
                                // Error occured
                                print("Error3 - populatePendingDriversTable: Username: \(driverUser) -- \(error!) \(error!.description)")
                            } else {
                                // Success, append information of drivers to pending*Arrays
                                let firstName = object!["firstName"] as! String
                                let lastName = object!["lastName"] as! String
                                let fullName = "\(firstName) \(lastName)"
                                let level = object!["level"] as! String
                                let friendLAT:String = object!["currentLAT"] as! String
                                let friendLONG:String = object!["currentLONG"] as! String
                                self.friendLocationLAT = Double(friendLAT)!
                                self.friendLocationLONG = Double(friendLONG)!
                                print("friendLocationLAT = \(self.friendLocationLAT)")
                                print("friendLocationLONG = \(self.friendLocationLONG)")
                                print("userLocationLAT = \(self.userLocationLAT)")
                                print("userLocationLONG = \(self.userLocationLONG)")
                                print("userCoordinate = \(self.pickupCoordinate)")
                                let userCoordinate = CLLocationCoordinate2DMake(self.userLocationLAT, self.userLocationLONG)
                                let friendCoordinate = CLLocationCoordinate2DMake(self.friendLocationLAT, self.friendLocationLONG)
                                if(CLLocationCoordinate2DIsValid(userCoordinate) && CLLocationCoordinate2DIsValid(friendCoordinate)) {
                                    print("both coordinates valid")
                                    self.updatePendingDistance(self.pickupCoordinate, coordinate2: friendCoordinate)
                                    if(self.pendingDistance >= 0) {
                                        self.pendingFriendDistanceArray.append("\(self.pendingDistance) miles")
                                    } else {
                                        self.pendingFriendDistanceArray.append("Getting distance...")
                                    }
                                } else {
                                    print("something went wrong")
                                }
                                self.pendingFriendFullNameArray.append(fullName)
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

    
    /*
     * Action Functions
     */
    @IBAction func editPickUpDidTouch(sender: AnyObject) {
        // Check that the user is not currently searching for a rider
        // If user is, then display an alert
        // Else, allow edit
        if(self.primaryStatusLabel.text == "Searching for driver.") { // If request has been set
            self.displayOkayAlert("Request pending", message: "You must cancel the current request and submit a new one to change the pick-up address")
            return
        } else if(self.primaryStatusLabel.text != "Waiting for user.") { // If request has been set
            self.displayOkayAlert("Job pending", message: "You cannot edit the pick-up address while you have an active request.")
            return
        }
        PickUpDropOff = false // false = pickUp
        self.performSegueWithIdentifier("editAddressSegue", sender: self)
    }
    
    @IBAction func editDropOffDidTouch(sender: AnyObject) {
        // Check that the user is not currently searching for a rider
        // If user is, then display an alert
        // Else, allow edit
        if(self.primaryStatusLabel.text == "Searching for driver.") { // If request has been set
            self.displayOkayAlert("Request pending", message: "You must cancel the current request and submit a new one to change the drop-off address")
            return
        } else if(self.primaryStatusLabel.text != "Waiting for user.") { // If request has been set
            self.displayOkayAlert("Job pending", message: "You cannot edit the drop-off address while you have an active request.")
            return
        }
        PickUpDropOff = true // true = dropOff
        self.performSegueWithIdentifier("editAddressSegue", sender: self)
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
        
        // Check if the user is currently a driver.)
        if(self.taskPickupAddress.text != "N/A") {
            let alert = UIAlertController(title: "Error", message: "You cannot place a ride request with an active task.", preferredStyle:  UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action: UIAlertAction!) in
                self.taskView.hidden = false
                print("got in")
            }))
            self.presentViewController(alert, animated: true, completion: nil)
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
                    print("Error4 - requestRideDidTouch: \(error!) \(error!.description)")
                } else {
                    // 3) User object has been found, update information in database to set status to searching for driver
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
                            print("Request has been saved")
                            // 4) Update user status to red
                            // green = idle
                            // red = searching for ride
                            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                                if let currentUser = currentUser as? PFUser {
                                    currentUser["status"] = "red"
                                    currentUser.saveInBackgroundWithBlock {
                                        (success: Bool, error: NSError?) -> Void in
                                        if (success) {
                                            print("User status has been updated.")
                                            // 5) Start location manager to update currentLAT and currentLOC in database
                                            self.locationManager.startUpdatingLocation()
                                            self.populatePendingDriversTable()
                                        } else {
                                            print("Error5 - requestRideDidTouch: \(error!) \(error!.description)")
                                        }
                                    }
                                }
                            })

                        } else {
                            print("Error6 - requestRideDidTouch: \(error!) \(error!.description)")
                        }
                    }
                }
            }
        }
        
        // Change all necessary labels & buttons
        primaryStatusLabel.text = self.status
        driverArrived2Button.hidden = true
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
                    print("Error7 - cancelRideDidTouch: \(error!) \(error!.description)")
                } else {
                    // 3) Set status back to Waiting for user and save to database.
                    object!["status"] = "Waiting for user."
                    self.status = object!["status"] as! String
                    self.primaryStatusLabel.text = self.status
                    object!.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("Status has been set to Waiting for user.")
                            // 4) Set User status back to "green" and save to database
                            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                                if let currentUser = currentUser as? PFUser {
                                    currentUser["status"] = "green"
                                    currentUser.saveInBackgroundWithBlock {
                                        (success: Bool, error: NSError?) -> Void in
                                        if (success) {
                                            print("User status has been updated.")
                                            
                                        } else {
                                            print("Error8 - cancelRideDidTouch: \(error!) \(error!.description)")
                                        }
                                    }
                                }
                            })
                        } else {
                            print("Error9 - cancelRideDidTouch: \(error!) \(error!.description)")
                        }
                    }
                }
            }
        }
        
        // Change all necessary labels & buttons
        primaryStatusLabel.text = "Waiting for user."
        driverArrived2Button.hidden = true
        cancelRideButton.hidden = true
        requestRideButton.hidden = false
        driverTableView.hidden = true
        selectADriverLabel.hidden = true
        requestCancel = false
        requestRideButton.setTitle("Request a ride?", forState: .Normal)
    }
    
    @IBAction func driverArrivedDidTouch(sender: AnyObject) {
        print("driver arrived")
        self.displayOkayAlert("Starting mile tracker", message: "Let us know when you have arrived at your destination.")
        self.letUsKnowLabel.text = "Let us know when you have arrived at your destination."
    }
    
    // Still have to update database
    @IBAction func driverArrived2DidTouch(sender: AnyObject) {
        print("driver arrived2")
        if(self.primaryStatusLabel.text == "Waiting for driver.") {
            self.displayOkayAlert("Starting mile tracker", message: "Let us know when you have arrived at your destination.")
            self.primaryStatusLabel.text = "Travelling..."
            self.letUsKnowLabel.text = "Let us know when you have arrived at your destination."
            self.driverArrived2Button.backgroundColor = UIColor(red: 227/255, green: 67/255, blue: 69/255, alpha: 1)
            self.driverArrived2Button.setTitle("I have arrived at my destination.", forState: .Normal)
            if currentUser != nil {
                let userQuery = PFQuery(className: "rider")
                userQuery.whereKey("username", equalTo:self.currentUser!.username!)
                userQuery.getFirstObjectInBackgroundWithBlock {
                    (userObject: PFObject?, error: NSError?) -> Void in
                    if error == nil && userObject != nil {
                        userObject!["status"] = "Travelling..."
                        userObject!.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                print("User status updated to travelling")
                            } else {
                                print("Error16 - driverArrived2DidTouch: \(error!) \(error!.description)")
                            }
                        }
                    } else {
                        print("Error15 - driverArrived2DidTouch: \(error!) \(error!.description)")
                    }
                }
            }
            // Start mile tracking
        } else if (self.primaryStatusLabel.text == "Travelling...") {
            // end adventure
            self.displayOkayAlert("Ending ride.", message: "You have travelled 10 miles.")
            self.primaryStatusLabel.text = "Waiting for user."
            self.driverArrived2Button.hidden = true
            self.cancelRideButton.hidden = true
            self.requestRideButton.hidden = false
            self.letUsKnowLabel.hidden = true
            self.driverArrived2Button.backgroundColor = UIColor(red: 77/255, green: 166/255, blue: 17/255, alpha: 1)
            if currentUser != nil {
                let userQuery = PFQuery(className: "rider")
                userQuery.whereKey("username", equalTo:self.currentUser!.username!)
                userQuery.getFirstObjectInBackgroundWithBlock {
                    (userObject: PFObject?, error: NSError?) -> Void in
                    if error == nil && userObject != nil {
                        userObject!["status"] = "Waiting for user."
                        userObject!.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                print("User status updated to Waiting for user.")
                            } else {
                                print("Error18 - driverArrived2DidTouch: \(error!) \(error!.description)")
                            }
                        }
                    } else {
                        print("Error17 - driverArrived2DidTouch: \(error!) \(error!.description)")
                    }
                }
            }
        }
    }
    
    @IBAction func acceptDriverDidTouch(sender: AnyObject) {
        let userQuery = PFQuery(className: "rider")
        userQuery.whereKey("username", equalTo: self.currentUser!.username!)
        userQuery.getFirstObjectInBackgroundWithBlock {
            (userObject: PFObject?, error: NSError?) -> Void in
            if error != nil || userObject == nil {
                // Error occured
                print("Error12 - acceptDriverDidTouch: \(error!) \(error!.description)")
            } else {
                userObject!["driver"] = self.driverViewUsername.text!
                userObject!["status"] = "Waiting for driver."
                userObject!["pendingDriver"] = ""
                userObject!.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("User's rider driver & status has been updated.")
                        PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                            if let currentUser = currentUser as? PFUser {
                                currentUser["status"] = "grey"
                                currentUser.saveInBackgroundWithBlock {
                                    (success: Bool, error: NSError?) -> Void in
                                    if (success) {
                                        print("User's status has been updated")
                                    } else {
                                        print("Error: \(error!) \(error!.description)")
                                    }
                                }
                            }
                        })
                        self.refresh(UIRefreshControl())
                        self.driverTableView.hidden = true
                        self.driverView.hidden = true
                        self.viewToDim.hidden = true
                        
                        self.status = "Waiting for driver."
                        self.primaryStatusLabel.text = self.status
                        self.letUsKnowLabel.text = "Let us know when \(self.selectedDriver) arrives so that we can start counting miles."
                        self.letUsKnowLabel.hidden = false
                        self.driverArrived2Button.setTitle("\(self.selectedDriver) has arrived.", forState: .Normal)
                        self.driverArrived2Button.hidden = false
                        self.selectADriverLabel.hidden = true
                        self.cancelRideButton.hidden = true
                        self.requestRideButton.hidden = true
                    } else {
                        print("Error: \(error!) \(error!.description)")
                    }
                }
            }
        }
    }
    
    @IBAction func declineDriverDidTouch(sender: AnyObject) {
        let userQuery = PFQuery(className: "rider")
        userQuery.whereKey("username", equalTo: self.currentUser!.username!)
        userQuery.getFirstObjectInBackgroundWithBlock {
            (userObject: PFObject?, error: NSError?) -> Void in
            if error != nil || userObject == nil {
                // Error occured
                print("Error11 - declineDriverDidTouch: \(error!) \(error!.description)")
            } else {
                let pendingDriver = userObject!["pendingDriver"] as! String
                let newPendingDriver1:String = pendingDriver.stringByReplacingOccurrencesOfString((self.driverViewUsername.text!), withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let newPendingDriver2:String = pendingDriver.stringByReplacingOccurrencesOfString(",\(self.driverViewUsername.text!)", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                if(newPendingDriver2 == pendingDriver) {
                    userObject!["pendingDriver"] = newPendingDriver1
                } else {
                    userObject!["pendingDriver"] = newPendingDriver2
                }
                userObject!.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("User's pending drivers has been updated.")
                        self.refresh(UIRefreshControl())
                        self.driverView.hidden = true
                        self.viewToDim.hidden = true
                    } else {
                        print("Error: \(error!) \(error!.description)")
                    }
                }
            }
        }
    }
    
    @IBAction func cancelDriverViewDidTouch(sender: AnyObject) {
        self.driverView.hidden = true
        self.viewToDim.hidden = true
    }
    
    @IBAction func taskPickupAddressDidTouch(sender: AnyObject) {
        print("touched taskpickup")
        if(self.taskPickupAddress.text == "N/A") {
            print("invalid dropoff, not a driver")
            return
        }
        let origURL: String = "http://maps.apple.com/?q=\(self.taskPickupAddress.text!)"
        let convertedURL : NSString = origURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let searchURL : NSURL = NSURL(string: convertedURL as String)!
        UIApplication.sharedApplication().openURL(searchURL)
    }
    
    @IBAction func taskDropoffDidTouch(sender: AnyObject) {
        print("touched taskdropoff")
        if(self.taskDropoffAddress.text == "N/A") {
            print("invalid dropoff, not a driver")
            return
        }
        
        let origURL: String = "http://maps.apple.com/?q=\(self.taskDropoffAddress.text!)"
        let convertedURL : NSString = origURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let searchURL : NSURL = NSURL(string: convertedURL as String)!
        UIApplication.sharedApplication().openURL(searchURL)
    }
    
    @IBAction func taskViewDidTouch(sender: AnyObject) {
        if(self.taskView.hidden == true) {
           self.taskView.hidden = false
        } else {
            self.taskView.hidden = true
        }
    }
    
    /*
     * Overrided Functions
     */
    override func viewDidLoad() {
        // Hide views
        self.taskView.hidden = true
        self.driverView.hidden = true
        self.viewToDim.hidden = true
        self.letUsKnowLabel.hidden = true
        self.driverArrived2Button.hidden = true
        self.travellingView.hidden = true
        self.driverArrived2Button.backgroundColor = UIColor(red: 77/255, green: 166/255, blue: 17/255, alpha: 1)

        // Implement slide-out menu button
        if self.revealViewController() != nil {
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        // Setup default task view
        self.taskDriverLabel.text = "No driving task"
        self.taskDriverInfoLabel.text = "You currently are not driving anyone. Check your friend's list to see if anyone needs a ride."
        self.taskPickupAddress.text = "N/A"
        self.taskDropoffAddress.text = "N/A"
        
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
                                print("Error10 - viewDidLoad firstOpen: \(error!) \(error!.description)")
                            }
                        }
                    }
                }
            }
            
            // Set firstOpen to false
            self.firstOpen = false
            
            // Check if user is a driver
            self.checkIfDriving()
        // If application is returning from edit view
        } else if (self.returnFromEdit == true) {
            // Check if user is a driver
            self.checkIfDriving()
            
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
            // Check if user is a driver
            self.checkIfDriving()
            
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
                        print("Error11 - viewDidLoad firstOpen else: \(error!) \(error!.description)")
                    } else {
                        // 3) Set status to Waiting for user.
                        self.status = object!["status"] as! String
                        self.primaryStatusLabel.text = self.status
                        
                        // Hide/Show buttons depending on status
                        if(self.status == "Waiting for user.") {
                            self.driverArrived2Button.hidden = true
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
                            self.selectedDriver = object!["driver"] as! String
                            self.pickupCoordinate = CLLocationCoordinate2DMake(self.pickupCoordinateLAT, self.pickupCoordinateLONG)
                            self.dropoffCoordinate = CLLocationCoordinate2DMake(self.dropoffCoordinateLAT, self.dropoffCoordinateLONG)
                            if(CLLocationCoordinate2DIsValid(self.pickupCoordinate) && CLLocationCoordinate2DIsValid(self.dropoffCoordinate)) {
                                print("update distance")
                                self.updateDistance(self.pickupCoordinate, coordinate2: self.dropoffCoordinate)
                            }
                            
                            if (self.status == "Searching for driver.") {
                                print("searching")
                                self.letUsKnowLabel.hidden = true
                                self.driverArrived2Button.hidden = true
                                self.cancelRideButton.hidden = false
                                self.requestRideButton.hidden = true
                            } else if (self.status == "Waiting for driver.") {
                                self.letUsKnowLabel.text = "Let us know when \(self.selectedDriver) arrives so that we can start counting miles."
                                self.letUsKnowLabel.hidden = false
                                self.driverArrived2Button.setTitle("\(self.selectedDriver) has arrived.", forState: .Normal)
                                self.driverTableView.hidden = true
                                self.selectADriverLabel.hidden = true
                                self.driverArrived2Button.hidden = false
                                self.cancelRideButton.hidden = true
                                self.requestRideButton.hidden = true
                            } else if (self.status == "Travelling...") {
                                self.letUsKnowLabel.text = "Let us know when you have arrived at your destination."
                                self.driverArrived2Button.backgroundColor = UIColor(red: 227/255, green: 67/255, blue: 69/255, alpha: 1)
                                self.driverArrived2Button.setTitle("I have arrived at my destination.", forState: .Normal)
                                self.letUsKnowLabel.hidden = false
                                self.driverTableView.hidden = true
                                self.selectADriverLabel.hidden = true
                                self.driverArrived2Button.hidden = false
                                self.cancelRideButton.hidden = true
                                self.requestRideButton.hidden = true
                            }
                        }
                    }
                }
            }
        }
        if(primaryStatusLabel.text == "Waiting for user.") {
            self.driverArrived2Button.hidden = true
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


