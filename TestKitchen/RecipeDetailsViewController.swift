//
//  RecipeDetailsViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/18/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class RecipeDetailsViewController: UITableViewController {

    var sampleIngredients = ["2 cups flour", "1/2 cup brown sugar", "2 tsp baking powder", "1 tsp salt", "1/2 stick butter", "Zest and juice of 1 orange", "1 tsp vanilla extract", "3/4 cup shredded coconut", "1/2 cup almonds"]
    var sampleDirections = ["Mix Stuff", "Mix other stuff", "preheat something", "check if it's done"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleIngredients.count + sampleDirections.count + 6 //Title,Picture,Headers(3),Notes
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        

        // make index constants for cleaner ifs
        // define higher up?
        let directionsHeaderIndex = 3 + sampleIngredients.count
        let notesHeaderIndex = directionsHeaderIndex + sampleDirections.count + 1
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        } else if indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
        } else if indexPath.row == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
        } else if indexPath.row > 2, indexPath.row < directionsHeaderIndex {
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        } else if indexPath.row == directionsHeaderIndex {
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
        } else if  indexPath.row > directionsHeaderIndex, indexPath.row < notesHeaderIndex{
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        } else if indexPath.row == notesHeaderIndex {
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath)
        }
        
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
