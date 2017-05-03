//
//  PushNotificationsSettingsTableViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 4/12/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class PushNotificationsSettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        (self.tabBarController as! MainTabBarController).hideTabBar()
    }

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    } */
}
