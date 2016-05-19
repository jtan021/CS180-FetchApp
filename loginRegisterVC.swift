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
    var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
    
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
    @IBOutlet weak var embeddedPhoneNumberTextField: UITextField!
    
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
    
    // textFieldShouldReturn()
    // Add's done button to textfield
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func cancelNumberPad() {
        embeddedPhoneNumberTextField.resignFirstResponder()
        embeddedPhoneNumberTextField.text = ""
    }
    
    func doneWithNumberPad() {
        embeddedPhoneNumberTextField.resignFirstResponder()
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
        } else if (usernameTextField.text!.rangeOfCharacterFromSet(characterSet.invertedSet) != nil) {
            self.displayAlert("Invalid username", message: "Acceptable characters for a Fetch account username include letters a-z, A-Z, and numbers 0-9")
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
        if (embeddedFirstNameTextField.text == "" || embeddedLastNameTextField.text == "" || embeddedConfirmPasswordTextField.text == "" || embeddedEmailAddressTextField.text == "" || embeddedPhoneNumberTextField.text == "") {
            self.displayAlert("Missing field(s)", message: "All fields must be filled out.")
            return
        } else {
            // Second check that the two passwords entered match
            if (embeddedPhoneNumberTextField.text!.characters.count != 10) {
                print(embeddedPhoneNumberTextField.text!.characters.count)
                self.displayAlert("Invalid phone number", message: "Please enter a valid 10 digit phone number including area code.")
                return
            }
            if (passwordTextField.text != embeddedConfirmPasswordTextField.text) {
                self.displayAlert("Invalid password", message: "The confirmed password must be identical to the previously entered password.")
                return
            } else {
                // Since fields are not nil and the passwords match, attempt to create the account
                let user = PFUser()
                user.username = usernameTextField.text
                user.password = embeddedConfirmPasswordTextField.text
                user.email = embeddedEmailAddressTextField.text
                user["firstName"] = embeddedFirstNameTextField.text
                user["lastName"] = embeddedLastNameTextField.text
                user["level"] = "1"
                user["experience"] = "0"
                user["friends"] = ""
                user["pending"] = ""
                user["phoneNumber"] = embeddedPhoneNumberTextField.text
                user["status"] = "green"
                user["currentLAT"] = "0"
                user["currentLONG"] = "0"
                let defaultACL = PFACL()
                defaultACL.publicWriteAccess = true
                defaultACL.publicReadAccess = true
                PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
                user.ACL = defaultACL
                let image = UIImagePNGRepresentation(UIImage(named: "gender_neutral_user")!)
                let profilePic = PFFile(name: "profile.png", data: image!)
                user["profilePic"] = profilePic
                user.signUpInBackgroundWithBlock {
                    (succeeded, error) -> Void in
                    // If account creation failed, display error
                    if let error = error {
                        if let errorString = error.userInfo["error"] as? NSString {
                            self.displayAlert("Registration failed", message: errorString as String)
                        }
                    } else {
                        // Else account has been successfully registered, hide registrationView
                        let newFriendObject = PFObject(className: "friends")
                        newFriendObject["username"] = self.usernameTextField.text
                        newFriendObject["friendsList"] = ""
                        newFriendObject["pendingFrom"] = ""
                        newFriendObject["pendingTo"] = ""
                        let defaultACL = PFACL()
                        defaultACL.publicWriteAccess = true
                        defaultACL.publicReadAccess = true
                        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
                        newFriendObject.ACL = defaultACL
                        newFriendObject.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                print("Successful registration")
                                self.viewToDim.hidden = true
                                self.registrationView.hidden = true
                                self.displayAlert("\(self.usernameTextField.text!) successfully registered", message: "Welcome to Fetch.")
                                self.performSegueWithIdentifier("successfulLoginSegue", sender: self)
                            } else {
                                print("Error1: \(error!) \(error!.description)")
                            }
                        }
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
        self.embeddedPhoneNumberTextField.delegate = self
        
        // Set phoneNumber textfield keyboard to numberpad
        self.embeddedPhoneNumberTextField.keyboardType = UIKeyboardType.NumberPad
        
        // Add done button to all regular keyboards
        self.usernameTextField.returnKeyType = UIReturnKeyType.Done
        self.passwordTextField.returnKeyType = UIReturnKeyType.Done
        self.embeddedEmailAddressTextField.returnKeyType = UIReturnKeyType.Done
        self.embeddedConfirmPasswordTextField.returnKeyType = UIReturnKeyType.Done
        self.embeddedFirstNameTextField.returnKeyType = UIReturnKeyType.Done
        self.embeddedLastNameTextField.returnKeyType = UIReturnKeyType.Done
        self.embeddedPhoneNumberTextField.returnKeyType = UIReturnKeyType.Done
        
        // Add done button to number pad keyboard
        let numberToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        numberToolbar.barStyle = UIBarStyle.Default
        numberToolbar.items = [UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(loginRegisterVC.cancelNumberPad)), UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(loginRegisterVC.doneWithNumberPad))]
        numberToolbar.sizeToFit()
        embeddedPhoneNumberTextField.inputAccessoryView = numberToolbar
        
        // Hides registration view
        viewToDim.hidden = true
        registrationView.hidden = true
        
        // Adds gesture so keyboard is dismissed when areas outside of editable text are tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loginRegisterVC.DismissKeyboard))
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
