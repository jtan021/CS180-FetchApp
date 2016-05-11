//
//  mainNavigationController.swift
//  FetchAppV2
//
//  Created by Jonathan Tan on 5/8/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import MapKit

class mainNavigationController: UINavigationController {
    var firstOpen: Bool = true
    var returnFromEdit: Bool = false
    var updatedPickUp: Bool = false
    var updatedDropOff: Bool = false
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationVC:mainVC = segue.destinationViewController as! mainVC
        destinationVC.firstOpen = self.firstOpen
        destinationVC.returnFromEdit = self.returnFromEdit
        destinationVC.updatedPickUp = self.updatedPickUp
        destinationVC.updatedDropOff = self.updatedDropOff
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
