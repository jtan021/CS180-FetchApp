//
//  businessVC.swift
//  FetchAppV3
//
//  Created by Jonathan Tan on 5/19/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import Parse

struct businessItem {
    var businessName: String
    var members: String
}

class businessVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentUser = PFUser.currentUser()
    var inputTextField: UITextField?
    var groupInputTextField: UITextField?
    var businessArray = [businessItem]()
    
    @IBOutlet weak var jobTableView: UITableView!
    @IBOutlet weak var jobViewToDim: UIView!
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var jobViewTitle: UILabel!
    @IBOutlet weak var jobViewTextView: UITextView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // displayOkayAlert
    // Inputs: Title: String, Message: String
    // Output: UIAlertController
    // Function: Displays a UIAlertController with an "Okay" button to show information to the user
    func displayOkayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateJobTable() -> Void {
        self.businessArray.removeAll()
        if (currentUser != nil) {
            let businessQuery = PFQuery(className: "business")
            businessQuery.whereKey("username", equalTo: self.currentUser!.username!)
            businessQuery.findObjectsInBackgroundWithBlock {
                (businessObjects: [PFObject]?, error: NSError?) -> Void in
                if error == nil && businessObjects != nil {
                    // Search succeeded
                    if let businessObjects = businessObjects {
                        for business in businessObjects {
                            print(business)
                            let businessName = business["businessName"] as! String
                            let members = business["members"] as! String
                            self.businessArray.append(businessItem(businessName: businessName, members: members))
                            self.jobTableView.reloadData()
                        }
                    }
                } else {
                    print("Error updateJobTable: \(error!) \(error!.description)")
                }
            }
        }
    }
    
    // refresh
    // Input: UIRefreshControl
    // Output: None
    // Function: Function for refreshing the tableview
    func refreshTable(refreshControl: UIRefreshControl) {
        self.updateJobTable()
        self.jobTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Sets the numberOfRowsInSection of table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessArray.count
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Updates the tableView cell with information
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let businessName: String = self.businessArray[indexPath.row].businessName
        let businessCell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) 
        businessCell.textLabel!.text = businessName
        return businessCell
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Indicates what happens when a user selects a cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected cell")
        self.jobViewTitle.text = self.businessArray[indexPath.row].businessName
        self.jobViewTextView.text = self.businessArray[indexPath.row].members
        self.jobViewToDim.hidden = false
        self.jobView.hidden = false
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let businessName = self.businessArray[indexPath.row].businessName
        let businessQuery = PFQuery(className: "business")
        businessQuery.whereKey("username", equalTo: self.currentUser!.username!)
        businessQuery.whereKey("businessName", equalTo: businessName)
        businessQuery.getFirstObjectInBackgroundWithBlock {
            (groupObject: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                groupObject?.deleteInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("group deleted")
                        self.businessArray.removeAtIndex(indexPath.row)
                        self.updateJobTable()
                        self.jobTableView.reloadData()
                    } else {
                        print("Error with deleting business: \(error!) \(error!.description)")
                    }
                }
            }
        }
    }

    
    @IBAction func jobViewAddDidTouch(sender: AnyObject) {
        let alertController: UIAlertController = UIAlertController(title: "Add employee", message: "Enter the employee's FetchApp account username.", preferredStyle: .Alert)
        let addFriend: UIAlertAction = UIAlertAction(title: "Add", style: .Default) { action -> Void in
            let friendUsername = self.inputTextField!.text
            let business = self.jobViewTitle.text
            // Check if friendUsername is valid
            if(friendUsername == "") {
                self.displayOkayAlert("Invalid entry", message: "You must specify a FetchApp account username to add to the business.")
                return
            } else {
                // Check if friendUsername is already in business
                let prevGroup: String = self.jobViewTextView.text
                var prevGroupArray = [String]()
                var employeeExist:Bool = false
                prevGroupArray = prevGroup.componentsSeparatedByString(",")
                for employee in prevGroupArray {
                    if(employee == friendUsername) {
                        employeeExist = true
                    }
                }
                if(employeeExist == true) { // Employee is in the business already
                    self.displayOkayAlert("Error", message: "\(friendUsername!) already exists in \(business!).")
                    return
                } else {
                    // Employee is not in the business
                    // Check if friendUsername is on friend's list
                    var employeeExist2:Bool = false
                    let userQuery = PFQuery(className: "friends")
                    userQuery.whereKey("username", equalTo: self.currentUser!.username!)
                    userQuery.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error != nil || object == nil {
                            // Error occurred
                            print("Error userQuery - add member to business: \(error!) \(error!.description)")
                        } else {
                            // Success
                            let allFriends = object!["friendsList"]
                            var allFriendsArray = [String]()
                            allFriendsArray = allFriends.componentsSeparatedByString(",")
                            for friend in allFriendsArray {
                                if(friend == friendUsername) {
                                    employeeExist2 = true
                                }
                            }
                            if(employeeExist2 == false) {
                                self.displayOkayAlert("Error", message: "\(friendUsername!) does not exist on your friend's list. Add them to your friend's list first in order to add them to this business group.")
                            } else {
                                let businessQuery = PFQuery(className: "business")
                                businessQuery.whereKey("username", equalTo: self.currentUser!.username!)
                                businessQuery.whereKey("businessName", equalTo: business!)
                                businessQuery.getFirstObjectInBackgroundWithBlock {
                                    (object: PFObject?, error: NSError?) -> Void in
                                    if error != nil || object == nil {
                                        // Error occurred
                                        print("Error - add member to business: \(error!) \(error!.description)")
                                    } else {
                                        // Group name does not exist under user, create group
                                        let prevMembers = object!["members"] as! String
                                        var newMembers = ""
                                        if(prevMembers == "") {
                                            newMembers = "\(friendUsername!)"
                                        } else {
                                            newMembers = "\(prevMembers),\(friendUsername!)"
                                        }
                                        object!["members"] = newMembers
                                        object!.saveInBackgroundWithBlock {
                                            (success: Bool, error: NSError?) -> Void in
                                            if (success) {
                                                print("\(business) successfully updated.")
                                                self.updateJobTable()
                                                self.jobTableView.reloadData()
                                                self.displayOkayAlert("\(business!) updated", message: "\(friendUsername!) has been added to \(business!).")
                                                self.jobViewTextView.text = newMembers
                                            } else {
                                                print("Error - add member to business: \(error!) \(error!.description)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        alertController.addAction(addFriend)
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Default) { action -> Void in
            print("Canceled")
        }
        alertController.addAction(cancelAction)
        //Add a text field
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            self.inputTextField = textField
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func jobViewRemoveDidTouch(sender: AnyObject) {
        let alertController: UIAlertController = UIAlertController(title: "Remove employee", message: "Enter the employee's FetchApp account username.", preferredStyle: .Alert)
        let removeFriend: UIAlertAction = UIAlertAction(title: "Remove", style: .Default) { action -> Void in
            let friendUsername = self.inputTextField!.text
            let business = self.jobViewTitle.text
            // Check if friendUsername is valid
            if(friendUsername == "") {
                self.displayOkayAlert("Error", message: "You must specify a FetchApp account username to remove them from the business.")
                return
                // Check that there is someone to remove
            } else if (self.jobViewTextView.text == "") {
                self.displayOkayAlert("Invalid entry", message: "\(friendUsername!) is not employed in \(business!).")
                return
            } else {
                // Check if friendUsername is in the business
                let prevGroup: String = self.jobViewTextView.text
                var prevGroupArray = [String]()
                var employeeExist:Bool = false
                prevGroupArray = prevGroup.componentsSeparatedByString(",")
                for employee in prevGroupArray {
                    if(employee == friendUsername) {
                        employeeExist = true
                    }
                }
                if(employeeExist != true) { // Employee is in the business already
                    self.displayOkayAlert("Invalid entry", message: "\(friendUsername!) is not employed in \(business!).")
                    return
                } else {
                    let groupQuery = PFQuery(className: "business")
                    groupQuery.whereKey("username", equalTo: self.currentUser!.username!)
                    groupQuery.whereKey("businessName", equalTo: business!)
                    groupQuery.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error != nil || object == nil {
                            // Error occurred
                            print("Error - remove member from business: \(error!) \(error!.description)")
                        } else {
                            // Group name does not exist under user, create group
                            let prevMembers = object!["members"] as! String
                            let newMembers1:String = prevMembers.stringByReplacingOccurrencesOfString(friendUsername!, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            let newMembers2:String = prevMembers.stringByReplacingOccurrencesOfString(",\(friendUsername!)", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            var newMembers = ""
                            if(newMembers2 == prevMembers) {
                                newMembers = newMembers1
                            } else {
                                newMembers = newMembers2
                            }
                            object!["members"] = newMembers
                            object!.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                if (success) {
                                    print("\(business!) successfully updated.")
                                    self.updateJobTable()
                                    self.jobTableView.reloadData()
                                    self.displayOkayAlert("\(business!) updated", message: "\(friendUsername!) has been removed from \(business!).")
                                    self.jobViewTextView.text = newMembers
                                } else {
                                    print("Error - remove member from business: \(error!) \(error!.description)")
                                }
                            }
                        }
                    }
                }
            }
        }
        alertController.addAction(removeFriend)
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Default) { action -> Void in
            print("Canceled")
        }
        alertController.addAction(cancelAction)
        //Add a text field
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            self.inputTextField = textField
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func newBusinessDidTouch(sender: AnyObject) {
        let alertController: UIAlertController = UIAlertController(title: "New Business", message: "What is the name of your business?", preferredStyle: .Alert)
        let newGroup: UIAlertAction = UIAlertAction(title: "Create", style: .Default) { action -> Void in
            // Check that input is valid
            if(self.groupInputTextField!.text! == "") {
                self.displayOkayAlert("Invalid Entry", message: "Business name cannot be empty.")
                return
            }
            //Check if group exists under user
            let businessName = self.groupInputTextField!.text!
            let businessQuery = PFQuery(className: "business")
            businessQuery.whereKey("username", equalTo: self.currentUser!.username!)
            businessQuery.whereKey("businessName", equalTo: businessName)
            businessQuery.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil || object != nil {
                    // Group name exists under user
                    self.displayOkayAlert("Invalid business name", message: "Each business you create must be unique.")
                } else {
                    // Group name does not exist under user, create group
                    let newBusinessObject = PFObject(className: "business")
                    newBusinessObject["username"] = self.currentUser?.username!
                    newBusinessObject["businessName"] = "\(businessName)"
                    newBusinessObject["members"] = ""
                    let defaultACL = PFACL()
                    defaultACL.publicWriteAccess = true
                    defaultACL.publicReadAccess = true
                    PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
                    newBusinessObject.ACL = defaultACL
                    newBusinessObject.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("\(businessName) successfully created.")
                            self.displayOkayAlert("Business group created", message: "\(businessName) successfully created. Click on it to add friends.")
                            self.businessArray.append((businessItem(businessName: "\(businessName)", members: "")))
                            self.jobTableView.reloadData()
                        } else {
                            print("Error - business: \(error!) \(error!.description)")
                        }
                    }
                }
            }
        }
        alertController.addAction(newGroup)
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Default) { action -> Void in
            print("Canceled")
        }
        alertController.addAction(cancelAction)
        //Add a text field
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            self.groupInputTextField = textField
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func jobViewNotifyDidTouch(sender: AnyObject) {
        let businessName = self.jobViewTitle.text
        let businessQuery = PFQuery(className: "business")
        businessQuery.whereKey("username", equalTo: self.currentUser!.username!)
        businessQuery.whereKey("businessName", equalTo: businessName!)
        businessQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                // Error
                print("Error - jobViewNotifyDidTouch: \(error!) \(error!.description)")
            } else {
                // User found
                // Notify members in business
                let allMembers = object!["members"]
                var membersArray = [String]()
                membersArray = allMembers.componentsSeparatedByString(",")
                for member in membersArray {
                    let memberQuery = PFQuery(className: "rider")
                    memberQuery.whereKey("username", equalTo: member)
                    memberQuery.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error != nil || object == nil {
                            // Group name exists under user
                            print("Error - jobViewNotifyDidTouch: \(error!) \(error!.description)")
                        } else {
                            let prevBusinessJob = object!["businessJob"] as! String
                            var newBusinessJob = ""
                            if(prevBusinessJob == "") {
                                newBusinessJob = "\(self.currentUser!.username!)"
                            } else {
                                newBusinessJob = "\(prevBusinessJob),\(self.currentUser!.username!)"
                            }
                            object!["businessJob"] = newBusinessJob
                            object!.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                if (success) {
                                    print("\(member) businessJob successfully updated.")
                                } else {
                                    print("Error - business: \(error!) \(error!.description)")
                                }
                            }
                        }
                    }
                }
                self.displayOkayAlert("\(businessName!) notified", message: "Employees from \(businessName!) have been notified.")
            }
        }
    }
    
    @IBAction func cancelJobViewDidTouch(sender: AnyObject) {
        self.jobView.hidden = true
        self.jobViewToDim.hidden = true
    }
    
    override func viewDidLoad() {
        self.jobTableView.delegate = self
        self.jobTableView.dataSource = self
        
        if self.revealViewController() != nil {
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            //self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(businessVC.refreshTable(_:)), forControlEvents: .ValueChanged)
        jobTableView.addSubview(refreshControl)
        
        self.jobViewToDim.hidden = true
        self.jobView.hidden = true
        
        self.updateJobTable()
        self.jobTableView.reloadData()
    }
}
