//
//  User.swift
//  FetchApp
//
//  Created by Jonathan Tan on 3/21/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

//
// CLASS IS NOLONGER BEING USED
//
import Foundation
import Parse

@objc public class User: NSObject {
    var pickupAddress: String = ""
    var pickupCoordinate: CLLocationCoordinate2D?
    var dropoffCoordinate: CLLocationCoordinate2D?
    var dropoffAddress: String = ""
    let currentUser = PFUser.currentUser()
    
    override init() {
        super.init()
            self.pickupCoordinate = CLLocationCoordinate2DMake(0,0)
            self.dropoffCoordinate = CLLocationCoordinate2DMake(0,0)
            self.pickupAddress = ""
            self.dropoffAddress = ""
    }
    
}