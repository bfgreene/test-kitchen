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
    var showNoRecipesImage = false
    let backendless = Backendless.sharedInstance() as Backendless
    var currentUserId = String() //put userID in UserDefaults or something
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadDishes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadDishes() //trying here to get spinner to show
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numDishes = uniqueDishes.count
        if numDishes == 0 {
            //TODO: change to "no recipes!".. make square, centered, doesn't flash before first load(doesn't show at at all if there are recipes but just haven't loaded yet
            recipesTableView.backgroundView = UIImageView(image: UIImage(named: "NoRecipes"))
            recipesTableView.backgroundView?.contentMode = .scaleAspectFit
        } else {
            recipesTableView.backgroundView = nil
        }
        return uniqueDishes.count
        
    }
    
    
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeCell
        cell.nameLabel.text = uniqueDishes[indexPath.row]
        return cell
    }

    
    
    /**
     *  Create new Recipe based on user input from alert
     *  Save to backendless db
     *
     */
    @IBAction func addRecipeButtonPressed(_ sender: Any) {
        promptForDishName(false)
    }
    
    
    
    func loadDishes() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        currentUserId = backendless.userService.currentUser.email as String
        let whereClause = "user_id = '\(currentUserId)' and course = '\(courseNames[menuIndex])'"
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(whereClause)
        queryBuilder!.setSortBy(["created"])
        
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
                            activityIndicator.removeFromSuperview()

        },
                        error: {
                            (fault : Fault?) -> () in
                            print("Server reported an error: \(fault ?? Fault()) ")
                            activityIndicator.removeFromSuperview()

        })

    }
    
    
    
    func promptForDishName(_ isReprompt: Bool) {
        let alert = UIAlertController(title: "New Recipe", message: "What is the name of the recipe?", preferredStyle: .alert)
        
        if isReprompt { alert.title? = "Please enter a unique name" }
        
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            
            //reprompt if dish with that name exists
            if let dishName = textField.text, self.uniqueDishes.contains(dishName) {
                self.promptForDishName(true)
            } else {
                self.saveNewDish(withDishName: textField.text ?? "New Dish")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func saveNewDish(withDishName dishName: String) {
        let recipe = ["course" : self.courseNames[self.menuIndex],
                      "dish_name": dishName,
                      "version_name": "Original",
                      "user_id" : self.currentUserId] as [String : Any]
        let dataStore = self.backendless.data.ofTable("Recipe")
        dataStore!.save(recipe,
                        response: {
                            (recipe) -> () in
                            print("Recipe saved")
                            //segue to versions
                            self.loadDishes()
                            self.recipesTableView.reloadData()
        },
                        error: {
                            (fault : Fault?) -> () in
                            print("Server reported an error: \(fault ?? Fault())")
        })
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToVersions" {
            let versionsVC = segue.destination as? RecipeVersionsViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRow(at: indexPath) as? RecipeCell
                versionsVC?.title = cell?.nameLabel.text ?? "Unknown"
                versionsVC?.userId = currentUserId
                versionsVC?.dishName = cell?.nameLabel.text ?? ""
            }
        }
    }
}



class RecipeCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
}

