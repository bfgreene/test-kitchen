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
    
    /**
     *  Check if username exists and pw is correct
     *  Segue to main menu
     */
    @IBAction func signInButtonPressed(_ sender: Any) {
        //check username exists
        //check password is correct
        
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
