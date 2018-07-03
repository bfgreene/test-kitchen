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
    
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        //check username exists
        //check password is correct
        
        //segue to main screen
       // UserDefaults.standard.set("un", forKey: "username") //maybe I don't need this with backendless b/c I can use the shared instance to find active user across the app
        performSegue(withIdentifier: "signInSegue", sender: self)
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "signInSegue" {
//            let destinationNC = segue.destination as! UINavigationController
//            let targetVC = destinationNC.topViewController as! MenuViewController
//            
//        }
//    }
}
