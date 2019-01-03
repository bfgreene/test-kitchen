//
//  ConstantsAndExtensions.swift
//  TestKitchen
//
//  Created by Ben Greene on 12/20/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    func alert(withTitle title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

struct Constants {
    static let courseNames = ["Mains", "Sides", "Appetizers", "Bakery", "Desserts", "Other"] 
}
