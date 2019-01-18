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
    
    /**
     * Log out user and return to login view
     */
    @IBAction func logOutButtonPressed(_ sender: Any) {
        backendless.userService.logout({
            (result : Any?) -> Void in
            self.dismiss(animated: true, completion: nil)
        },
        error: {
            (fault : Fault?) -> Void in
            self.alert(withTitle: "Error", msg: "Could not log out")
        })
    }
    
    /**
     * Delete account after confirmation from user, return to login view
     */
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to delete your account?", message: "This action cannot be undone", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            let user = self.backendless.userService.currentUser
            let dataStore = self.backendless.data.ofTable("Users")
            if let userId = user?.objectId {
                print("userId: \(userId)")
                _ = dataStore?.remove(byId: String(userId))
                self.logOutButtonPressed(self)
            } else {
                self.alert(withTitle: "Error", msg: "Account could not be deleted.")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

/**
 * Small view with developer information
 */
class DeveloperInfoView: UIViewController {
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
