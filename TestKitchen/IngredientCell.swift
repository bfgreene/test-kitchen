//
//  IngredientCell.swift
//  TestKitchen
//
//  Created by Ben Greene on 5/14/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class IngredientCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
