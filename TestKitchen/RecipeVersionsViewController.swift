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
    
    
    
    /**
     *
     *
     * MARK: TableView functions
     *
     */
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rename = UITableViewRowAction(style: .normal, title: "Rename") { action, index in
            self.promptForVersionName(withTitle: "Rename Version", msg: "What would you like to rename this version?", indexPath: indexPath, reprompt: false)
        }
        rename.backgroundColor = UIColor(red: 0.725, green: 0.725, blue: 0.725, alpha: 1) //light grey
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            if self.allVersions.count == 1 {
                self.alert(withTitle: "Cannot Delete", msg: "There must be at least one version for each recipe")
            } else {
                self.deleteVersion(atIndexPath: indexPath)
            }
        }
        delete.backgroundColor = UIColor(red: 1, green: 0.439, blue: 0.439, alpha: 1) //pale red
        
        
        return [delete, rename]
    }
    
    
    
    
    

    /**
     *  MARK: Favorite Button Functionality
     *
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
                },
                                error: {
                                    (fault : Fault?) -> () in
                                    self.alert(withTitle: "Server Error", msg: fault?.message ?? "Unknown Error")
                })
            }
        }
    }
    func getFavoriteImage(withValue val: Bool) -> UIImage {
        return val ? #imageLiteral(resourceName: "heart-filled-50") : #imageLiteral(resourceName: "heart-outline-50")
    }
    
    
    
    
    
    
    
    /**
     *
     *
     * MARK: Add, Update, Delete, Load Version functions
     *
     */
    
    @IBAction func addVersionButtonPressed(_ sender: Any) {
        promptForVersionName(withTitle: "New Version", msg: "What is the name of your new version?", indexPath: nil, reprompt: false)
    }

    func promptForVersionName(withTitle title: String, msg: String, indexPath: IndexPath?, reprompt isReprompt: Bool) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        if isReprompt { alert.title? = "Please enter a unique version name" }
        
        alert.addTextField()
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
                //remprompt if name exists
                self.promptForVersionName(withTitle: title, msg: msg, indexPath: indexPath, reprompt: true)
            } else if let path = indexPath{
                //rename version and update
                self.updateVersion(atIndexPath: path, newName: textField.text ?? "")
            } else {
                //save new version
                self.saveNewVersion(withVersionName: textField.text! as String)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateVersion(atIndexPath indexPath: IndexPath, newName: String){
        let spinner = createActivityIndicator()
        let dataStore = self.backendless.data.ofTable("Recipe")
        var updatedVersion = allVersions[indexPath.row]
        updatedVersion["version_name"] = newName
        dataStore?.save(updatedVersion,
                        response: { record in
                            spinner.removeFromSuperview()
                            self.loadVersions()
                        }, error: { fault in
                            spinner.removeFromSuperview()
                            self.alert(withTitle: "Server Error", msg: fault?.message ?? "Unknown error")
        })
    }
    
    func deleteVersion(atIndexPath indexPath: IndexPath) {
        let cell = self.versionsTable.cellForRow(at: indexPath) as! RecipeVersionCell
        let versionName = cell.nameLabel.text ?? ""
        let alert = UIAlertController(title: "Delete \(versionName)?", message: "This action cannot be undone", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            let versionId = self.allVersions[indexPath.row]["objectId"] as? String ?? ""
            self.backendless.data.ofTable("Recipe").remove(byId: versionId,
                response: { num in
                    self.loadVersions()
                }, error: { fault in
                    self.alert(withTitle: "Server Error", msg: fault?.message ?? "Unknown Error")
            })
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func saveNewVersion(withVersionName versionName: String) {
        //TODO: make option to make new version based off specific existing version? come up with way to not use indexing in case all versions deleted... could do this with button in the recipe details of one they want to base off of
        let recipe = ["course": self.allVersions[0]["course"],
                      "dish_name" : self.allVersions[0]["dish_name"],
                      "user_id" : self.allVersions[0]["user_id"],
                      "version_name" : versionName
        ]
        let dataStore = self.backendless.data.ofTable("Recipe")
        dataStore!.save(recipe,
                        response: {
                            (recipe) -> () in
                            self.loadVersions()
                            self.versionsTable.reloadData() //TODO: Redundant?
        },
                        error: {
                            (fault : Fault?) -> () in
                            self.alert(withTitle: "Server Error", msg: fault?.message ?? "Unknown Error")
                            
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
