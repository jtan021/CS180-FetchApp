//
//  backTableViewController.swift
//  Fetch
//
//  Created by Jonathan Tan on 3/21/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import Foundation
import UIKit
import Parse

class backtableVC: UITableViewController {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userLevelLabel: UILabel!
    @IBOutlet weak var userExperienceLabel: UILabel!
    @IBOutlet weak var menuTableView: UITableView!

    var tableArray = [String]()
    
    override func viewDidLoad() {
        tableArray = ["Friend's List","Rankings","Settings","Log Out"]
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        
        var tableViewController: UITableViewController = UITableViewController(style: .Plain)
        tableViewController.tableView = self.menuTableView
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.tag = indexPath.row
        cell.textLabel?.text = tableArray[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) {
            // Do Friend's List
        } else if (indexPath.row == 1) {
            // Do Rankings
        } else if (indexPath.row == 2) {
            // Open Settings
        } else if (indexPath.row == 3) {
            // Log Out
            PFUser.logOut()
            let currentUser = PFUser.currentUser()
            print(currentUser)
            print("\nLogout Successful\n")
            self.performSegueWithIdentifier("successfulLogoutSegue", sender: self)
        }
    }
}
