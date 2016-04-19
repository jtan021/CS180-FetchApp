//
//  ViewController.swift
//  FetchApp
//
//  Created by Jonathan Tan on 4/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        // Load menu
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    override func viewDidAppear(animated: Bool) {
        //menuBarButton.action = Selector("revealToggle:")
    }

}
