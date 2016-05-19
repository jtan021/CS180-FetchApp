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
    var sawRiderAlert: Bool = false
    
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
            profileCell.userInteractionEnabled = false
            // 1) Authenticate user
            if currentUser != nil {
                PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                    if let currentUser = currentUser as? PFUser {
                        // Get information from database
                        let firstName = currentUser["firstName"] as! String
                        let lastName = currentUser["lastName"] as! String
                        let experience = currentUser["experience"] as! String
                        var doubleExperience = Double(experience)
                        print(doubleExperience)
                        var realLevel:Double = 0
                        var realExperience: Double = 0
                        
                        let profilePicData = currentUser["profilePic"] as! PFFile
                        profilePicData.getDataInBackgroundWithBlock({
                            (imageData: NSData?, error: NSError?) -> Void in
                            if (error == nil) {
                                let profilePic = UIImage(data:imageData!)
                                profileCell.profilePic.image = profilePic
                            }
                        })
                        
                        var foundLevel:Bool = false
                        var baseLevel:Double = 1
                        var tempExperience:Double = doubleExperience!
                        
                        if(doubleExperience! < 3) {
                            realLevel = 1
                            realExperience = doubleExperience!
                        } else {
                            var expCap = baseLevel*10/3
                            tempExperience = doubleExperience! - expCap
                            while(tempExperience > 0) {
                                baseLevel+=1
                                expCap = baseLevel*10/3
                                realExperience = tempExperience
                                tempExperience = tempExperience - expCap
                            }
                            realLevel = baseLevel
                        }
//                        while(foundLevel == false) {
//                            let expCap = baseLevel*10/3
//                            // Level -> Range
//                            // 1 -> 3
//                            // 2 -> 6
//                            // 3 -> 10
//                            // 4 -> 13
//                            // 5 -> 16
//                            // ...
//                            // 20 -> 66
//                            if(doubleExperience! < 3) {
//                                foundLevel = true
//                                realLevel = 1
//                            } else if(expCap - tempExperience > 0) {
//                                foundLevel = true
//                                realLevel = baseLevel - 1
//                                realExperience = tempExperience
//                            } else {
//                                tempExperience = tempExperience - expCap
//                            }
//                            baseLevel += 1
//                        }
                        
                        // Set precision of experience to 1 decimal places
                        realExperience = Double(round(10*(realExperience))/10)
                        var realCap = Int(round(realLevel)*10/3)
//                        if(realLevel == 1) {
//                            realCap = Int(round(realLevel)*10/3)
//                        } else {
//                            realCap = Int(round(realLevel+1)*10/3)
//                        }
                        
                        // Set profileCell information
                        profileCell.fullName.text = "\(firstName) \(lastName)"
                        profileCell.level.text = "Level \(Int(realLevel))"
                        profileCell.experience.text = "Experience: \(realExperience)/\(realCap)"
                        
                        currentUser["level"] = "\(Int(realLevel))"
                        currentUser.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                print("User level has been updated.")
                                
                            } else {
                                print("Error - profile: \(error!) \(error!.description)")
                            }
                        }
                        self.tableView.reloadData()
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
                } else if(!silentMode) {
                    print("On")
                    silentCell.silentModeLabel.text = "Silent Mode: ON"
                    silentMode = true
                    tableView.reloadData()
                }
                PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                    if let currentUser = currentUser as? PFUser {
                        if(currentUser["status"] as! String == "red") {
                            print("status is already red, do nothing")
                            return
                        } else if(self.silentMode == false) {
                            currentUser["status"] = "green"
                        } else if (self.silentMode == true) {
                            currentUser["status"] = "grey"
                        }
                        currentUser.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                print("Status successfuly updated")
                            } else {
                                print("Error - silentMode: \(error!) \(error!.description)")
                            }
                        }
                    }
                })
                return
            } else if (indexPath.row == 3) {
                // Show friend's list
                currentView = indexPath.row
                self.performSegueWithIdentifier("friendListSegue", sender: self)
            } else if (indexPath.row == 4) {
                // Show businss
                currentView = indexPath.row
                self.performSegueWithIdentifier("businessSegue", sender: self)
            } else if (indexPath.row == 5) {
                // Show ranking
                currentView = indexPath.row
                self.performSegueWithIdentifier("rankingListSegue", sender: self)
            } else if (indexPath.row == 6) {
                // Show settings
                currentView = indexPath.row
                self.performSegueWithIdentifier("editProfileSegue", sender: self)
            } else {
                // log out
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
        menuItems = ["profile", "home", "silentMode", "friendsList", "business", "ranking", "setting", "logOut"]
        self.tableView.reloadData()
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
            destinationVC.sawRiderAlert = self.sawRiderAlert;
            print(distance)
        } else if (segue.identifier == "friendListSegue") {
            let DestViewController = segue.destinationViewController as! UINavigationController
            let targetController = DestViewController.topViewController as! secondaryVC
            targetController.viewSelect = 0
            targetController.navigationItem.title = "Friend's List"
        } else if (segue.identifier == "rankingListSegue") {
            let DestViewController = segue.destinationViewController as! UINavigationController
            let targetController = DestViewController.topViewController as! secondaryVC
            targetController.viewSelect = 1
            targetController.navigationItem.title = "Local Rankings"
        } else if (segue.identifier == "editProfileSegue") {
            let DestViewController = segue.destinationViewController as! UINavigationController
            let targetController = DestViewController.topViewController as! secondaryVC
            targetController.viewSelect = 2
            targetController.navigationItem.title = "Edit Profile"
        }
    }
    
}
