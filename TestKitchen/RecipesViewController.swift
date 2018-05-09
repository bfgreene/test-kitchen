//
//  RecipesViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/3/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class RecipesViewController: UITableViewController {
    
    //2d array for mains/sides/apps/bakery/dessert/other
    
    var menuIndex = 0
    let mains = ["Falafel", "Shrimp Scampi", "Pesto Pasta", "Red Curry"]
    let sides = ["Roasted Potatoes", "Brussel Sprouts", "Three Bean Salad", "Summer Squash"]
    let appetizers = ["Spinach Salad", "Bruschetta"]
    let bakery = ["Sourdough", "Pita", "Cinnamon Challah", "Straberry Rhubarb Pie", "Banana Bread"]
    let desserts = ["Fudge Brownies", "Chocolate Chip Cookies"]
    let other = ["Tzaziki", "Vinaigrette"]
    
    var allRecipes = [[String]]()
    
    override func viewDidLoad() {
        allRecipes = [mains, sides, appetizers, bakery, desserts, other]
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRecipes[menuIndex].count
    }
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeCell
        cell.nameLabel.text = allRecipes[menuIndex][indexPath.row]
        return cell
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToVersions" {
            let versionsVC = segue.destination as? RecipeVersionsViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRow(at: indexPath) as? RecipeCell
                versionsVC?.title = cell?.nameLabel.text ?? "Unknown"
            }
            
        }
    }

}

class RecipeCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
}

