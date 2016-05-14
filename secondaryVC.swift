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
    var pendingList:String = ""
    var pendingArray = [String]()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet weak var newFriendButton: UIButton!

    
    // displayFindFriendAlert
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
            if(friendUsername == self.currentUser?.username!) {
                self.displayOkayAlert("Invalid Entry", message: "Please enter a Fetch account username other than your own.")
                return
            } else {
                let friendQuery = PFQuery(className: "friends")
                friendQuery.whereKey("username", equalTo: friendUsername)
                friendQuery.getFirstObjectInBackgroundWithBlock {
                    (friendObject: PFObject?, error: NSError?) -> Void in
                    if error == nil {
                        if (friendObject != nil) {
                            // friend's username exists
                            // update User's object "pendingTo" in friends class
                            let userQuery = PFQuery(className: "friends")
                            userQuery.whereKey("username", equalTo: self.currentUser!.username!)
                            userQuery.getFirstObjectInBackgroundWithBlock {
                                (userObject: PFObject?, error: NSError?) -> Void in
                                if error == nil {
                                    if (userObject != nil) {
                                        // friend's username exists
                                        // update User's object in friends class
                                        let allFriends = userObject!["friendsList"] as! String
                                        let allFriendsArray = allFriends.componentsSeparatedByString(",")
                                        var friendExists:Bool = false
                                        for friend in allFriendsArray {
                                            if friendUsername == friend {
                                                friendExists = true
                                            }
                                        }
                                        if(friendExists == true) {
                                            self.displayOkayAlert("Invalid Entry", message: "That friend is already on your friend's list.")
                                            return
                                        } else if (friendExists == false) {
                                            if(userObject!["pendingTo"] as! String == "") {
                                                userObject!["pendingTo"] = "\(friendUsername)"
                                            } else {
                                                userObject!["pendingTo"] = "\(userObject!["pendingTo"]),\(friendUsername)"
                                            }
                                            userObject!.saveInBackgroundWithBlock {
                                                (success: Bool, error: NSError?) -> Void in
                                                if (success) {
                                                    self.displayOkayAlert("Friend request sent", message: "Waiting for confirmation from \(friendUsername).")
                                                    //self.updateFriendsTable()
                                                    self.sendOutPendingRequests()
                                                    return
                                                } else {
                                                    print("Error4: \(error!) \(error!.description)")
                                                }
                                            }
                                        }
                                    } else {
                                        self.displayOkayAlert("Error occurred", message: "Please try again later.")
                                        return
                                    }
                                } else {
                                    print("error 11111 \(error)")
                                }
                            }
                        }
                    } else {
                        self.displayOkayAlert("Invalid Entry", message: "Fetch user was not found.")
                    }
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
                                    self.updateFriendsTable()
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
                        self.updateFriendsTable()
                        self.checkForPendingRequests()
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
    
    // displayDeleteFriendAlert
    // Inputs: Title: String, Message: String
    // Output: UIAlertController
    // Function: Displays a UIAlertController with "Yes" "No" buttons to ask the user a "Yes/No" Question.
    // Currently is not being used.
    func sendOutPendingRequests() -> Void {
        if currentUser != nil {
            let userQuery = PFQuery(className: "friends")
            userQuery.whereKey("username", equalTo: (self.currentUser?.username!)!)
            userQuery.getFirstObjectInBackgroundWithBlock {
                (userObject: PFObject?, error: NSError?) -> Void in
                if error != nil || userObject == nil {
                    // Error occured
                    print("Error00: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
                } else {
                    self.pendingList = userObject!["pendingTo"] as! String
                    self.pendingArray = self.pendingList.componentsSeparatedByString(",")
                    for friends in self.pendingArray {
                        print("friends = \(friends)")
                        let friendQuery = PFQuery(className: "friends")
                        friendQuery.whereKey("username", equalTo: friends)
                        friendQuery.getFirstObjectInBackgroundWithBlock {
                            (friendObject: PFObject?, error: NSError?) -> Void in
                            if error != nil || friendObject == nil {
                                // Error occured
                                print("Error01: friends: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
                            } else {
                                if((friendObject!["pendingFrom"] as! String) == "") {
                                    friendObject!["pendingFrom"] = "\(self.currentUser!.username!)"
                                } else {
                                    friendObject!["pendingFrom"] = "\(friendObject!["pendingFrom"]),\(self.currentUser!.username!)"
                                }
                                friendObject!.saveInBackgroundWithBlock {
                                    (success: Bool, error: NSError?) -> Void in
                                    if (success) {
                                        print("friendObject updated")
                                    } else {
                                        print("Error: \(error!) \(error!.description)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
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
        //self.sendOutPendingRequests()
        refreshControl.endRefreshing()
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Sets the numberOfRowsInSection of table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let selectedUsername = friendUsernameArray[indexPath.row]
            let alert = UIAlertController(title: "Delete friend", message: "Are you sure you want to remove \(selectedUsername) from your friend's list?", preferredStyle:  UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                self.friendNameArray.removeAtIndex(indexPath.row)
                self.friendUsernameArray.removeAtIndex(indexPath.row)
                self.friendLevelArray.removeAtIndex(indexPath.row)
                self.friendStatusArray.removeAtIndex(indexPath.row)
                self.friendTableView.reloadData()
                if self.currentUser?.username! != nil {
                    let query = PFQuery(className: "friends")
                    query.whereKey("username", equalTo: (self.currentUser?.username!)!)
                    query.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error != nil || object == nil {
                            // Error occured
                            print("Error11: \(error!) \(error!.description)")
                        } else {
                            let friendList = (object!["friendsList"]) as! String
                            let pendingList = (object!["pendingTo"]) as! String
                            // Search the friendList for selectedUsername and ',selectedUsername'
                            // If ',selectedUsername' was not found then no need to remove the comma
                            // If ',selectedUsername' was found, remove the comma and the selectedUsername
                            // Save newFriendList to object
                            // Do same for pending list
                            let newFriendList1:String = friendList.stringByReplacingOccurrencesOfString(selectedUsername, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            let newFriendList2:String = friendList.stringByReplacingOccurrencesOfString(",\(selectedUsername)", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            let newPendingList1:String = pendingList.stringByReplacingOccurrencesOfString(selectedUsername, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            let newPendingList2:String = pendingList.stringByReplacingOccurrencesOfString(",\(selectedUsername)", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            
                            if(newFriendList2 == friendList) {
                                object!["friendsList"] = newFriendList1
                            } else {
                                object!["friendsList"] = newFriendList2
                            }
                            
                            if(newPendingList2 == pendingList) {
                                object!["pendingTo"] = newPendingList1
                            } else {
                                object!["pendingTo"] = newPendingList2
                            }
                            
                            object!.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                if (success) {
                                    print("\(selectedUsername) has been removed.")
                                } else {
                                    print("Error: \(error!) \(error!.description)")
                                }
                            }
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func updateFriendsTable() -> Void {
        self.friendStatusArray.removeAll()
        self.friendNameArray.removeAll()
        self.friendLevelArray.removeAll()
        self.friendUsernameArray.removeAll()
        if currentUser != nil {
            let userQuery = PFQuery(className: "friends")
            userQuery.whereKey("username", equalTo: currentUser!.username!)
            userQuery.getFirstObjectInBackgroundWithBlock {
                (userObject: PFObject?, error: NSError?) -> Void in
                if error != nil || userObject == nil {
                    // Error occured
                    print("Error: \(error!) \(error!.description)")
                } else {
                    let allFriendsUsernames = userObject!["friendsList"] as! String
                    self.friendUsernameArray = allFriendsUsernames.componentsSeparatedByString(",")
                    for username in self.friendUsernameArray {
                        let query = PFQuery(className: "_User")
                        query.whereKey("username", equalTo: username)
                        query.getFirstObjectInBackgroundWithBlock {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error != nil || object == nil {
                                // Error occured
                                print("Error00: Username: \(username) -- \(error!) \(error!.description)")
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
            }
        }
    }
    
    func checkForPendingRequests() -> Void {
        // Check if user has any pending friend requests
        // If yes, display newFriendButton
        // If not, hide newFriendButton
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
                        self.newFriendButton.hidden = false
                    } else {
                        self.newFriendButton.hidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func addFriendsDidTouch(sender: AnyObject) {
        self.displayFindFriendAlert("Enter Fetch Account username", message: "*Fetch accounts are case-sensitive.")
    }
    
    @IBAction func newFriendDidTouch(sender: AnyObject) {
        self.checkForPendingFriends()
        self.updateFriendsTable()
        self.checkForPendingRequests()
    }
    
    override func viewDidLoad() {
        // Start by hiding newFriendButton
        self.newFriendButton.hidden = true
        
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
        self.friendStatusArray.removeAll()
        self.friendNameArray.removeAll()
        self.friendLevelArray.removeAll()
        self.friendUsernameArray.removeAll()
        self.updateFriendsTable()
        
        // Check if user has any pending friend requests
        self.checkForPendingRequests()
    }
}
// 2 } up
//            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
//                if let currentUser = currentUser as? PFUser {
//                    // Get information from database
//                    let allFriendsUsernames = currentUser["friends"] as! String
//                    self.friendUsernameArray = allFriendsUsernames.componentsSeparatedByString(",")
//                    for username in self.friendUsernameArray {
//                        // 2) Search for user object in "rider" class of database
//                        let query = PFQuery(className: "_User")
//                        query.whereKey("username", equalTo: username)
//                        query.getFirstObjectInBackgroundWithBlock {
//                            (object: PFObject?, error: NSError?) -> Void in
//                            if error != nil || object == nil {
//                                // Error occured
//                                print("Error00: Username: \(username) -- \(error!) \(error!.description)")
//                            } else {
//                                let firstName = object!["firstName"] as! String
//                                let lastName = object!["lastName"] as! String
//                                let fullName = "\(firstName) \(lastName)"
//                                let level = object!["level"] as! String
//                                let status = object!["status"] as! String
//                                if(status == "red") {
//                                    self.friendStatusArray.append(UIImage(named: "redStatus")!)
//                                } else if(status == "green") {
//                                    self.friendStatusArray.append(UIImage(named: "greenStatus")!)
//                                } else {
//                                    self.friendStatusArray.append(UIImage(named: "greyStatus")!)
//                                }
//                                self.friendNameArray.append(fullName)
//                                self.friendLevelArray.append("Level \(level)")
//                                self.friendTableView.reloadData()
//                                print(self.friendNameArray[0])
//                            }
//                        }
//                        
//                    }
//                }
//            })

