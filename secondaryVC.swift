//
//  secondaryVC.swift
//  FetchAppV3
//
//  Created by Jonathan Tan on 5/12/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

struct rankItem {
    var fullName: String
    var username: String
    var level: String
    var experience: String
    var profilePic: UIImage
}

struct groupItem {
    var groupName: String
    var members: String
}

struct friendItem {
    var fullName: String
    var username: String
    var level: String
    var status: String
    var statusImage: UIImage
    var profilePic: UIImage
}

class secondaryVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    var currentUser = PFUser.currentUser()
    var friendArray = [friendItem]()
//    var friendNameArray = [String]()
    var friendUsernameArray = [String]()
//    var friendLevelArray = [String]()
//    var friendStatusArray = [String]()
//    var friendStatusImageArray = [UIImage]()
//    var friendProfilePicArray = [UIImage]()
//    var rankNameArray = [String]()
    var rankUsernameArray = [String]()
//    var rankLevelArray = [String]()
    var userFriend:String?
    var inputTextField: UITextField?
    var groupInputTextField: UITextField?
    var pendingList:String = ""
    var pendingArray = [String]()
    var userLocationLAT:Double = 0
    var userLocationLONG:Double = 0
    var locationManager = CLLocationManager()
    var rankArray = [rankItem]()
    var groupArray = [groupItem]()
    var viewSelect:Int = 0 // 0 = friendListView, 1 = rankingView, 2 = editProfile
    var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var friendListView: UIView!
    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet weak var newFriendButton: UIButton!
    @IBOutlet weak var activeRequestView: UIView!
    @IBOutlet weak var requestFullName: UILabel!
    @IBOutlet weak var requestUsername: UILabel!
    @IBOutlet weak var requestPickupAddress: UITextView!
    @IBOutlet weak var requestDropoffAddress: UITextView!
    @IBOutlet weak var requestDistance: UILabel!
    @IBOutlet weak var requestUserPic: UIImageView!
    @IBOutlet weak var friendListViewToDim: UIView!
    @IBOutlet weak var inactiveRequestView: UIView!
    @IBOutlet weak var inactiveRequestImage: UIImageView!
    @IBOutlet weak var inactiveRequestFullName: UILabel!
    @IBOutlet weak var inactiveRequestUsername: UILabel!
    @IBOutlet weak var inactiveRequestLevel: UILabel!
    @IBOutlet weak var rankingTableView: UITableView!
    @IBOutlet weak var rankViewToDim: UIView!
    @IBOutlet weak var rankViewRank: UILabel!
    @IBOutlet weak var rankViewFullName: UILabel!
    @IBOutlet weak var rankViewUsername: UILabel!
    @IBOutlet weak var rankViewLevel: UILabel!
    @IBOutlet weak var rankViewProfilePic: UIImageView!
    @IBOutlet weak var rankingView: UIView!
    @IBOutlet weak var rankingSelectedUserView: UIView!
    @IBOutlet weak var rankingViewExperience: UILabel!
    @IBOutlet weak var editProfileImage: UIImageView!
    @IBOutlet weak var editProfileFirstName: UITextField!
    @IBOutlet weak var editProfileLastName: UITextField!
    @IBOutlet weak var editProfilePhoneNumber: UITextField!
    @IBOutlet weak var editProfileEmailAddress: UITextField!
    @IBOutlet weak var editProfileView: UIView!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var groupViewName: UILabel!
    @IBOutlet weak var groupViewMembers: UITextView!
    @IBOutlet weak var groupViewInput: UITextField!
    @IBOutlet weak var groupViewToDim: UIView!
    @IBOutlet weak var groupViewPopup: UIView!

    
    // Inputs: None
    // Outputs; None
    // Function: Dismisses the keyboard
    func DismissKeyboard() {
        view.endEditing(true)
    }
    
    // textFieldShouldReturn()
    // Add's done button to textfield
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func cancelNumberPad() {
        self.editProfilePhoneNumber.resignFirstResponder()
        self.editProfilePhoneNumber.text = ""
    }
    
    func doneWithNumberPad() {
        self.editProfilePhoneNumber.resignFirstResponder()
    }
    
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
//        if (touch.view == self.friendTableView || touch.view == self.rankingTableView || touch.view == self.groupTableView) {
//            return false
//        }
//        return true
//    }
    
    // displayFindFriendAlert
    // Inputs: Title: String, Message: String
    // Output: UIAlertController
    // Function: Displays a UIAlertController with input text capabilities which searches the database for the inputted username and handles.
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
    
    func setupEditProfile() -> Void {
        PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
            if let currentUser = currentUser as? PFUser {
                let firstName = currentUser["firstName"] as! String
                let lastName = currentUser["lastName"] as! String
                let phoneNumber = currentUser["phoneNumber"] as! String
                let profilePicData = currentUser["profilePic"] as! PFFile
                profilePicData.getDataInBackgroundWithBlock({
                    (imageData: NSData?, error: NSError?) -> Void in
                    if (error == nil) {
                        let profilePic = UIImage(data:imageData!)
                        self.editProfileImage.image = profilePic
                    }
                })
                let emailAddress = currentUser.email
                self.editProfileFirstName.text = firstName
                self.editProfileLastName.text = lastName
                self.editProfilePhoneNumber.text = phoneNumber
                self.editProfileEmailAddress.text = emailAddress
            } else {
                self.displayOkayAlert("Error", message: "An error occurred while obtaining your information from the database. Please reload the page.")
                self.editProfileFirstName.text = ""
                self.editProfileLastName.text = ""
                self.editProfilePhoneNumber.text = ""
                self.editProfileEmailAddress.text = ""
                self.editProfileImage.image = UIImage(named: "gender_neutral_user")
            }
        })
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
//    func animateDropDownToFrame(frame: CGRect, completion:() -> Void) {
//        if (!self.isAnimating) {
//            self.isAnimating = true
//            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
//                
//                self.dropDownGroup.frame = frame
//                
//                }, completion: { (completed: Bool) -> Void in
//                    self.isAnimating = false
//                    if (completed) {
//                        completion()
//                    }
//            })
//        }
//    }
    
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
    func refreshFriendsTable(refreshControl: UIRefreshControl) {
        self.updateFriendsTable()
        self.friendTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // refresh
    // Input: UIRefreshControl
    // Output: None
    // Function: Function for refreshing the tableview
    func refreshRankingTable(refreshControl: UIRefreshControl) {
        self.updateRankingTable()
        self.rankingTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // refresh
    // Input: UIRefreshControl
    // Output: None
    // Function: Function for refreshing the tableview
    func refreshGroupTable(refreshControl: UIRefreshControl) {
        self.updateGroupTable()
        self.groupTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Sets the numberOfRowsInSection of table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.friendTableView) {
            return friendArray.count
        } else if (tableView == self.rankingTableView) {
            print(rankArray.count)
            return rankArray.count
        } else {
            return groupArray.count
        }
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Updates the tableView cell with information
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == self.friendTableView) {
            let friendCell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! friendsCell
            friendCell.name.text = self.friendArray[indexPath.row].fullName
            friendCell.level.text = self.friendArray[indexPath.row].level
            friendCell.status.image = self.friendArray[indexPath.row].statusImage
            friendCell.profilePic.image = self.friendArray[indexPath.row].profilePic
            return friendCell
        } else if (tableView == self.rankingTableView) {
            let rankCell = tableView.dequeueReusableCellWithIdentifier("rankingCell", forIndexPath: indexPath) as! rankingsCell
            rankCell.fullName.text = self.rankArray[indexPath.row].fullName
            rankCell.level.text = "Level \(self.rankArray[indexPath.row].level)"
            rankCell.rank.text = "\(indexPath.row + 1)"
            rankCell.profilePic.image = self.rankArray[indexPath.row].profilePic
            return rankCell
        } else {
            let cellIdentifier: String = self.groupArray[indexPath.row].groupName
            let groupCell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as! UITableViewCell
            groupCell.textLabel!.text = cellIdentifier
            return groupCell
        }
    }
    
    // Name: tableView
    // Inputs: None
    // Outputs: None
    // Function: Indicates what happens when a user selects a cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected cell")
        if(tableView == self.friendTableView) {
            if(self.friendArray[indexPath.row].status == "red") {
                self.requestFullName.text = self.friendArray[indexPath.row].fullName
                self.requestUsername.text = self.friendArray[indexPath.row].username
                self.requestUserPic.image = self.friendArray[indexPath.row].profilePic
                let userQuery = PFQuery(className: "rider")
                userQuery.whereKey("username", equalTo: self.friendArray[indexPath.row].username)
                userQuery.getFirstObjectInBackgroundWithBlock {
                    (userObject: PFObject?, error: NSError?) -> Void in
                    if error != nil || userObject == nil {
                        // Error occured
                        print("Error15: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
                    } else {
                        let pickupAddress = userObject!["pickupAddress"] as! String
                        let dropoffAddress = userObject!["dropoffAddress"] as! String
                        let distance = userObject!["distance"] as! String
                        self.requestPickupAddress.text = pickupAddress
                        self.requestDropoffAddress.text = dropoffAddress
                        self.requestDistance.text = "Approximate distance: \(distance) miles"
                        self.friendListViewToDim.hidden = false
                        self.activeRequestView.hidden = false
                    }
                }
            } else {
                self.inactiveRequestFullName.text = self.friendArray[indexPath.row].fullName
                self.inactiveRequestUsername.text = self.friendArray[indexPath.row].username
                self.inactiveRequestLevel.text = self.friendArray[indexPath.row].level
                self.inactiveRequestImage.image = self.friendArray[indexPath.row].profilePic
                self.friendListViewToDim.hidden = false
                self.inactiveRequestView.hidden = false
            }
        } else if (tableView == self.rankingTableView) {
            self.rankViewFullName.text = self.rankArray[indexPath.row].fullName
            self.rankViewLevel.text = "Level \(self.rankArray[indexPath.row].level)"
            self.rankViewUsername.text = self.rankArray[indexPath.row].username
            self.rankViewRank.text = "Rank \(indexPath.row + 1)"
            let experience = Double("\(self.rankArray[indexPath.row].experience)")
            let realExperience = Double(round(10*(experience!)/10))
            self.rankingViewExperience.text = "Total experience: \(realExperience)"
            self.rankViewProfilePic.image = self.rankArray[indexPath.row].profilePic
            self.rankViewToDim.hidden = false
            self.rankingSelectedUserView.hidden = false
        } else if (tableView == self.groupTableView) { //Tableview == groupTableView
            if(indexPath.row == 0) {
                self.updateFriendsTable()
                self.groupView.hidden = true
            } else {
                self.groupViewName.text = self.groupArray[indexPath.row].groupName
                self.groupViewMembers.text = self.groupArray[indexPath.row].members
                self.groupViewToDim.hidden = false
                self.groupViewPopup.hidden = false
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if(tableView == self.friendTableView) {
            return true
        } else if (tableView == self.groupTableView && indexPath.row != 0) {
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView == self.friendTableView) {
            if (editingStyle == UITableViewCellEditingStyle.Delete) {
                // handle delete (by removing the data from your array and updating the tableview)
                let selectedUsername = friendUsernameArray[indexPath.row]
                let alert = UIAlertController(title: "Delete friend", message: "Are you sure you want to remove \(selectedUsername) from your friend's list?", preferredStyle:  UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    self.friendArray.removeAtIndex(indexPath.row)
//                    self.friendNameArray.removeAtIndex(indexPath.row)
                    self.friendUsernameArray.removeAtIndex(indexPath.row)
//                    self.friendLevelArray.removeAtIndex(indexPath.row)
//                    self.friendStatusArray.removeAtIndex(indexPath.row)
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
        } else { // Group tableView
            let groupName = groupArray[indexPath.row].groupName
            let groupQuery = PFQuery(className: "groups")
            groupQuery.whereKey("username", equalTo: self.currentUser!.username!)
            groupQuery.whereKey("groupName", equalTo: groupName)
            groupQuery.getFirstObjectInBackgroundWithBlock {
                (groupObject: PFObject?, error: NSError?) -> Void in
                if (error == nil) {
                    groupObject?.deleteInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("group deleted")
                            self.groupArray.removeAtIndex(indexPath.row)
                            self.updateGroupTable()
                            self.groupTableView.reloadData()
                        } else {
                            print("Error with deleting group: \(error!) \(error!.description)")
                        }
                    }
                }
            }
        }
    }
    
    func updateFriendsTable() -> Void {
        self.friendArray.removeAll()
//        self.friendStatusArray.removeAll()
//        self.friendStatusImageArray.removeAll()
//        self.friendNameArray.removeAll()
//        self.friendLevelArray.removeAll()
//        self.friendUsernameArray.removeAll()
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
                                let profilePicData = object!["profilePic"] as! PFFile
                                let firstName = object!["firstName"] as! String
                                let lastName = object!["lastName"] as! String
                                let fullName = "\(firstName) \(lastName)"
                                let level = object!["level"] as! String
                                let status = object!["status"] as! String
                                profilePicData.getDataInBackgroundWithBlock({
                                    (imageData: NSData?, error: NSError?) -> Void in
                                    if (error == nil) {
                                        let profilePic = UIImage(data:imageData!)
//                                        self.friendProfilePicArray.append(profilePic!)
                                        if(status == "red") {
                                            self.friendArray.append(friendItem(fullName: fullName, username: username, level: "Level \(level)", status: status, statusImage: UIImage(named: "redStatus")!, profilePic: profilePic!))
                                            
//                                            self.friendStatusImageArray.append(UIImage(named: "redStatus")!)
                                        } else if(status == "green") {
                                            self.friendArray.append(friendItem(fullName: fullName, username: username, level: "Level \(level)", status: status, statusImage: UIImage(named: "greenStatus")!, profilePic: profilePic!))
//                                            self.friendStatusImageArray.append(UIImage(named: "greenStatus")!)
                                        } else {
                                            self.friendArray.append(friendItem(fullName: fullName, username: username, level: "Level \(level)", status: status, statusImage: UIImage(named: "greyStatus")!, profilePic: profilePic!))
//                                            self.friendStatusImageArray.append(UIImage(named: "greyStatus")!)
                                        }
//                                        self.friendNameArray.append(fullName)
//                                        self.friendLevelArray.append("Level \(level)")
//                                        self.friendStatusArray.append(status)
                                        self.friendTableView.reloadData()
//                                        print(self.friendNameArray[0])
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateRankingTable() -> Void {
//        self.rankNameArray.removeAll()
//        self.rankLevelArray.removeAll()
//        self.rankUsernameArray.removeAll()
        self.rankArray.removeAll()
        
        // Add user to ranking
        if currentUser != nil {
            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                if let currentUser = currentUser as? PFUser {
                    let firstName = currentUser["firstName"] as! String
                    let lastName = currentUser["lastName"] as! String
                    let userExperience = currentUser["experience"] as! String
                    let userFullName = "\(firstName) \(lastName)"
                    let userLevel = currentUser["level"] as! String
                    let profilePicData = currentUser["profilePic"] as! PFFile
                    profilePicData.getDataInBackgroundWithBlock({
                        (imageData: NSData?, error: NSError?) -> Void in
                        if (error == nil) {
                            let profilePic = UIImage(data:imageData!)
                            self.rankArray.append(rankItem(fullName: "\(userFullName)", username: "\(self.currentUser!.username!)", level: "\(userLevel)", experience: "\(userExperience)", profilePic: profilePic!))
                            print(firstName)
                            // Now sort the array
                            let result = self.rankArray.sortInPlace {
                                switch ($0.level,$1.level) {
                                // if neither “category" is nil and contents are equal,
                                case let (lhs,rhs) where lhs == rhs:
                                    // compare “status” (> because DESC order)
                                    return $0.experience > $1.experience
                                // else just compare “category” using <
                                case let (lhs, rhs):
                                    return lhs > rhs
                                }
                            }
                            self.rankingTableView.reloadData()
                        }
                    })
                }
            })
            
            // Add friends
            let userQuery = PFQuery(className: "friends")
            userQuery.whereKey("username", equalTo: currentUser!.username!)
            userQuery.getFirstObjectInBackgroundWithBlock {
                (userObject: PFObject?, error: NSError?) -> Void in
                if error != nil || userObject == nil {
                    // Error occured
                    print("Error: \(error!) \(error!.description)")
                } else {
                    let allFriendsUsernames = userObject!["friendsList"] as! String
                    self.rankUsernameArray = allFriendsUsernames.componentsSeparatedByString(",")
                    for friendusername in self.rankUsernameArray {
                        let query = PFQuery(className: "_User")
                        query.whereKey("username", equalTo: friendusername)
                        query.getFirstObjectInBackgroundWithBlock {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error != nil || object == nil {
                                // Error occured
                                print("Error00: Username: \(friendusername) -- \(error!) \(error!.description)")
                            } else {
                                let firstName = object!["firstName"] as! String
                                let lastName = object!["lastName"] as! String
                                let friendexperience = object!["experience"] as! String
                                let friendfullName = "\(firstName) \(lastName)"
                                let friendlevel = object!["level"] as! String
                                let profilePicData = object!["profilePic"] as! PFFile
                                profilePicData.getDataInBackgroundWithBlock({
                                    (imageData: NSData?, error: NSError?) -> Void in
                                    if (error == nil) {
                                        let profilePic = UIImage(data:imageData!)
                                        self.rankArray.append(rankItem(fullName: "\(friendfullName)", username: "\(friendusername)", level: "\(friendlevel)", experience: "\(friendexperience)", profilePic: profilePic!))
                                        print(firstName)
                                        // Now sort the array
                                        let result = self.rankArray.sortInPlace {
                                            switch ($0.level,$1.level) {
                                            // if neither “category" is nil and contents are equal,
                                            case let (lhs,rhs) where lhs == rhs:
                                                // compare “status” (> because DESC order)
                                                return $0.experience > $1.experience
                                            // else just compare “category” using <
                                            case let (lhs, rhs):
                                                return lhs > rhs
                                            }
                                        }
                                        self.rankingTableView.reloadData()
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateGroupTable() -> Void {
        self.groupArray.removeAll()
        self.groupArray.append(groupItem(groupName: "All friends", members: ""))
        if (currentUser != nil) {
            let groupQuery = PFQuery(className: "groups")
            groupQuery.whereKey("username", equalTo: self.currentUser!.username!)
            groupQuery.findObjectsInBackgroundWithBlock {
                (groupObjects: [PFObject]?, error: NSError?) -> Void in
                if error == nil && groupObjects != nil {
                    // Search succeeded
                    if let groupObjects = groupObjects {
                        for group in groupObjects {
                            let groupName = group["groupName"] as! String
                            let groupMembers = group["members"] as! String
                            self.groupArray.append(groupItem(groupName: groupName, members: groupMembers))
                            self.groupTableView.reloadData()
                        }
                    }
                } else {
                    print("Error updateGroupTable: \(error!) \(error!.description)")
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // Get user's current location in latitude and longitude
        let location = locations.last! as CLLocation
        self.userLocationLAT = location.coordinate.latitude
        self.userLocationLONG = location.coordinate.longitude
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
                        print("Error: \(error!) \(error!.description)")
                    }
                }
            }
        })
        self.locationManager.stopUpdatingLocation()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.editProfileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addFriendsDidTouch(sender: AnyObject) {
        self.displayFindFriendAlert("Enter Fetch Account username", message: "*Fetch accounts are case-sensitive.")
    }
    
    @IBAction func newFriendDidTouch(sender: AnyObject) {
        self.checkForPendingFriends()
        self.updateFriendsTable()
        self.checkForPendingRequests()
    }
   
    // If user taps to accept friend's ride request
    @IBAction func acceptFriendRequestDidTouch(sender: AnyObject) {
        print("accepted")
        let friendUser:String = self.requestUsername.text!
        let userQuery = PFQuery(className: "rider")
        userQuery.whereKey("username", equalTo: self.currentUser!.username!)
        userQuery.getFirstObjectInBackgroundWithBlock {
            (userObject: PFObject?, error: NSError?) -> Void in
            if error != nil || userObject == nil {
                // Error occured
                print("Error17 - acceptFriendRequestDidTouch: \(error!) \(error!.description)")
            } else {
                // Check if user has an active ride request
                // If yes, displayOkayAlert that user cannot take on a ride request while having an active request
                // If no, check if user is already on friend's pending driver's list
                if((userObject!["status"] as! String) != "Waiting for user.") {
                    self.displayOkayAlert("Job pending", message: "You cannot take on a ride request while you have an active request.")
                } else {
                    // User does not have a active ride request, check if user is already on friend's pending driver's list
                    // If yes, displayOkayAlert that user already accepted their friend's request
                    // If no, add user to friend's pending driver list
                    let friendQuery = PFQuery(className: "rider")
                    friendQuery.whereKey("username", equalTo: friendUser)
                    friendQuery.getFirstObjectInBackgroundWithBlock {
                        (friendObject: PFObject?, error: NSError?) -> Void in
                        if error != nil || friendObject == nil {
                            // Error occured
                            print("Error16: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
                        } else {
                            var pendingDriver = friendObject!["pendingDriver"] as! String
                            if pendingDriver.rangeOfString("\(self.currentUser!.username!)") != nil{
                                print("user exists in their pending already")
                                self.displayOkayAlert("Error", message: "You already accepted \(friendUser)'s request.")
                            } else {
                                if(pendingDriver == "") {
                                    pendingDriver = "\(self.currentUser!.username!)"
                                } else {
                                    pendingDriver = "\(pendingDriver),\(self.currentUser!.username!)"
                                }
                                friendObject!["pendingDriver"] = pendingDriver
                                friendObject!.saveInBackgroundWithBlock {
                                    (success: Bool, error: NSError?) -> Void in
                                    if (success) {
                                        print("Friend's pending drivers has been updated.")
                                        self.displayOkayAlert("Request sent", message: "You accepted \(friendUser)'s request. Please wait for their confirmation.")
                                        self.friendListViewToDim.hidden = true
                                        self.activeRequestView.hidden = true
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
    
    // If user taps to cancel accepting friend's ride request
    @IBAction func cancelFriendRequestDidTouch(sender: AnyObject) {
        let friendUser:String = self.requestUsername.text!
        let userQuery = PFQuery(className: "rider")
        userQuery.whereKey("username", equalTo: friendUser)
        userQuery.getFirstObjectInBackgroundWithBlock {
            (friendObject: PFObject?, error: NSError?) -> Void in
            if error != nil || friendObject == nil {
                // Error occured
                print("Error17: Username: \((self.currentUser?.username!)!) -- \(error!) \(error!.description)")
            } else {
                let pendingDriver = friendObject!["pendingDriver"] as! String
                if ((pendingDriver == "") || (pendingDriver.rangeOfString("\(self.currentUser!.username!)") == nil)) {
                    print("user does not exist in the friend's pending already")
                    self.displayOkayAlert("Error", message: "You never accepted \(friendUser)'s request.")
                } else {
                    let newPendingDriver1:String = pendingDriver.stringByReplacingOccurrencesOfString((self.currentUser!.username!), withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    let newPendingDriver2:String = pendingDriver.stringByReplacingOccurrencesOfString(",\(self.currentUser!.username!)", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                    if(newPendingDriver2 == pendingDriver) {
                        friendObject!["pendingDriver"] = newPendingDriver1
                    } else {
                        friendObject!["pendingDriver"] = newPendingDriver2
                    }
                    friendObject!.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("Friend's pending drivers has been updated.")
                            self.locationManager.delegate = self
                            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                            self.locationManager.requestAlwaysAuthorization()
                            self.locationManager.startUpdatingLocation()
                            self.displayOkayAlert("Request cancelled", message: "You are no longer pending for \(friendUser)'s request.")
                            self.friendListViewToDim.hidden = true
                            self.activeRequestView.hidden = true
                        } else {
                            print("Error: \(error!) \(error!.description)")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func activeRequestCloseDidTouch(sender: AnyObject) {
        self.friendListViewToDim.hidden = true
        self.activeRequestView.hidden = true
    }
    
    @IBAction func cancelInactiveRequestDidTouch(sender: AnyObject) {
        self.friendListViewToDim.hidden = true
        self.inactiveRequestView.hidden = true
    }
    
    @IBAction func cancelRankViewDidTouch(sender: AnyObject) {
        self.rankViewToDim.hidden =  true
        self.rankingSelectedUserView.hidden = true
    }
    
    @IBAction func editProfilePicDidTouch(sender: AnyObject) {
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveProfileDidTouch(sender: AnyObject) {
        if(self.editProfileEmailAddress.text == "" || self.editProfilePhoneNumber.text == "" || self.editProfileLastName.text == "" || self.editProfileFirstName.text == "") {
            self.displayOkayAlert("Missing Information", message: "None of your profile information can be left blank.")
            return
        }
        PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
            if let currentUser = currentUser as? PFUser {
                let imageData: NSData = UIImageJPEGRepresentation(self.editProfileImage.image!, 0.5)!
                let profilePic: PFFile = PFFile(name: "profile.png", data: imageData)!
                currentUser["firstName"] = self.editProfileFirstName.text
                currentUser["lastName"] = self.editProfileLastName.text
                currentUser["phoneNumber"] = self.editProfilePhoneNumber.text
                currentUser.email = self.editProfileEmailAddress.text
                currentUser["profilePic"] = profilePic
                currentUser.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("Successfuly updated profile.")
                        self.displayOkayAlert("Update successful", message: "Your profile has been successfuly updated.")
                    } else {
                        print("Error - saveProfileDidTouch: \(error!) \(error!.description)")
                    }
                }
            }
        })
    }
    
    @IBAction func showGroupsDidTouch(sender: AnyObject) {
        if(self.groupView.hidden == false) {
            self.groupView.hidden = true
        } else {
            self.groupView.hidden = false
        }
    }
    
    @IBAction func createNewGroupDidTouch(sender: AnyObject) {
        let alertController: UIAlertController = UIAlertController(title: "New Group", message: "What would you like to name this group?", preferredStyle: .Alert)
        let newGroup: UIAlertAction = UIAlertAction(title: "Create", style: .Default) { action -> Void in
            // Check that input is valid
            if(self.groupInputTextField!.text! == "") {
                self.displayOkayAlert("Invalid Entry", message: "Group name cannot be empty.")
                return
            }
            
            //Check if group exists under user
            let groupName = self.groupInputTextField!.text!
            let groupQuery = PFQuery(className: "groups")
            groupQuery.whereKey("username", equalTo: self.currentUser!.username!)
            groupQuery.whereKey("groupName", equalTo: groupName)
            groupQuery.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil || object != nil {
                    // Group name exists under user
                    self.displayOkayAlert("Invalid group name", message: "Each group you create must be unique.")
                } else {
                    // Group name does not exist under user, create group
                    let newGroupObject = PFObject(className: "groups")
                    newGroupObject["username"] = self.currentUser?.username!
                    newGroupObject["groupName"] = "\(groupName)"
                    newGroupObject["members"] = ""
                    let defaultACL = PFACL()
                    defaultACL.publicWriteAccess = true
                    defaultACL.publicReadAccess = true
                    PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
                    newGroupObject.ACL = defaultACL
                    newGroupObject.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("\(groupName) successfully created.")
                            self.displayOkayAlert("Group created", message: "\(groupName) successfully created. Click on it to add friends.")
                            self.groupArray.append((groupItem(groupName: "\(groupName)", members: "")))
                            self.groupTableView.reloadData()
                        } else {
                            print("Error - groups: \(error!) \(error!.description)")
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
    
    @IBAction func groupViewAddDidTouch(sender: AnyObject) {
        if(self.groupViewInput.text == "") {
            self.displayOkayAlert("Missing field", message: "You must specify a FetchApp account username to add or delete friends from a group.")
            return
        }
        let inputFriendUsername = self.groupViewInput.text
        let groupName = self.groupViewName.text
        // Check if inputFriendUsername exists in group already
        let prevFriend:String = self.groupViewMembers.text
        var prevFriendArray = [String]()
        var friendExist:Bool = false
        prevFriendArray = prevFriend.componentsSeparatedByString(",")
        for friend in prevFriendArray {
            if(friend == inputFriendUsername) {
                friendExist = true
            }
        }
        if(friendExist == true) {
            self.displayOkayAlert("Error", message: "\(inputFriendUsername!) already exists in \(groupName!).")
            return
        } else {
            // Check if inputFriendUsername is on friend's list
            var friendExist2:Bool = false
            let userQuery = PFQuery(className: "friends")
            userQuery.whereKey("username", equalTo: self.currentUser!.username!)
            userQuery.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error != nil || object == nil {
                    // Error occurred
                    print("Error userQuery - add member to groups: \(error!) \(error!.description)")
                } else {
                    // Success
                    let allFriends = object!["friendsList"]
                    var allFriendsArray = [String]()
                    allFriendsArray = allFriends.componentsSeparatedByString(",")
                    for friend in allFriendsArray {
                        if(friend == inputFriendUsername) {
                            friendExist2 = true
                        }
                    }
                    if(friendExist2 == false) {
                        self.displayOkayAlert("Error", message: "\(inputFriendUsername!) does not exist on your friend's list. Add them to your friend's list first in order to place them in a group.")
                    } else {
                        let groupQuery = PFQuery(className: "groups")
                        groupQuery.whereKey("username", equalTo: self.currentUser!.username!)
                        groupQuery.whereKey("groupName", equalTo: groupName!)
                        groupQuery.getFirstObjectInBackgroundWithBlock {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error != nil || object == nil {
                                // Error occurred
                                print("Error - add member to groups: \(error!) \(error!.description)")
                            } else {
                                // Group name does not exist under user, create group
                                let prevMembers = object!["members"] as! String
                                var newMembers = ""
                                if(prevMembers == "") {
                                    newMembers = "\(inputFriendUsername!)"
                                } else {
                                    newMembers = "\(prevMembers),\(inputFriendUsername!)"
                                }
                                object!["members"] = newMembers
                                object!.saveInBackgroundWithBlock {
                                    (success: Bool, error: NSError?) -> Void in
                                    if (success) {
                                        print("\(groupName) successfully updated.")
                                        self.updateGroupTable()
                                        self.groupTableView.reloadData()
                                        self.displayOkayAlert("\(groupName!) updated", message: "\(inputFriendUsername!) has been added to \(groupName!).")
                                        self.groupViewMembers.text = newMembers
                                    } else {
                                        print("Error - add member to groups: \(error!) \(error!.description)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func groupViewRemoveDidTouch(sender: AnyObject) {
        if(self.groupViewInput.text == "") {
            self.displayOkayAlert("Missing field", message: "You must specify a FetchApp account username to add or delete friends from a group.")
            return
        }
        let inputFriendUsername = self.groupViewInput.text
        if(self.groupViewMembers.text == "") {
            self.displayOkayAlert("Error", message: "\(inputFriendUsername!) does not exist in \(self.groupViewName.text!)")
        }
        let groupName = self.groupViewName.text
        let prevFriend:String = self.groupViewMembers.text
        var prevFriendArray = [String]()
        var friendExist:Bool = false
        prevFriendArray = prevFriend.componentsSeparatedByString(",")
        for friend in prevFriendArray {
            if(friend == inputFriendUsername) {
                friendExist = true
            }
        }
        if(friendExist == false) {
            self.displayOkayAlert("Error", message: "\(inputFriendUsername!) does not exist in \(self.groupViewName.text!)")
        } else {
            let groupQuery = PFQuery(className: "groups")
            groupQuery.whereKey("username", equalTo: self.currentUser!.username!)
            groupQuery.whereKey("groupName", equalTo: groupName!)
            groupQuery.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error != nil || object == nil {
                    // Error occurred
                    print("Error - remove member from groups: \(error!) \(error!.description)")
                } else {
                    // Group name does not exist under user, create group
                    let prevMembers = object!["members"] as! String
                    let newMembers1:String = prevMembers.stringByReplacingOccurrencesOfString(inputFriendUsername!, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    let newMembers2:String = prevMembers.stringByReplacingOccurrencesOfString(",\(inputFriendUsername!)", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
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
                            print("\(groupName!) successfully updated.")
                            self.updateGroupTable()
                            self.groupTableView.reloadData()
                            self.displayOkayAlert("\(groupName!) updated", message: "\(inputFriendUsername!) has been removed from \(groupName!).")
                            self.groupViewMembers.text = newMembers
                        } else {
                            print("Error - remove member from groups: \(error!) \(error!.description)")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func groupViewShowDidTouch(sender: AnyObject) {
        let groupName = self.groupViewName.text
        if(self.groupViewMembers.text == "") {
            self.displayOkayAlert("Error", message: "Cannot display this group because there are no members.")
            return
        }
//        self.friendStatusArray.removeAll()
//        self.friendStatusImageArray.removeAll()
//        self.friendNameArray.removeAll()
//        self.friendLevelArray.removeAll()
        self.friendArray.removeAll()
        self.friendUsernameArray.removeAll()
        let groupQuery = PFQuery(className: "groups")
        groupQuery.whereKey("username", equalTo: self.currentUser!.username!)
        groupQuery.whereKey("groupName", equalTo: groupName!)
        groupQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                // Error occurred
                print("Error - group view show: \(error!) \(error!.description)")
            } else {
                let friendsInGroup = object!["members"] as! String
                var friendsInGroupArray = [String]()
                friendsInGroupArray = friendsInGroup.componentsSeparatedByString(",")
                for username in friendsInGroupArray {
                    self.friendUsernameArray.append(username)
                    let query = PFQuery(className: "_User")
                    query.whereKey("username", equalTo: username)
                    query.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error != nil || object == nil {
                            // Error occured
                            print("Error Show: Username: \(username) -- \(error!) \(error!.description)")
                        } else {
                            let profilePicData = object!["profilePic"] as! PFFile
                            let firstName = object!["firstName"] as! String
                            let lastName = object!["lastName"] as! String
                            let fullName = "\(firstName) \(lastName)"
                            let level = object!["level"] as! String
                            let status = object!["status"] as! String
                            profilePicData.getDataInBackgroundWithBlock({
                                (imageData: NSData?, error: NSError?) -> Void in
                                if (error == nil) {
                                    let profilePic = UIImage(data:imageData!)
                                    if(status == "red") {
                                        self.friendArray.append(friendItem(fullName: fullName, username: username, level: "Level \(level)", status: status, statusImage: UIImage(named: "redStatus")!, profilePic: profilePic!))
                                        
                                        //                                            self.friendStatusImageArray.append(UIImage(named: "redStatus")!)
                                    } else if(status == "green") {
                                        self.friendArray.append(friendItem(fullName: fullName, username: username, level: "Level \(level)", status: status, statusImage: UIImage(named: "greenStatus")!, profilePic: profilePic!))
                                        //                                            self.friendStatusImageArray.append(UIImage(named: "greenStatus")!)
                                    } else {
                                        self.friendArray.append(friendItem(fullName: fullName, username: username, level: "Level \(level)", status: status, statusImage: UIImage(named: "greyStatus")!, profilePic: profilePic!))
                                        //                                            self.friendStatusImageArray.append(UIImage(named: "greyStatus")!)
                                    }
//                                    self.friendProfilePicArray.append(profilePic!)
//                                    if(status == "red") {
//                                        self.friendStatusImageArray.append(UIImage(named: "redStatus")!)
//                                    } else if(status == "green") {
//                                        self.friendStatusImageArray.append(UIImage(named: "greenStatus")!)
//                                    } else {
//                                        self.friendStatusImageArray.append(UIImage(named: "greyStatus")!)
//                                    }
//                                    self.friendNameArray.append(fullName)
//                                    self.friendLevelArray.append("Level \(level)")
//                                    self.friendStatusArray.append(status)
                                    self.friendTableView.reloadData()
//                                    print(self.friendNameArray[0])
                                }
                            })
                        }
                    }
                }
                self.groupViewToDim.hidden = true
                self.groupViewPopup.hidden = true
                self.groupView.hidden = true
            }
        }

    }
    
    @IBAction func groupViewCancelDidTouch(sender: AnyObject) {
        self.groupViewToDim.hidden = true
        self.groupViewPopup.hidden = true
    }

    override func viewDidLoad() {
        // Setup delegates
        super.viewDidLoad()
        self.rankingTableView.delegate = self
        self.rankingTableView.dataSource = self
        
        // Start by hiding specific views
        self.newFriendButton.hidden = true
        self.activeRequestView.hidden = true
        self.friendListViewToDim.hidden = true
        self.inactiveRequestView.hidden = true
        self.editProfileView.hidden = true
        self.groupView.hidden = true
        self.groupViewToDim.hidden = true
        self.groupViewPopup.hidden = true
        
        // Setup group for FriendsList
        self.groupArray = [(groupItem(groupName: "All friends", members: ""))]
        
        // Add menu button action
        if self.revealViewController() != nil {
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        // Add keyboard stuff
        // Set delegates
        self.editProfileLastName.delegate = self
        self.editProfileFirstName.delegate = self
        self.editProfileEmailAddress.delegate = self
        self.editProfilePhoneNumber.delegate = self
        
        self.editProfileEmailAddress.returnKeyType = UIReturnKeyType.Done
        self.editProfileFirstName.returnKeyType = UIReturnKeyType.Done
        self.editProfileLastName.returnKeyType = UIReturnKeyType.Done
        self.editProfilePhoneNumber.keyboardType = UIKeyboardType.NumberPad
        
        // Add done button to number pad keyboard
        let numberToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        numberToolbar.barStyle = UIBarStyle.Default
        numberToolbar.items = [UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(secondaryVC.cancelNumberPad)), UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(secondaryVC.doneWithNumberPad))]
        numberToolbar.sizeToFit()
        self.editProfilePhoneNumber.inputAccessoryView = numberToolbar
        
        // Adds gesture so keyboard is dismissed when areas outside of editable text are tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(secondaryVC.DismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        // Add refresh action to driverTableView
        // Pull down to refresh
        let refreshFriendControl = UIRefreshControl()
        refreshFriendControl.addTarget(self, action: #selector(secondaryVC.refreshFriendsTable(_:)), forControlEvents: .ValueChanged)
        let refreshRankingControl = UIRefreshControl()
        refreshRankingControl.addTarget(self, action: #selector(secondaryVC.refreshRankingTable(_:)), forControlEvents: .ValueChanged)
        let refreshGroupControl = UIRefreshControl()
        refreshGroupControl.addTarget(self, action: #selector(secondaryVC.refreshGroupTable(_:)), forControlEvents: .ValueChanged)
        friendTableView.addSubview(refreshFriendControl)
        rankingTableView.addSubview(refreshRankingControl)
        groupTableView.addSubview(refreshGroupControl)
        
        if(viewSelect == 0) { // FriendList selected
            self.updateGroupTable()
            self.rankingView.hidden = true
            // Populate friend's table
//            self.friendStatusArray.removeAll()
//            self.friendStatusImageArray.removeAll()
//            self.friendNameArray.removeAll()
//            self.friendLevelArray.removeAll()
            self.friendUsernameArray.removeAll()
            self.updateFriendsTable()
            
            // Add dropDownGroup swipe gesture
//            let swipeDown = UISwipeGestureRecognizer(target: self, action: "showDropDownView:")
//            swipeDown.direction = UISwipeGestureRecognizerDirection.Down
//            self.view.addGestureRecognizer(swipeDown)
//            
//            let swipeUp = UISwipeGestureRecognizer(target: self, action: "hideDropDownView:")
//            swipeUp.direction = UISwipeGestureRecognizerDirection.Up
//            self.view.addGestureRecognizer(swipeUp)
            
        } else if (viewSelect == 1) { // Ranking view selected
            self.navigationItem.rightBarButtonItem = nil
            self.rankViewToDim.hidden = true
            self.rankingSelectedUserView.hidden = true
            self.rankingView.hidden = false
            self.rankArray.removeAll()
            self.updateRankingTable()
        } else { // editProfile selected
            self.navigationItem.rightBarButtonItem = nil
            self.editProfileView.hidden = false
            self.setupEditProfile()
        }
        
        // Check if user has any pending friend requests
        self.checkForPendingRequests()
    }
}
