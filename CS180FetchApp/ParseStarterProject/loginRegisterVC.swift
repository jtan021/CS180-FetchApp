/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class loginRegisterVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var viewToDim: UIView!
    @IBOutlet weak var registrationView: UIView!
    @IBOutlet weak var embeddedFirstNameTextField: UITextField!
    @IBOutlet weak var embeddedLastNameTextField: UITextField!
    @IBOutlet weak var embeddedPasswordConfirmTextField: UITextField!
    @IBOutlet weak var embeddedEmailAddressTextField: UITextField!
    
    @IBAction func embeddedCancelDidTouch(sender: AnyObject) {
        viewToDim.hidden = true
        registrationView.hidden = true
    }
    
    @IBAction func embeddedRegisterDidTouch(sender: AnyObject) {
        // First check that all fields are filled out.
        if (embeddedFirstNameTextField.text == "" || embeddedLastNameTextField.text == "" || embeddedPasswordConfirmTextField.text == "" || embeddedEmailAddressTextField.text == "") {
            self.displayAlert("Missing field(s)!", message: "All fields must be filled out.")
        } else {
            // Second check that the two passwords entered match
            if (passwordTextField.text != embeddedPasswordConfirmTextField.text) {
                self.displayAlert("Invalid password!", message: "The confirmed password must be identical to the previously entered password.")
            } else {
                // Since fields are not nil and the passwords match, attempt to create the account
                let user = PFUser()
                user.username = usernameTextField.text
                user.password = embeddedPasswordConfirmTextField.text
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

    @IBAction func registerDidTouch(sender: AnyObject) {
        // First check that all fields are filled out.
        if (usernameTextField.text == "" || passwordTextField.text == "") {
            self.displayAlert("Missing field(s)!", message: "Please enter your desired username & password to continue.")
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
    
    @IBAction func loginDidTouch(sender: AnyObject) {
        // First check that all fields are filled out.
        if (usernameTextField.text == "" || passwordTextField.text == "") {
            self.displayAlert("Missing field(s)!", message: "All fields must be filled out.")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegates
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.embeddedEmailAddressTextField.delegate = self
        self.embeddedPasswordConfirmTextField.delegate = self
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
