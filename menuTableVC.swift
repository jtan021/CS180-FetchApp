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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return menuItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier: String = menuItems[indexPath.row] as! String
        if(indexPath.row == 1) {
            let silentCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! silentModeCell
            return silentCell
        } else {
            var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
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
        if(indexPath.row == 0) {
            // Do profile stuff
        } else if (indexPath.row == 1) {
            // Do Silent mode
            print("silent mode")
            var silentCell = tableView.dequeueReusableCellWithIdentifier("silentMode", forIndexPath: indexPath) as! silentModeCell
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
            PFUser.logOut()
            let currentUser = PFUser.currentUser()
            print(currentUser)
            print("\nLogout Successful\n")
            self.performSegueWithIdentifier("successfulLogoutSegue", sender: self)
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
