//
//  MenuViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/8/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    let backendless = Backendless.sharedInstance()!
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToRecipes", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToRecipes" {
            let recipesVC = segue.destination as! RecipesViewController
            let button  = sender as! UIButton
            recipesVC.menuIndex = button.tag
        }
    }

    @IBAction func settingsButtonPressed(_ sender: Any) {
        //"log out" for now
        
        backendless.userService.logout({
            (result : Any?) -> Void in
            print("User has been logged out")
            self.dismiss(animated: true, completion: nil)
        },
            error: {
                (fault : Fault?) -> Void in
                print("Server reported an error: \(String(describing: fault?.description))")
        })
    }
}
