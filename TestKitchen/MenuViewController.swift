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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //remove bottom line from navigation bar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

    }
    
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
}
