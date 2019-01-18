//
//  SignInViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 6/25/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var signInButton: UIButton!
    
    let backendless = Backendless.sharedInstance()!


    @IBAction func signInButtonPressed(_ sender: Any) {
        if (!(emailField.text?.isEmpty)! && !(passwordField.text?.isEmpty)!) {
            loginUser()
        } else {
            self.alert(withTitle: "Error", msg: "Invalid email or password")
        }
    }
    
    /**
     * Login user with backendless userService api
     * Segue if login succeeds
     * Present alert if login fails
    */
    func loginUser() {
        backendless.userService.login(emailField.text, password: passwordField.text,
        response: {
            (loggedUser : BackendlessUser?) -> Void in
            self.passwordField.text = ""
            self.performSegue(withIdentifier: "signInSegue", sender: self)
        },
        error: {
            (fault : Fault?) -> Void in
            self.alert(withTitle: "Error", msg: "Invalid email or password")
        })
    }

}
