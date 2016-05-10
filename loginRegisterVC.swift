//
//  loginRegisterVC.swift
//  FetchAppV2
//
//  Created by Jonathan Tan on 5/3/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import Parse

class loginRegisterVC: UIViewController, UITextFieldDelegate {
    
    /*
    * Constants
    */
    
    
    /*
    * Outlets
    */
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var viewToDim: UIView!
    @IBOutlet weak var registrationView: UIView!
    @IBOutlet weak var embeddedFirstNameTextField: UITextField!
    @IBOutlet weak var embeddedLastNameTextField: UITextField!
    @IBOutlet weak var embeddedEmailAddressTextField: UITextField!
    @IBOutlet weak var embeddedConfirmPasswordTextField: UITextField!
    
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
    
    // DismissKeyboard()
    // Dismisses the keyboard if areas outside of editable text are tapped
    func DismissKeyboard() {
        view.endEditing(true)
    }
    
    /*
    * Action functions
    */
    @IBAction func loginDidTouch(sender: AnyObject) {
        // First check that all fields are filled out.
        if (usernameTextField.text == "" || passwordTextField.text == "") {
            self.displayAlert("Missing field(s)", message: "All fields must be filled out.")
        } else {
            // If fields are all filled out, attempt to log user in
            PFUser.logInWithUsernameInBackground(usernameTextField.text!, password:passwordTextField.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    self.performSegueWithIdentifier("successfulLoginSegue", sender: self)
                    print("Login Successful")
                } else {
                    if let errorString = error?.userInfo["error"] as? NSString {
                        self.displayAlert("Login failed", message: errorString as String)
                    }
                }
            }
        }
    }
    
    @IBAction func registerDidTouch(sender: AnyObject) {
        // First check that all fields are filled out.
        if (usernameTextField.text == "" || passwordTextField.text == "") {
            self.displayAlert("Missing field(s)", message: "Please enter your desired username & password to continue.")
        } else {
            // Second check that the entered username is not taken
            let query = PFQuery(className: "_User")
            query.whereKey("username", equalTo: usernameTextField.text!)
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    if (objects!.count > 0) {
                        print("username is taken")
                        self.displayAlert("Account unavailable", message: "Username is already in use.")
                    } else {
                        print("username is available")
                        
                        // Since fields are not nil and username is available, show the registrationView
                        self.viewToDim.hidden = false
                        self.registrationView.hidden = false
                    }
                } else {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func embeddedRegisterDidTouch(sender: AnyObject) {
        // First check that all fields are filled out.
        if (embeddedFirstNameTextField.text == "" || embeddedLastNameTextField.text == "" || embeddedConfirmPasswordTextField.text == "" || embeddedEmailAddressTextField.text == "") {
            self.displayAlert("Missing field(s)", message: "All fields must be filled out.")
        } else {
            // Second check that the two passwords entered match
            if (passwordTextField.text != embeddedConfirmPasswordTextField.text) {
                self.displayAlert("Invalid password", message: "The confirmed password must be identical to the previously entered password.")
            } else {
                // Since fields are not nil and the passwords match, attempt to create the account
                let user = PFUser()
                user.username = usernameTextField.text
                user.password = embeddedConfirmPasswordTextField.text
                user.email = embeddedEmailAddressTextField.text
                user["firstName"] = embeddedFirstNameTextField.text
                user["lastName"] = embeddedLastNameTextField.text
                user.signUpInBackgroundWithBlock {
                    (succeeded, error) -> Void in
                    // If account creation failed, display error
                    if let error = error {
                        if let errorString = error.userInfo["error"] as? NSString {
                            self.displayAlert("Registration failed", message: errorString as String)
                        }
                    } else {
                        // Else account has been successfully registered, hide registrationView
                        print("Successful registration")
                        self.viewToDim.hidden = true
                        self.registrationView.hidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func returnToLoginDidTouch(sender: AnyObject) {
        registrationView.hidden = true
        viewToDim.hidden = true
    }
    
    /*
     * Overrided functions
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegates
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.embeddedEmailAddressTextField.delegate = self
        self.embeddedConfirmPasswordTextField.delegate = self
        self.embeddedFirstNameTextField.delegate = self
        self.embeddedLastNameTextField.delegate = self
        
        // Hides registration view
        viewToDim.hidden = true
        registrationView.hidden = true
        
        // Adds gesture so keyboard is dismissed when areas outside of editable text are tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if user was already logged in
        let currentUser = PFUser.currentUser()
        if currentUser?.username != nil {
            // If yes, skip login page
            performSegueWithIdentifier("successfulLoginSegue", sender: self)
        }
    }
}
