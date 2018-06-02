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
    let courseNames = ["Mains", "Sides", "Appetizers", "Bakery", "Desserts", "Other"]
    let mains = ["Falafel", "Shrimp Scampi", "Pesto Pasta", "Red Curry"]
    let sides = ["Roasted Potatoes", "Brussel Sprouts", "Three Bean Salad", "Summer Squash"]
    let appetizers = ["Spinach Salad", "Bruschetta"]
    let bakery = ["Sourdough", "Pita", "Cinnamon Challah", "Straberry Rhubarb Pie", "Banana Bread"]
    let desserts = ["Fudge Brownies", "Chocolate Chip Cookies"]
    let other = ["Tzaziki", "Vinaigrette"]
    
    var allRecipes = [[String]]()
    
    let backendless = Backendless.sharedInstance()
    
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

    @IBAction func addRecipeButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "New Recipe", message: "What is the name of the recipe?", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Delish Dish"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            print("Text field: \(String(describing: textField.text))")
            //make new entry in table with given recipe name and 'Original' for default first version
            //segue to that recipe detail? Or just to versionsVC?
            let recipe = ["course" : self.courseNames[self.menuIndex],
                          "dish_name": textField.text ?? "New Dish",
                          "version_name": "Original",
                          "user_id" : "1"] as [String : Any]
            let dataStore = self.backendless?.data.ofTable("Recipe")
            dataStore!.save(recipe,
                            response: {
                                (recipe) -> () in
                                print("Contact saved")
            },
                            error: {
                                (fault : Fault?) -> () in
                                print("Server reported an error: \(fault ?? Fault())")
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
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

