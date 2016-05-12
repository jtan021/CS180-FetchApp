//
//  menuTableVC.swift
//  FetchAppV2
//
//  Created by Jonathan Tan on 5/3/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import Parse

class menuTableVC: UITableViewController {
    var menuItems: [AnyObject] = []
    var silentMode: Bool = false
    
    /*
    * Custom functions
    */
    // displayAlert
    // Inputs: title:String, message:String
    // Output: UIAlertAction
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
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
        let cellIdentifier: String = menuItems[indexPath.row] as! String
        if(indexPath.row == 1) {
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
        
        if(indexPath.row == 0) {
            // Do profile stuff
        } else if (indexPath.row == 1) {
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
        } else if (indexPath.row == 2) {
            // Show friend's list
        } else if (indexPath.row == 3) {
            // Show ranking
        } else if (indexPath.row == 4) {
            // Show settings
        } else if (indexPath.row == 5) {
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
                        // 3) Check if status == inactive
                        let status = object!["status"] as! String
                        if(status == "inactive") {
                            // 3.5a) If status == inactive, log out.
                            PFUser.logOut()
                            let currentUser = PFUser.currentUser()
                            print(currentUser)
                            print("\nLogout Successful\n")
                            self.performSegueWithIdentifier("successfulLogoutSegue", sender: self)
                        } else {
                            // 3.5b) If status != inacitve, alert user and ask to set status to inactive and continue log out
                            let alert = UIAlertController(title: "Ride pending", message: "You are currently searching for a ride. Would you like to cancel your search and continue logging out?", preferredStyle:  UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                                object!["status"] = "inactive"
                                object!.saveInBackgroundWithBlock {
                                    (success: Bool, error: NSError?) -> Void in
                                    if (success) {
                                        print("Status set to inactive")
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
    
    /*
    * Overrided functions
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        menuItems = ["profile", "silentMode", "friendsList", "ranking", "setting", "logOut"]
    }
    
    
}
