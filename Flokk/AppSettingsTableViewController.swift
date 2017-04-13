//
//  AppSettingsTableViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 4/13/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class AppSettingsTableViewController: UITableViewController {
    let transitionRight = SlideRightAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    
    @IBAction func unwindToAppSettings(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromAppSettingsToPushNotificationSettings" {
            segue.destination.transitioningDelegate = transitionRight
            
        }
    }
}
