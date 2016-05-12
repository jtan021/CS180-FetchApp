//
//  mainNavigationController.swift
//  FetchAppV2
//
//  Created by Jonathan Tan on 5/8/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import MapKit
import Parse

class mainNavigationController: UINavigationController {
    var firstOpen: Bool = true
    var returnFromEdit: Bool = false
    var updatedPickUp: Bool = false
    var updatedDropOff: Bool = false
    var currentUser = PFUser.currentUser()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationVC:mainVC = segue.destinationViewController as! mainVC
        destinationVC.firstOpen = self.firstOpen
        destinationVC.returnFromEdit = self.returnFromEdit
        destinationVC.updatedPickUp = self.updatedPickUp
        destinationVC.updatedDropOff = self.updatedDropOff
        if(self.firstOpen != true) {
            print("Updating labels in mainNavigationController")
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
                        destinationVC.pickupAddressVar = (object!["pickupAddress"] as! String)
                        destinationVC.pickupCoordinateLAT = (object!["pickupCoordinateLAT"] as! Double)
                        destinationVC.pickupCoordinateLONG = (object!["pickupCoordinateLONG"] as! Double)
                        destinationVC.dropoffAddressVar = (object!["dropoffAddress"] as! String)
                        destinationVC.dropoffCoordinateLAT = (object!["dropoffCoordinateLAT"] as! Double)
                        destinationVC.dropoffCoordinateLONG = (object!["dropoffCoordinateLONG"] as! Double)
                        destinationVC.pickupAddress.text = (object!["pickupAddress"] as! String)
                        destinationVC.dropoffAddress.text = (object!["dropoffAddress"] as! String)
                        destinationVC.pickupCoordinate = CLLocationCoordinate2DMake(destinationVC.pickupCoordinateLAT, destinationVC.pickupCoordinateLONG)
                        destinationVC.dropoffCoordinate = CLLocationCoordinate2DMake(destinationVC.dropoffCoordinateLAT, destinationVC.dropoffCoordinateLONG)
                    }
                }
            }
        }
    }
//        let destinationVC = DestViewController.topViewController as! mainVC
//        if(self.returnFromEdit == true) {
//            destinationVC.firstTime = false
//            destinationVC.updatedDropOff = self.updatedDropOff
//            destinationVC.updatedPickUp = self.updatedPickUp
//        }
//        destinationVC.returnFromEdit = self.returnFromEdit
//        destinationVC.activeUser = self.activeUser
//        if(pickupDropOff == true) { // Pickup = false, drop off = true
//            //destinationVC.dropoffLabel.text = self.chosenAddress!
//            self.activeUser!.dropoffAddress = self.chosenAddress!
//            self.activeUser!.dropoffCoordinate = chosenPlaceMark!.coordinate
//            destinationVC.updatedDropOff = true
//        } else if (pickupDropOff == false) {
//            //destinationVC.pickupLabel.text = self.chosenAddress!
//            self.activeUser!.pickupAddress = self.chosenAddress!
//            self.activeUser!.pickupCoordinate = chosenPlaceMark!.coordinate
//            destinationVC.updatedPickUp = true
//        }
//        destinationVC.activeUser = self.activeUser
//        destinationVC.firstTime = false
//        destinationVC.returnFromEdit = true
        //destinationVC.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
}
