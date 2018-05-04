//
//  RecipesViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/3/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class RecipesViewController: UITableViewController {
    
    let tempRecipes = ["Falafel", "Pita", "Tzaziki", "Biscotti", "Pesto Alfredo", "Shrimp Scampi"]
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempRecipes.count
    }
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeCell
        cell.nameLabel.text = tempRecipes[indexPath.row]
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToRecipe" {
            let recipeVC = segue.destination as? RecipeViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRow(at: indexPath) as? RecipeCell
                recipeVC?.title = cell?.nameLabel.text ?? "Unknown"
            }
            
        }
    }

}

class RecipeCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
}

