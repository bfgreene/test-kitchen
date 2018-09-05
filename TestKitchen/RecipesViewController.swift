//
//  RecipesViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/3/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class RecipesViewController: UITableViewController {
    
    
    var menuIndex = 0
    let courseNames = ["Mains", "Sides", "Appetizers", "Bakery", "Desserts", "Other"] //put in constants file or something
    

    @IBOutlet var recipesTableView: UITableView!
    
    var allRecipes = [[String : Any]]()
    var uniqueDishes = [String]()
    let backendless = Backendless.sharedInstance() as Backendless
    var currentUserId = String() //put userID in UserDefaults or something
    
    override func viewDidLoad() {
        currentUserId = backendless.userService.currentUser.email as String
        //allRecipes = [mains, sides, appetizers, bakery, desserts, other]
        let whereClause = "user_id = '\(currentUserId)' and course = '\(courseNames[menuIndex])'"//add ordered by date_created ascending
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(whereClause)
        
        let dataStore = self.backendless.data.ofTable("Recipe")
        dataStore?.find(queryBuilder,
                        response: {
                            (foundRecipes) -> () in
                            for recipe in foundRecipes as! [[String : Any]] {
                                self.allRecipes.append(recipe)
                                let dishName = recipe["dish_name"] as? String ?? ""
                                if !self.uniqueDishes.contains(dishName) {
                                    self.uniqueDishes.append(dishName)

                                }
                            }
                            self.recipesTableView.reloadData()
                            print("Result: \(String(describing: foundRecipes))")
        },
                        error: {
                            (fault : Fault?) -> () in
                            print("Server reported an error: \(fault ?? Fault()) ")
        })
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return allRecipes.count //no should be unique dish_names.. so multiple versions don't casue repeats
        let numDishes = uniqueDishes.count
        if numDishes == 0 {
            recipesTableView.backgroundView = UIImageView(image: UIImage(named: "sourd")) //change to "no recipes! image".. make square and centered to fit all screens and that it doesn't flash before first load
        } else {
            recipesTableView.backgroundView = nil
        }
        return uniqueDishes.count
        
    }
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeCell
        //cell.nameLabel.text = allRecipes[indexPath.row]["dish_name"] as? String
        cell.nameLabel.text = uniqueDishes[indexPath.row]
        return cell
    }

    /**
     *  Create new Recipe based on user input from alert
     *  Save to backendless db
     *
     */
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
                          "user_id" : self.currentUserId] as [String : Any]
            let dataStore = self.backendless.data.ofTable("Recipe")
            dataStore!.save(recipe,
                            response: {
                                (recipe) -> () in
                                print("Recipe saved")
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
                versionsVC?.allVersions = allRecipes.filter { $0["dish_name"] as? String == cell?.nameLabel.text
                }
            }
            
        }
    }

}

class RecipeCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
}

