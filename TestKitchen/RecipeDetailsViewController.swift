//
//  RecipeDetailsViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/18/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class RecipeDetailsViewController: UITableViewController {

    var sampleDish = "Towels"
    var sampleIngredients = [String]() //["2 cups flour", "1/2 cup brown sugar", "2 tsp baking powder", "1 tsp salt", "1/2 stick butter", "zest and juice of 1 orange", "1 tsp vanilla extract", "3/4 cup shredded coconut", "1/2 cup almonds"]
    var sampleDirections = [String]() //["Mix Stuff", "Mix other stuff", "preheat something", "check if it's done"]
    
    
    @IBOutlet var recipeTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
       
        // Uncomment if messing with dynamic row height stuff
        // recipeTable.estimatedRowHeight = 44
        // recipeTable.rowHeight = UITableViewAutomaticDimension
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveRecipe))
        saveButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = saveButton
        
        
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless?.data.ofTable("Recipe")
        dataStore?.findFirst({
            (dictionary) -> () in
                let recipeDictionary =  dictionary as! [String : Any]
                self.sampleDish = recipeDictionary["dish_name"] as! String
                let dString = recipeDictionary["direction_list"] as! String
                let iString = recipeDictionary["ingredient_list"] as! String
                self.sampleDirections = dString.components(separatedBy: ",")
                self.sampleIngredients = iString.components(separatedBy: ",")
                DispatchQueue.main.async {
                    self.recipeTable.reloadData()
                }
            },
            error: {
                (fault : Fault?) -> () in
                print("Server reported an error: \(fault ?? Fault() )")
        })
        
        
        
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleIngredients.count + sampleDirections.count + 6 //Title,Picture,Headers(3),Notes
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat()
        
        switch indexPath.row {
        case 0:
            height = 60
        case 1:
            height = 150
        case 2:
            height = 45
        case 3 + sampleIngredients.count:
            height = 45
        default:
            height = 44
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // define higher up? switch?
        let directionsHeaderIndex = 4 + sampleIngredients.count
        let notesHeaderIndex = directionsHeaderIndex + sampleDirections.count + 2
        let addIngredientIndex = directionsHeaderIndex - 1
        let addDirectionIndex = notesHeaderIndex - 1
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleCell
            cell.titleLabel.text = sampleDish
            return cell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageCell
            //set image for that recipe or default "add image"
            cell.recipeImage.image = #imageLiteral(resourceName: "sourd")
            return cell
            
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderCell
            cell.headerLabel.text = "Ingredients"
            cell.addButton.isHidden = true
            cell.addButton.tag = 0 //ingredients tag
            return cell
            
        } else if indexPath.row > 2, indexPath.row < addIngredientIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemCell
            cell.contentLabel.text = "∙ " + sampleIngredients[indexPath.row - 3]
            return cell
            
            
        } else if indexPath.row == addIngredientIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addItemCell", for: indexPath) as! AddItemCell
            cell.addButton.tag = 0
            cell.textField.text = ""
            return cell
            
        } else if indexPath.row == directionsHeaderIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderCell
            cell.headerLabel.text = "Directions"
            cell.addButton.isHidden = true
            cell.addButton.tag = 1 //directions tag TODO:make constants struct here and for tag above
            return cell
            
        } else if  indexPath.row > directionsHeaderIndex, indexPath.row < addDirectionIndex{
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemCell
            cell.contentLabel.text = String(indexPath.row - directionsHeaderIndex) + ". " + sampleDirections[indexPath.row - directionsHeaderIndex - 1]
            return cell
            
        } else if indexPath.row == addDirectionIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addItemCell", for: indexPath) as! AddItemCell
            cell.addButton.tag = 1 //directions tag TODO:make constants struct here and for tag above
            cell.textField.text = ""
            return cell
            
        } else if indexPath.row == notesHeaderIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderCell
            cell.headerLabel.text = "Notes"
            cell.addButton.isHidden = true
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath) as! NotesCell
            cell.textContent.text = "add notes here"
            return cell
        }
        
        
    }
    

    
    @objc func saveRecipe() {
        //save recipe to backendless
        //make save button disabled
    }
    
    
    
    
    @IBAction func addItemButtonPressed(_ sender: Any) {
        if let addButton = sender as? UIButton, let cell = addButton.superview?.superview?.superview as? AddItemCell {
                print(cell.textField.text ?? "")
            if addButton.tag == 0 {
                sampleIngredients.append(cell.textField.text ?? "")
                DispatchQueue.main.async {
                    self.recipeTable.reloadData()
                }
            } else if addButton.tag == 1 {
                sampleDirections.append(cell.textField.text ?? "")
                DispatchQueue.main.async {
                    self.recipeTable.reloadData()
                }
            }
        }
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        //add new blank cell to appropriate section
        //have number/bullet and blinkingcursor/keyboard to indicated typing in content right there
        if let button = sender as? UIButton {
            if button.tag == 0 {
                sampleIngredients.append("")
                DispatchQueue.main.async {
                    self.recipeTable.reloadData()
                }
            } else if button.tag == 1 {
                sampleDirections.append("")
                DispatchQueue.main.async {
                    self.recipeTable.reloadData()
                }
            }
        }
        
        let alert = UIAlertController(title: "New Ingredient", message: nil , preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            
            textField.text = "sand"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let text = alert?.textFields![0].text
            print(text ?? "spooksville")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        //scroll to row and make selected, in edit mode(blinking cursor
        
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
