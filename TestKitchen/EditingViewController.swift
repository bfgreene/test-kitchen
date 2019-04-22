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
    var indexPath: IndexPath?
    var delegate: recipeUpdator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = editingText
        textView.becomeFirstResponder()
        
        //add cancel and save buttons programatically
        self.navigationItem.hidesBackButton = true
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditingViewController.cancel(sender:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditingViewController.save(sender:)))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func cancel(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func save(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
        delegate?.updateCell(newContent: textView.text, forCellAt: indexPath)
    }
    
    
    
    
}
