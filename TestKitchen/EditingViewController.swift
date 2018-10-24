//
//  EditingViewController.swift
//  
//
//  Created by Ben Greene on 10/1/18.
//

import UIKit

class EditingViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    var editingText = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = editingText
        //add cancel/save buttons programatically
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? RecipeDetailsViewController {
            destinationVC.notes = textView.text
        }
    }
    

}
