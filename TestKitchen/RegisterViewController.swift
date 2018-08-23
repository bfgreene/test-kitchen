//
//  RegisterViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 6/25/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordConfirmationField: UITextField!
    
    @IBOutlet var registerButton: UIButton!
    let backendless = Backendless.sharedInstance()

    /**
    *   Check if account exists and if two pw entries match
    *   Register if new user and segue to main menu
    */
    @IBAction func registerButtonPressed(_ sender: Any) {
        print(emailField.text ?? "nil")
        //check if account exists
        if emailField.text == "existingUser" {
            //alert "User with this email exists"
            print("this email has an account")
        } else if passwordField.text != passwordConfirmationField.text {
            //alert "Passwords do not match"
            print("pwds do not match")
        } else {
            print("registering user")
            registerUser()
        }
        //register
        //segue to menu table
        performSegue(withIdentifier: "registerSegue", sender: self)
    }
    
    /**
     *  Backendless provided registration code
     */
    func registerUser() {
        let user = BackendlessUser()
        user.setProperty("email", object: emailField.text)
        user.password = passwordField.text! as NSString
        backendless?.userService.register(user,
                                         response: {
                                            (registeredUser : BackendlessUser?) -> Void in
                                            print("User registered \(registeredUser?.value(forKey: "email") ?? "nil" )")
        },
                                         error: {
                                            (fault : Fault?) -> Void in
                                            print("Server reported an error: \(fault?.description ?? "nil")")
        })
    }
    
    
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
