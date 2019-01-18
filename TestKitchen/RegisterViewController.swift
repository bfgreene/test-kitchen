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
    let backendless = Backendless.sharedInstance()!

    /**
    *   Check if account exists and if two pw entries match
    *   Register if new user and segue to main menu
    */
    @IBAction func registerButtonPressed(_ sender: Any) {
        if passwordField.text != passwordConfirmationField.text {
            alert(withTitle: "Error", msg: "Password fields do not match")
        } else {
            registerUser()
        }
    }
    
    /**
     *  Backendless provided registration code
     */
    func registerUser() {
        let user = BackendlessUser()
        user.setProperty("email", object: emailField.text)
        user.password = passwordField.text! as NSString
        backendless.userService.register(user,
            response: {
                (registeredUser : BackendlessUser?) -> Void in
                self.loginUser()
            },
            error: {
                (fault : Fault?) -> Void in
                self.alert(withTitle: "Error", msg: fault?.message ?? "Could not register user")
        })
    }

    func loginUser() {
        backendless.userService.login(emailField.text, password: passwordField.text,
            response: {
                (loggedUser : BackendlessUser?) -> Void in
                self.passwordField.text = ""
                self.passwordConfirmationField.text = ""
                self.emailField.text = ""
                self.performSegue(withIdentifier: "registerSegue", sender: self)
            },
            error: {
                (fault : Fault?) -> Void in
                self.alert(withTitle: "Error", msg: "Invalid email or password")
        })
    }
    
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
