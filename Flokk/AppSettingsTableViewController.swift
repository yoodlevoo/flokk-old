//
//  AppSettingsTableViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 4/13/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class AppSettingsTableViewController: UITableViewController {
    let transitionRight = SlideRightAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as! PersonalProfileNavigationViewController).showNavigationBar()
        (self.tabBarController as! MainTabBarController).hideTabBar()
        //self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func unwindToAppSettings(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromAppSettingsToPersonalProfile" {
            
        }
    }
}
