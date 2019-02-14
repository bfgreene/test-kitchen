//
//  RecipeDetailsViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/18/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class RecipeDetailsViewController: UITableViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, recipeUpdator {

    let backendless = Backendless.sharedInstance()
    var recipeID = String() //use this or send entire recipe? consider what happends when updating/adding new versions
    var recipe = [String : Any]()
    var ingredients = [String]()
    var directions = [String]()
    var notes = String()
    var dishImage: UIImage?
    var imagePath: String?
    var directionsHeaderIndex, notesHeaderIndex, addIngredientIndex, addDirectionIndex, firstIngredientIndex, firstDirectionIndex : Int!
 
    @IBOutlet var recipeTable: UITableView!
    
    
    
    /**
     *  Grab recipe details from db
     *  Additional UI setup
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeData()
        updateReferenceIndicies()
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
            let width = tableView.frame.width
            height = imagePath != nil ? width : 150
        default:
            height = UITableViewAutomaticDimension
        }
        return height
    }
    
    
    
    /**
     * Determine which custom cell to deque based on position in table
     *
     * Title
     * Image
     * Ingredients
     * [Ingredient List]
     * New Ingredient Input
     * Directions
     * [Direction List]
     * New Direction Input
     * Notes
     * [Notes]
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        updateReferenceIndicies()
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleCell
            cell.titleLabel.text = recipe["dish_name"] as? String
            return cell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageCell
            if imagePath != nil {
                cell.backgroundAddButton.isHidden = true
                cell.addPhotoButton.isHidden = true
                cell.spinner.startAnimating()
                if let img = dishImage {
                    cell.backgroundImageView.image = img
                    //cell.contentView.sendSubview(toBack: cell.backgroundImageView)
                    cell.photoSettingsButton.clipsToBounds = true
                    cell.photoSettingsButton.layer.cornerRadius = 5
                }
            } else {
                cell.addPhotoButton.isHidden = false
                cell.backgroundAddButton.isHidden = false
            }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemCell
            cell.contentLabel.text = notes
            return cell
        }
        
        
    }
    

    
    @objc func saveRecipe() {
        //make save button disabled
        let dataStore = self.backendless?.data.ofTable("Recipe")
        recipe["ingredient_list"] = ingredients.map{$0}.joined(separator: ",")
        recipe["direction_list"] = directions.map{$0}.joined(separator: ",")
        recipe["notes"] = notes
        recipe["image_path"] = imagePath
        
        dataStore?.save(recipe,
                        response: {
                            (updatedRecipe) -> () in
                            //TODO: make "success" popup flash
        },
                        error: {
                            (fault : Fault?) -> () in
                            self.alert(withTitle: "Server Error", msg: fault?.message ?? "Unknown Error")
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
    

    /*
     * Action Sheet for selecting dish image from gallery/camera
     */
    @IBAction func addPhotoButtonPressed(_ sender: Any) {
        var prompt = "Choose Dish Image "
        if let btn = sender as? UIButton {
            if btn.tag == 1 {
                prompt = "Replace Dish Image"
            }
        }
            
        let alert = UIAlertController(title: prompt, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in self.openGallery()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No Camera Access", message: "You have not given access to the camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No Gallery Access", message: "You have not given access to the photo gallery", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dishImage = chosenImage
            saveImage(img: chosenImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func saveImage(img: UIImage) {
        if let imageCell = recipeTable.cellForRow(at: IndexPath(row: 1, section: 0)) as? ImageCell {
            imageCell.backgroundAddButton.isHidden = true
            imageCell.addPhotoButton.isHidden = true
            imageCell.spinner.startAnimating()
        }
        let imgFile = UIImageJPEGRepresentation(img, 1)
        let filePath = "images/img_\(Date().timeIntervalSince1970).jpg" //TODO: add username in here incase two users add image same second
        backendless?.file.saveFile(filePath, content: imgFile, response: { (file: BackendlessFile?) in
            self.imagePath = file?.fileURL
            DispatchQueue.main.async {
                self.recipeTable.reloadData()
            }
            self.saveRecipe()
        }, error: { (fault: Fault?) in
            self.alert(withTitle: "Error", msg: fault?.message ?? "Image failed to save.")
        })
    }
    
    func getImage(withURL url: String) {
        if let fileURL = URL(string: url) {
            downloadImage(from: fileURL)
        }
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.dishImage = UIImage(data: data)
                self.recipeTable.reloadData()
            }
            
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    
    
    
    /*
     *  General additional UI setup:
     *  allow for dynamic row heights
     *  add save button programatically
     *  allow for swipe keyboard dismiss
     */
    func setupUI() {
        recipeTable.estimatedRowHeight = 45
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveRecipe))
        saveButton.isEnabled = true
        self.navigationItem.rightBarButtonItem = saveButton
        
        recipeTable.keyboardDismissMode = .onDrag
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let firstIngredientIndex = 3
        let firstDirectionIndex = firstIngredientIndex + ingredients.count + 2
        
        switch indexPath.row {
        case firstIngredientIndex..<firstIngredientIndex+ingredients.count :
            return true
        case firstDirectionIndex..<firstDirectionIndex+directions.count:
            return true
        default:
            return false
        }
    }
 

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // TODO: Make constants for indexes
            // TODO: update numbers of directions if direction deleted
            if indexPath.row < ingredients.count + 3 {
                ingredients.remove(at: (indexPath.row-3))
            } else {
                directions.remove(at: (indexPath.row-ingredients.count-5))
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            recipeTable.reloadData() //added to renumber directions upon deletion
        }
    }
    
    /*
     * recipeUpdator protocol functions
     */
    func updateCell(newContent: String, forCellAt indexPath: IndexPath?) {
        
        if indexPath != nil && indexPath!.row < recipeTable.numberOfRows(inSection: 0) {
            let tableIndex = indexPath!.row
            var dataArrayIndex = Int()
            if tableIndex >= firstIngredientIndex && tableIndex < (firstIngredientIndex+ingredients.count) {
                dataArrayIndex = tableIndex - firstIngredientIndex
                ingredients[dataArrayIndex] = newContent
            } else if tableIndex >= firstDirectionIndex && tableIndex < (firstDirectionIndex+directions.count) {
                dataArrayIndex = tableIndex - firstDirectionIndex
                directions[dataArrayIndex] = newContent
            } else if tableIndex == notesHeaderIndex + 1 {
                notes = newContent
            }
            
            DispatchQueue.main.async {
                self.recipeTable.reloadData()
            }
        }
        
    }
    
    func removePrefix(ofString text: String, atIndex itemIndex: Int) -> String {
        var substringIndex = text.startIndex
        if itemIndex >= firstIngredientIndex && itemIndex < (firstIngredientIndex+ingredients.count) {
            substringIndex = text.index(text.startIndex, offsetBy: 2)
        } else if itemIndex >= firstDirectionIndex && itemIndex < (firstDirectionIndex+directions.count) {
            substringIndex = text.index(text.startIndex, offsetBy: 3)
        }
        
        return String(text[substringIndex...])
    }
    
    func initializeData() {
        ingredients = (recipe["ingredient_list"] as? String)?.components(separatedBy: ",") ?? []
        if ingredients.count==1, ingredients[0].count == 0 {ingredients = []}
        directions = (recipe["direction_list"] as? String)?.components(separatedBy: ",") ?? []
        if directions.count == 1, directions[0].count == 0 {directions = []}
        imagePath = recipe["image_path"] as? String
        notes = recipe["notes"] as? String ?? ""
        if let path = imagePath {
            getImage(withURL: path)
        }
    }
    
    func updateReferenceIndicies() {
        firstIngredientIndex = 3
        directionsHeaderIndex = 4 + ingredients.count
        firstDirectionIndex = directionsHeaderIndex + 1
        notesHeaderIndex = directionsHeaderIndex + directions.count + 2
        addIngredientIndex = directionsHeaderIndex - 1
        addDirectionIndex = notesHeaderIndex - 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToEditor" {
            if let editingVC = segue.destination as? EditingViewController {
                let indexPath = recipeTable.indexPathForSelectedRow
                let selectedCell = recipeTable.cellForRow(at: indexPath!) as? ItemCell
                let text = removePrefix(ofString: (selectedCell?.contentLabel.text)!, atIndex: indexPath!.row)
                editingVC.editingText = text
                editingVC.delegate = self
                editingVC.indexPath = indexPath
            }
        }
    }


}

protocol recipeUpdator {
    func updateCell(newContent: String, forCellAt indexPath: IndexPath?)
}
