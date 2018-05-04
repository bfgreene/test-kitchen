//
//  Recipe.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/3/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import Foundation
import UIKit


class Recipe {
    
    var dish: String
    var title: String
    var image: UIImage?
    var prepTime: Int?
    var cookTime: Int?

    var ingredients: [String]
    var directions: [String]
    
    var pairings: [String]?
    var Notes: String?
    
    init(forDish dish:String, withTitle title: String) {
        self.dish = dish
        self.title = title
        self.ingredients = []
        self.directions = []
    }
}
