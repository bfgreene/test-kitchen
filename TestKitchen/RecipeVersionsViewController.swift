//
//  RecipeVersionsViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/7/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class RecipeVersionsViewController: UITableViewController {

    //temporary data
    let versions = ["Original", "Versions 2", "Low Sugar", "Longer ferment"]
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return section == 0 ? 1 : versions.count - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "versionCell") as! RecipeVersionCell
        if indexPath.section == 0 {
            cell.nameLabel.text = versions[indexPath.row]
        } else {
            cell.nameLabel.text = versions[indexPath.row + 1]
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    
    /**
     *  Create new version of recipe based on user input
     *  Save to backendless
     *  Segue to Recipe Detail of new version
     */
    @IBAction func addVersionButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "New Version", message: "What is the name of the recipe version?", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Dish 2.0"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            print("Text field: \(String(describing: textField.text))")
            //create new entry in table with current dish_name and specified version title, segue to new recipe
            //make option to make new version based of existing version?
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToRecipeDetails" {
            let recipeDetailsVC = segue.destination as? RecipeDetailsViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRow(at: indexPath) as? RecipeVersionCell
                recipeDetailsVC?.title = cell?.nameLabel.text ?? "Unknown"
            }
            
        }
    }

}

class RecipeVersionCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    
}
