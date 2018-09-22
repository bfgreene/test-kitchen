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
        //change title header font.. haven't found right fit
        //self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Palatino-Italic", size: 25)!] //change to better font

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
