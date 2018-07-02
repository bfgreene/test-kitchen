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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func registerButtonPressed(_ sender: Any) {
        //check if account exists
        //register
        //segue to menu table
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
