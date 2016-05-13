//
//  secondaryVC.swift
//  FetchAppV3
//
//  Created by Jonathan Tan on 5/12/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import Parse

class secondaryVC: UIViewController {
    var currentUser = PFUser.currentUser()
    var friendNameArray = [String]()
    var friendUsernameArray = [String]()
    var friendLevelArray = [String]()
    var friendStatusArray = [UIImage]()
    var userFriend:String?
    var inputTextField: UITextField?
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var friendTableView: UITableView!

    
    // displayYesNoAlert
    // Inputs: Title: String, Message: String
    // Output: UIAlertController
    // Function: Displays a UIAlertController with "Yes" "No" buttons to ask the user a "Yes/No" Question.
    // Currently is not being used.
    func displayFindFriendAlert(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let addFriend: UIAlertAction = UIAlertAction(title: "Add", style: .Default) { action -> Void in
            //Check if username exists
            if(self.inputTextField!.text! == "") {
                self.displayOkayAlert("Invalid Entry", message: "Must specify a Fetch account username to add to friend's list.")
                return
            }
            let friendUsername = self.inputTextField!.text!
            let query = PFQuery(className: "_User")
            query.whereKey("username", equalTo: friendUsername)
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    if (objects!.count > 0) {
                        PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                            if let currentUser = currentUser as? PFUser {
                                currentUser["friends"] = "\(currentUser["friends"]),\(friendUsername)"
                                currentUser.saveInBackgroundWithBlock {
                                    (success: Bool, error: NSError?) -> Void in
                                    if (success) {
                                        self.displayOkayAlert("Friend Added", message: "\(friendUsername) has been added to your friend's list.")
                                        self.updateFriendsList()
                                        self.friendTableView.reloadData()
                                        return
                                    } else {
                                        print("Error: \(error!) \(error!.description)")
                                    }
                                }
                            }
                        })
                    } else {
                        self.displayOkayAlert("Invalid Entry", message: "Fetch user was not found.")
                        return
                    }
                } else {
                    print(error)
                }
            }
        }
        alertController.addAction(addFriend)
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            print("Canceled")
        }
        alertController.addAction(cancelAction)
        //Add a text field
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            self.inputTextField = textField
        }
        self.presentViewController(alertController, animated: true, completion: nil)
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
    
    // refresh
    // Input: UIRefreshControl
    // Output: None
    // Function: Function for refreshing the tableview
    func refresh(refreshControl: UIRefreshControl) {
        self.friendTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Sets the numberOfRowsInSection of table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count = \(friendNameArray.count)")
        return friendNameArray.count
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Updates the tableView cell with information
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let friendCell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! friendsCell
        friendCell.name.text = friendNameArray[indexPath.row]
        friendCell.level.text = friendLevelArray[indexPath.row]
        friendCell.status.image = friendStatusArray[indexPath.row]
        return friendCell
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Indicates what happens when a user selects a cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected cell")
        // do select for driver
    }
    
    func updateFriendsList() -> Void {
        self.friendStatusArray.removeAll()
        self.friendNameArray.removeAll()
        self.friendLevelArray.removeAll()
        self.friendUsernameArray.removeAll()
        if currentUser != nil {
            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                if let currentUser = currentUser as? PFUser {
                    // Get information from database
                    let allFriendsUsernames = currentUser["friends"] as! String
                    self.friendUsernameArray = allFriendsUsernames.componentsSeparatedByString(",")
                    for username in self.friendUsernameArray {
                        // 2) Search for user object in "rider" class of database
                        let query = PFQuery(className: "_User")
                        query.whereKey("username", equalTo: username)
                        query.getFirstObjectInBackgroundWithBlock {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error != nil || object == nil {
                                // Error occured
                                print("Error: \(error!) \(error!.description)")
                            } else {
                                let firstName = object!["firstName"] as! String
                                let lastName = object!["lastName"] as! String
                                let fullName = "\(firstName) \(lastName)"
                                let level = object!["level"] as! String
                                let status = object!["status"] as! String
                                if(status == "red") {
                                    self.friendStatusArray.append(UIImage(named: "redStatus")!)
                                } else if(status == "green") {
                                    self.friendStatusArray.append(UIImage(named: "greenStatus")!)
                                } else {
                                    self.friendStatusArray.append(UIImage(named: "greyStatus")!)
                                }
                                self.friendNameArray.append(fullName)
                                self.friendLevelArray.append("Level \(level)")
                                self.friendTableView.reloadData()
                                print(self.friendNameArray[0])
                            }
                        }
                        
                    }
                }
            })
            
        }
    }
    
    @IBAction func addFriendsDidTouch(sender: AnyObject) {
        self.displayFindFriendAlert("Enter Fetch Account username", message: "*Fetch accounts are case-sensitive.")
    }
    
    override func viewDidLoad() {
        // Add menu button action
        if self.revealViewController() != nil {
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        // Add refresh action to driverTableView
        // Pull down to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(mainVC.refresh(_:)), forControlEvents: .ValueChanged)
        friendTableView.addSubview(refreshControl)
        
        // Populate friend's table
        if currentUser != nil {
            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                if let currentUser = currentUser as? PFUser {
                    // Get information from database
                    let allFriendsUsernames = currentUser["friends"] as! String
                    self.friendUsernameArray = allFriendsUsernames.componentsSeparatedByString(",")
                    for username in self.friendUsernameArray {
                        // 2) Search for user object in "rider" class of database
                        let query = PFQuery(className: "_User")
                        query.whereKey("username", equalTo: username)
                        query.getFirstObjectInBackgroundWithBlock {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error != nil || object == nil {
                                // Error occured
                                print("Error: \(error!) \(error!.description)")
                            } else {
                                let firstName = object!["firstName"] as! String
                                let lastName = object!["lastName"] as! String
                                let fullName = "\(firstName) \(lastName)"
                                let level = object!["level"] as! String
                                let status = object!["status"] as! String
                                if(status == "red") {
                                    self.friendStatusArray.append(UIImage(named: "redStatus")!)
                                } else if(status == "green") {
                                    self.friendStatusArray.append(UIImage(named: "greenStatus")!)
                                } else {
                                    self.friendStatusArray.append(UIImage(named: "greyStatus")!)
                                }
                                self.friendNameArray.append(fullName)
                                self.friendLevelArray.append("Level \(level)")
                                self.friendTableView.reloadData()
                                print(self.friendNameArray[0])
                            }
                        }
                        
                    }
                }
            })
            
        }
    }
    
}
