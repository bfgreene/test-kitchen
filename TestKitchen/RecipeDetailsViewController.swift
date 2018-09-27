//
//  RecipeDetailsViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/18/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class RecipeDetailsViewController: UITableViewController, UITextViewDelegate {

    var recipeID = String() //use this or send entire recipe? consider what happends when updating/adding new versions

    var recipe = [String : Any]()
    var ingredients = [String]()
    var directions = [String]()
    var notes = String()
    
    let backendless = Backendless.sharedInstance()
    
    @IBOutlet var recipeTable: UITableView!
    
    /**
     *  Grab recipe details from db
     *  Additional UI setup
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        ingredients = (recipe["ingredient_list"] as? String)?.components(separatedBy: ",") ?? []
        directions = (recipe["direction_list"] as? String)?.components(separatedBy: ",") ?? []
        notes = recipe["notes"] as? String ?? ""
       
        setupUI()
    }

    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count + directions.count + 8 //Title,Picture,Headers(3),Notes,addCells(2)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat()
        
        switch indexPath.row {
        case 0:
            height = 60
        case 1:
            height = 150
        default:
            height = UITableViewAutomaticDimension
            //height = getTextViewHeight(text: array[indexPath.row], font: UIFont.systemFont(ofSize: 14))
        }
        return height
    }
    
    
    
    /**
     *  Determine which custom cell to deque based on position in table
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // define higher up? switch?
        let directionsHeaderIndex = 4 + ingredients.count
        let notesHeaderIndex = directionsHeaderIndex + directions.count + 2
        let addIngredientIndex = directionsHeaderIndex - 1
        let addDirectionIndex = notesHeaderIndex - 1
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleCell
            cell.titleLabel.text = recipe["dish_name"] as? String
            return cell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageCell
            //set image for that recipe or default "add image"
            cell.recipeImage.image = #imageLiteral(resourceName: "sourd")
            return cell
            
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderCell
            cell.headerLabel.text = "Ingredients"
            return cell
            
        } else if indexPath.row > 2, indexPath.row < addIngredientIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemCell
            cell.contentLabel.text = "∙ " + ingredients[indexPath.row - 3]
            return cell
            
            
        } else if indexPath.row == addIngredientIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addItemCell", for: indexPath) as! AddItemCell
            cell.addButton.tag = 0
            cell.textField.text = ""
            return cell
            
        } else if indexPath.row == directionsHeaderIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderCell
            cell.headerLabel.text = "Directions"
            return cell
            
        } else if  indexPath.row > directionsHeaderIndex, indexPath.row < addDirectionIndex{
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemCell
            cell.contentLabel.text = String(indexPath.row - directionsHeaderIndex) + ". " + directions[indexPath.row - directionsHeaderIndex - 1]
            return cell
            
        } else if indexPath.row == addDirectionIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addItemCell", for: indexPath) as! AddItemCell
            cell.addButton.tag = 1 //directions tag TODO:make constants struct here and for tag above
            cell.textField.text = ""
            return cell
            
        } else if indexPath.row == notesHeaderIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderCell
            cell.headerLabel.text = "Notes"
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath) as! NotesCell
            if notes == "" {
                //add placeholder text
            } else {
                cell.textContent.text = notes
            }
            return cell
        }
        
        
    }
    

    
    @objc func saveRecipe() {
        //make save button disabled
        let dataStore = self.backendless?.data.ofTable("Recipe")
        recipe["ingredient_list"] = ingredients.map{$0}.joined(separator: ",")
        recipe["direction_list"] = directions.map{$0}.joined(separator: ",")
        recipe["notes"] = notes
        //recipe["image_path] = someImagePath
        
        dataStore?.save(recipe,
                        response: {
                            (updatedRecipe) -> () in
                            print("Recipe saved")
                            //make "success" popup flash
                            //set flag for versions to reload.. or send it back on unwind
        },
                        error: {
                            (fault : Fault?) -> () in
                            print("Server reported an error: \(String(describing: fault))")
                            //make alert of error
        })
        
    }
    
    
    
    @IBAction func addItemButtonPressed(_ sender: Any) {
        if let addButton = sender as? UIButton, let cell = addButton.superview?.superview?.superview as? AddItemCell {
            if addButton.tag == 0 {
                ingredients.append(cell.textField.text ?? "")
                DispatchQueue.main.async {
                    self.recipeTable.reloadData()
                }
            } else if addButton.tag == 1 {
                directions.append(cell.textField.text ?? "")
                DispatchQueue.main.async {
                    self.recipeTable.reloadData()
                }
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        notes = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 5000 //arbitrary 5000 character limit for notes... needs to be < 21000 for backendless
    }
    
    //Source: https://stackoverflow.com/a/44463571
    func getTextViewHeight(text: String, font: UIFont) -> CGFloat {
        let textSize: CGSize = text.size(withAttributes: [NSAttributedStringKey.font: font])
        var height: CGFloat = (textSize.width / UIScreen.main.bounds.width) * font.pointSize
        
        var lineBreaks: CGFloat = 0
        if text.contains("\n") {
            for char in text{
                if char == "\n" {
                    lineBreaks += (font.pointSize + 12)
                }
            }
        }
        
        height += lineBreaks
        return height + 60
    }
    
    
    /*
     *  General additional UI setup:
     *  allow for dynamic row heights
     *  add save button programatically
     *  allow for swipe keyboard dismiss
     */
    func setupUI() {
        //for dynamic row heights
        recipeTable.estimatedRowHeight = 45
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveRecipe))
        saveButton.isEnabled = true
        self.navigationItem.rightBarButtonItem = saveButton
        
        recipeTable.keyboardDismissMode = .onDrag
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

}
