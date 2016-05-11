//
//  User.swift
//  FetchApp
//
//  Created by Jonathan Tan on 3/21/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import Foundation
import Parse

@objc public class User: NSObject {
    var username: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var fullName: String = ""
    var emailAddress: String = ""
    var pickupAddress: String = ""
    var pickupCoordinate: CLLocationCoordinate2D?
    var dropoffCoordinate: CLLocationCoordinate2D?
    var dropoffAddress: String = ""
    var firstOpen: Bool = true
    var returnFromEdit:Bool = false
    var updatedDropOff: Bool = false
    var updatedPickUp: Bool = false
    let currentUser = PFUser.currentUser()
    
    override init() {
        super.init()
        if currentUser?.username != nil {
            self.username = currentUser!["username"] as! String
            self.firstName = currentUser!["firstName"] as! String
            self.lastName = currentUser!["lastName"] as! String
            self.fullName = self.firstName + " " + self.lastName
            self.emailAddress = currentUser!["email"] as! String
            self.pickupCoordinate = nil
            self.dropoffCoordinate = nil 
            self.pickupAddress = ""
            self.dropoffAddress = ""
            self.firstOpen = true
            self.returnFromEdit = false
        }
    }
    
}