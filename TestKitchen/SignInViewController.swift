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
            self.alert(withTitle: "Error", msg: fault?.message ?? "Invalid email or password")
        })
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        if let email = emailField.text {
            let alert = UIAlertController(title: "Password Reset", message: "Would you like to reset the password for \(email)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                self.sendPasswordReset(toAddress: email)
            }))
            alert.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: nil)))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func sendPasswordReset(toAddress email: String){
        backendless.userService.restorePassword(email, response: { val in
            self.alert(withTitle: "Success", msg: "A passowrd reset link has been sent to \(email)")
        }, error: { fault in
            self.alert(withTitle: "Server Error", msg: fault?.message ?? "Unknown Error")
        })
    }
    
    

}
