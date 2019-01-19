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
    @IBOutlet var recipesTableView: UITableView!
    var allRecipes = [[String : Any]]()
    var uniqueDishes = [String]()
    var showNoRecipesImage = false
    let backendless = Backendless.sharedInstance() as Backendless
    var currentUserId = String() //put userID in UserDefaults or something
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constants.courseNames[menuIndex]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadDishes()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uniqueDishes.count
    }
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeCell
        cell.nameLabel.text = uniqueDishes[indexPath.row]
        return cell
    }

    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rename = UITableViewRowAction(style: .normal, title: "Rename") { action, index in
            //prompt for new name
            print("rename button tapped")
        }
        rename.backgroundColor = .lightGray
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            //prompt for delete confirmation
            print("delete button tapped")
        }
        delete.backgroundColor = .red
        
        
        return [delete, rename]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func deleteDish() {
       
    }
    
    
    func promptForDishName(withTitle title: String, msg: String, rename: Bool, reprompt: Bool) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        if reprompt { alert.title? = "Please enter a unique name" }
        
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            
            //reprompt if dish with that name exists
            if let dishName = textField.text, self.uniqueDishes.contains(dishName) {
                self.promptForDishName(withTitle: title, msg: msg, rename: rename, reprompt: true)
            } else if !rename {
                self.saveNewDish(withDishName: textField.text ?? "New Dish")
            } else {
                //rename dish & update
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    func renameDish() {
        
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
        let activityIndicator = createActivityIndicator()
        currentUserId = backendless.userService.currentUser.email as String
        let whereClause = "user_id = '\(currentUserId)' and course = '\(Constants.courseNames[menuIndex])'"
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
                            if foundRecipes?.count == 0 {
                                self.recipesTableView.backgroundView = UIImageView(image: UIImage(named: "NoRecipes"))
                                self.recipesTableView.backgroundView?.contentMode = .scaleAspectFit
                            } else {
                                self.recipesTableView.backgroundView = UIImageView()
                            }

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
        let recipe = ["course" : Constants.courseNames[self.menuIndex],
                      "dish_name": dishName,
                      "version_name": "Original",
                      "user_id" : self.currentUserId] as [String : Any]
        let dataStore = self.backendless.data.ofTable("Recipe")
        dataStore!.save(recipe,
                        response: {
                            (recipe) -> () in
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

