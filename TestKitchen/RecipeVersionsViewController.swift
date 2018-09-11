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
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    /**
     *  Create new version of recipe based on user input
     *  Save to backendless
     *  Segue to Recipe Detail of new version
     */
    @IBAction func addVersionButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "New Version", message: "What is the name of the recipe version?", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Version \(self.allVersions.count + 1)"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            print("Text field: \(String(describing: textField.text))")
            //create new entry in table with current dish_name and specified version title, segue to new recipe
            //add it to allVersions so it shows up when
            //make option to make new version based of existing version?
            let recipe = ["course": self.allVersions[0]["course"],
                          "dish_name" : self.allVersions[0]["dish_name"],
                          "user_id" : self.allVersions[0]["user_id"],
                          "version_name" : textField.text ?? "Version \(self.allVersions.count + 1)"
            ] //default bases off of "original"... come up with way without indexing
            let dataStore = self.backendless.data.ofTable("Recipe")
            dataStore!.save(recipe,
                            response: {
                                (recipe) -> () in
                                print(recipe ?? "nil")
                                //segue to new version
            },
                            error: {
                                (fault : Fault?) -> () in
                                print("Server error: \(fault ?? Fault())")
                                //display error message
                                
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func loadVersions(){
        let whereClause = "user_id = '\(userId)' and dish_name = '\(dishName)'"
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(whereClause)
        queryBuilder!.setSortBy(["created"])
        
        let dataStore = self.backendless.data.ofTable("Recipe")
        dataStore?.find(queryBuilder,
                        response: {
                            (foundVersions) -> () in
                            self.allVersions = foundVersions as! [[String : Any]]
                            print(self.allVersions.count)
                            DispatchQueue.main.async {
                                self.versionsTable.reloadData()
                            }
        },
                        error: {
                            (fault : Fault?) -> () in
                            print("Server reported an error: \(fault ?? Fault()) ")
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
}
