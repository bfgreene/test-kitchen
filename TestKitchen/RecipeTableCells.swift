//
//  RecipeTableCells.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/30/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import Foundation
import UIKit

class TitleCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
}

class ImageCell: UITableViewCell {
    
    @IBOutlet var recipeImage: UIImageView!
}

class HeaderCell: UITableViewCell {
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var addButton: UIButton!
}

class ItemCell: UITableViewCell {
    
    @IBOutlet var contentLabel: UILabel!
}

class NotesCell: UITableViewCell {
        
    @IBOutlet var textContent: UITextView!
}

class AddItemCell: UITableViewCell {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var addButton: UIButton!
}
