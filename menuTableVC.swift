//
//  menuTableVC.swift
//  FetchAppV2
//
//  Created by Jonathan Tan on 5/3/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import Parse
import MapKit

class menuTableVC: UITableViewController {
    var menuItems: [AnyObject] = []
    var silentMode: Bool = false
    var currentView = 1
    var pickupAddress: String = ""
    var pickupCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0,0)
    var dropoffCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0,0)
    var dropoffAddress: String = ""
    var firstOpen:Bool = false
    var returnFromEdit:Bool = true
    var pickupDropOff:Bool = false
    var distance: Double = 0
    
    /*
    * Custom functions
    */
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
            print("distance = \(self.distance)")
        }
    }
    
    // displayAlert
    // Inputs: title:String, message:String
    // Output: UIAlertAction
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // initStoryboard
    // Inputs: Controller: UIViewController, StoryboardName: String
    // Output: None
    // Function: Displays the inputted viewcontroller as a subview of the current viewcontroller
//    func initStoryboard(controller: AnyClass, storyboardName: String)
//    {
//        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
//        let childController = storyboard.instantiateInitialViewController() as UIViewController!
//        addChildViewController(childController)
//        childController.view.backgroundColor = UIColor.redColor()
//        controller.view.addSubview(childController.view)
//        controller.didMoveToParentViewController(childController)
//    }
    
    /*
     * Overrided functions
     */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return menuItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentUser = PFUser.currentUser()
        let cellIdentifier: String = menuItems[indexPath.row] as! String
        if(indexPath.row == 0) {
            let profileCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! profileModeCell
            // 1) Authenticate user
            if currentUser != nil {
                PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                    if let currentUser = currentUser as? PFUser {
                        // Get information from database
                        let firstName = currentUser["firstName"] as! String
                        let lastName = currentUser["lastName"] as! String
                        let level = currentUser["level"] as! String
                        var experience = currentUser["experience"] as! String
                        var doubleExperience = Double(experience)
                        // Set precision of experience to 1 decimal places
                        doubleExperience = Double(round(10*(doubleExperience)!)/10)
                        
                        // Calculate experience range
                        var experienceRange:Int = 10
                        experienceRange = Int((Double(level)!*10/3))
                        experienceRange = Int((Double(level)!*10/3))
                        // Level -> Range
                        // 1 -> 3
                        // 2 -> 6
                        // 3 -> 10
                        // 4 -> 13
                        // 5 -> 16
                        // ...
                        // 20 -> 66
                        
                        // Set profileCell information
                        profileCell.fullName.text = "\(firstName) \(lastName)"
                        profileCell.level.text = "Level \(level)"
                        profileCell.experience.text = "Experience: \(doubleExperience)/\(experienceRange)"
                    }
                })
            }
            return profileCell
        } else if(indexPath.row == 2) {
            let silentCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! silentModeCell
            return silentCell
        } else {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if(indexPath.row == 0) {
            return 122
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentUser = PFUser.currentUser()
        let row = indexPath.row
        print("row = \(row)")
        print("currentView = \(currentView)")
        if(row == currentView) {
            self.revealViewController().revealToggleAnimated(true)
            print("same")
            return
        } else {
            print("continued")
            if(indexPath.row == 0) {
                // Do profile
                currentView = indexPath.row
                
            } else if (indexPath.row == 1) {
                currentView = indexPath.row
                self.performSegueWithIdentifier("homeSegue", sender: self)
            } else if (indexPath.row == 2) {
                // Do Silent mode
                print("silent mode")
                let silentCell = tableView.dequeueReusableCellWithIdentifier("silentMode", forIndexPath: indexPath) as! silentModeCell
                if(silentMode) {
                    print("Off")
                    silentCell.silentModeLabel.text = "Silent Mode: OFF"
                    silentMode = false
                    tableView.reloadData()
                    return
                }
                if(!silentMode) {
                    print("On")
                    silentCell.silentModeLabel.text = "Silent Mode: ON"
                    silentMode = true
                    tableView.reloadData()
                    return
                }
                
            } else if (indexPath.row == 3) {
                // Show friend's list
                currentView = indexPath.row
                self.performSegueWithIdentifier("friendListSegue", sender: self)
                
            } else if (indexPath.row == 4) {
                // Show ranking
                currentView = indexPath.row
                
            } else if (indexPath.row == 5) {
                // Show settings
                currentView = indexPath.row
                
            } else if (indexPath.row == 6) {
                // log out
                currentView = indexPath.row
                // Check status of user in database "rider" class
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
                            // 3) Check if status == Searching for driver.
                            let status = object!["status"] as! String
                            if(status == "Waiting for user.") {
                                // 3.5a) If status == Searching for driver., log out.
                                PFUser.logOut()
                                let currentUser = PFUser.currentUser()
                                print(currentUser)
                                print("\nLogout Successful\n")
                                self.performSegueWithIdentifier("successfulLogoutSegue", sender: self)
                            } else {
                                // 3.5b) If status != inacitve, alert user and ask to set status to Searching for driver. and continue log out
                                let alert = UIAlertController(title: "Ride pending", message: "You are currently searching for a ride. Would you like to cancel your search and continue logging out?", preferredStyle:  UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                                    object!["status"] = "Waiting for user."
                                    object!.saveInBackgroundWithBlock {
                                        (success: Bool, error: NSError?) -> Void in
                                        if (success) {
                                            print("Status set to Waiting for user.")
                                        } else {
                                            print("Error: \(error!) \(error!.description)")
                                        }
                                    }
                                    PFUser.logOut()
                                    let currentUser = PFUser.currentUser()
                                    print(currentUser)
                                    print("\nLogout Successful\n")
                                    self.performSegueWithIdentifier("successfulLogoutSegue", sender: self)
                                }))
                                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    /*
    * Overrided functions
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        menuItems = ["profile", "home", "silentMode", "friendsList", "ranking", "setting", "logOut"]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "homeSegue") {
            let destinationVC:SWRevealViewController = segue.destinationViewController as! SWRevealViewController
            destinationVC.firstOpen = self.firstOpen;
            destinationVC.returnFromEdit = false;
            destinationVC.pickupAddress = self.pickupAddress;
            destinationVC.pickupCoordinate = self.pickupCoordinate;
            destinationVC.dropoffAddress = self.dropoffAddress;
            destinationVC.dropoffCoordinate = self.dropoffCoordinate;
            print(distance)
            self.updateDistance(self.pickupCoordinate, coordinate2: self.dropoffCoordinate)
            destinationVC.distance = self.distance;
            print(distance)
        }
    }
    
}
