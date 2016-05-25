//
//  ViewController.swift
//  Roomies
//
//  Created by Alec Barlow, Gabe Ratcliff, Nigel Koh on 5/20/16.
//  Copyright © 2016 Alec Barlow, Gabe Ratcliff, Nigel Koh. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let prefs = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var errorTextLabel: UILabel!
    @IBOutlet weak var loginTextLabel: UILabel!
    
    @IBOutlet weak var registerButtonLabel: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var newUser = false
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        if newUser {
            //User was in the register view but needs to log-in
            newUser = false
            loginTextLabel.text = "Please Log-in"
            errorTextLabel.hidden = true
            registerButtonLabel.setTitle("New Roommate?", forState: .Normal)
            nameTextField.hidden = true
            confirmPasswordTextField.hidden = true
            
        } else {
            //User needs to register
            newUser = true
            loginTextLabel.text = "Please register"
            errorTextLabel.hidden = true
            registerButtonLabel.setTitle("Existing User?", forState: .Normal)
            nameTextField.hidden = false
            confirmPasswordTextField.hidden = false
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newUser = false
        errorTextLabel.hidden = true
        nameTextField.hidden = true
        confirmPasswordTextField.hidden = true
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let userData = NSMutableDictionary()
        //dismiss keyboard
        self.view.endEditing(true)
        
        if emailTextField.text!.isEmpty ||
            passwordTextField.text!.isEmpty {
            errorTextLabel.text = "All fields are required"
            errorTextLabel.hidden = false
            return false
        }
        
        if newUser {
    
            if textField == passwordTextField {
                let minPasswordLength = 5
                let text = passwordTextField.text!
//                var upperCase = false
//                var lowerCase = false
//                var number = false
                
                if text.characters.count < minPasswordLength {
                    errorTextLabel.text = "Password must be greater than \(minPasswordLength) characters"
                    errorTextLabel.hidden = false
                    return false
                }
                
                
                
//                for ch in text.characters {
//                    
//                }
                
            }
            if passwordTextField.text! != confirmPasswordTextField.text! {
                errorTextLabel.text = "Passwords to not match"
                errorTextLabel.hidden = false
                return false
            }
            
            userData["name"] = nameTextField.text!
            userData["email"] = emailTextField.text!
            userData["password"] = passwordTextField.text!
            
            UserModel.registerUser(userData, completionHandler: { data, response, error in
                
                do {
                    //                print(response)
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
//                        print(jsonResult)
                        if let checkForFail = jsonResult["error"] {
//                            print(checkForFail)
                            let fail = checkForFail as! String
                            dispatch_async(dispatch_get_main_queue(), {
                                self.errorTextLabel.text = fail
                                self.errorTextLabel.hidden = false
                            })
                        } else {
                            let user = jsonResult["_id"] as! String
                            self.prefs.setValue(user, forKey: "currentUser")
                            dispatch_async(dispatch_get_main_queue(), {
                                self.performSegueWithIdentifier("NewRoomSelectionSegue", sender: jsonResult)
                            })
                        }
                        
                        
                    }
                    
                }catch {
                    print(data)
                    print(response)
                    print(error)
                }
            })

        } else {
            userData["email"] = emailTextField.text!
            userData["password"] = passwordTextField.text!
            UserModel.loginUser(userData, completionHandler: { data, response, error in
                
                do {
                    //                print(response)
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
//                        print(jsonResult)
                        if let checkForFail = jsonResult["error"] {
//                            print(checkForFail)
                            let fail = checkForFail as! String
                            dispatch_async(dispatch_get_main_queue(), {
                                self.errorTextLabel.text = fail
                                self.errorTextLabel.hidden = false
                            })
                        } else {
                            let user = jsonResult["_id"] as! String
                            self.prefs.setValue(user, forKey: "currentUser")
//                            print(jsonResult)
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                if let lastRoom = jsonResult["_lastRoom"] as? String {
                                    self.prefs.setValue(lastRoom, forKey: "currentRoom")
                                    self.performSegueWithIdentifier("LoginSegue", sender: lastRoom)
                                } else {
                                    self.performSegueWithIdentifier("NewRoomSelectionSegue", sender: user)
                                }
                                
                            })
                        }
                        
                        
                    }
                    
                }catch {
                    print(data)
                    print(response)
                    print(error)
                }
            })
            
        }
        return true
    }


}

