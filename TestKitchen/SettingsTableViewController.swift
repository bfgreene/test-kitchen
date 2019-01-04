//
//  SettingsTableViewController.swift
//  TestKitchen
//
//  Created by Ben Greene on 9/5/18.
//  Copyright © 2018 bfgreene. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    let backendless = Backendless.sharedInstance()!
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        backendless.userService.logout({
            (result : Any?) -> Void in
            print("User has been logged out")
            self.dismiss(animated: true, completion: nil)
        },
                                       error: {
                                        (fault : Fault?) -> Void in
                                        print("Server reported an error: \(String(describing: fault?.description))")
        })
    }

}


class DeveloperInfoView: UIViewController {
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
