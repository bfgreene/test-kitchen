//
//  RecipeVersionsViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/7/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class RecipeVersionsViewController: UITableViewController {

    let backendless = Backendless.sharedInstance() as Backendless
    var allVersions = [[String:Any]]()
    var recipeName = String()
    var dishName = String()
    var userId = String()
    
    @IBOutlet var versionsTable: UITableView!
    
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadVersions()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allVersions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "versionCell") as! RecipeVersionCell
        cell.nameLabel.text = allVersions[indexPath.row]["version_name"] as? String
        let isFavorite = allVersions[indexPath.row]["is_favorite"] as? Bool ?? false
        cell.favoriteButton.setImage(getFavoriteImage(withValue: isFavorite), for: .normal)
        cell.favoriteButton.tag = indexPath.row
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    /**
     *  Changes the 'is_favorite' property of recipe and saves to database
     *  Displays proper favorite image
     */
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        //TODO: change ui constaints so title doesn't overlap heart button
        if let selectedButton = sender as? UIButton {
            let indexPath = IndexPath(row: selectedButton.tag, section: 0)
            let dataStore = backendless.data.ofTable("Recipe")
            let cell = tableView.cellForRow(at: indexPath) as? RecipeVersionCell
            var selectedRecord = allVersions[indexPath.row]
            if let currentValue = selectedRecord["is_favorite"] as? Bool {
                selectedRecord["is_favorite"] = !currentValue
                allVersions[indexPath.row] = selectedRecord
                dataStore?.save(selectedRecord,
                                response: {
                                    (updatedRecord) -> () in
                                    let record = updatedRecord as! [String : Any]
                                    if let isFavorite = record["is_favorite"] as? Bool {
                                        cell?.favoriteButton.setImage(self.getFavoriteImage(withValue: isFavorite), for: .normal)
                                    }
                                    print("Favorite saved")
                },
                                error: {
                                    (fault : Fault?) -> () in
                                    print("Server reported an error: \(fault ?? Fault())")
                })
            }
        }
    }
    
    
    @IBAction func addVersionButtonPressed(_ sender: Any) {
        promptForVersionName(reprompt: false)
    }
    
    
    func promptForVersionName(reprompt isReprompt: Bool) {
        let alert = UIAlertController(title: "New Version", message: "What is the name of the recipe version?", preferredStyle: .alert)
        
        if isReprompt { alert.title? = "Please enter a unique version name" }
        
        alert.addTextField { (textField) in
            textField.text = "Version \(self.allVersions.count + 1)"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            var versionNameExists = false
            if let inputName = textField.text {
                for version in self.allVersions {
                    if version["version_name"] as! String == inputName {
                        versionNameExists = true
                    }
                }
            }
            
            if versionNameExists {
                self.promptForVersionName(reprompt: true)
            } else {
                self.saveNewVersion(withVersionName: textField.text! as String)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func saveNewVersion(withVersionName versionName: String) {
        //TODO: make option to make new version based off specific existing version? come up with way to not use indexing in case all versions deleted
        //^^ could do this with button in the recipe details of one they want to base off of
        let recipe = ["course": self.allVersions[0]["course"],
                      "dish_name" : self.allVersions[0]["dish_name"],
                      "user_id" : self.allVersions[0]["user_id"],
                      "version_name" : versionName
        ]
        let dataStore = self.backendless.data.ofTable("Recipe")
        dataStore!.save(recipe,
                        response: {
                            (recipe) -> () in
                            print("New version created")
                            self.loadVersions()
                            self.versionsTable.reloadData()
                            //segue to new version
        },
                        error: {
                            (fault : Fault?) -> () in
                            print("Server error: \(fault ?? Fault())")
                            
        })
    }
    
    
    func loadVersions(){
        let activityIndicator = createActivityIndicator()
        let whereClause = "user_id = '\(userId)' and dish_name = '\(dishName)'"
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(whereClause)
        queryBuilder!.setSortBy(["created"])
        
        let dataStore = self.backendless.data.ofTable("Recipe")
        dataStore?.find(queryBuilder,
                        response: {
                            (foundVersions) -> () in
                            self.allVersions = foundVersions as! [[String : Any]]
                            DispatchQueue.main.async {
                                self.versionsTable.reloadData()
                            }
                            activityIndicator.removeFromSuperview()
        },
                        error: {
                            (fault : Fault?) -> () in
                            print("Server reported an error: \(fault ?? Fault()) ")
                            activityIndicator.removeFromSuperview()
        })
    }
    
    func getFavoriteImage(withValue val: Bool) -> UIImage {
        return val ? #imageLiteral(resourceName: "heart-filled-50") : #imageLiteral(resourceName: "heart-outline-50")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToRecipeDetails" {
            let recipeDetailsVC = segue.destination as? RecipeDetailsViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRow(at: indexPath) as? RecipeVersionCell
                recipeDetailsVC?.title = cell?.nameLabel.text ?? "Unknown"
                recipeDetailsVC?.recipe = allVersions[indexPath.row]                
            }
            
        }
    }

}

class RecipeVersionCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var favoriteButton: UIButton!
}
