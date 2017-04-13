//
//  FeedNavigationViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 2/2/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit
import AHKNavigationController

//basically only used to change the navigation bar's color
class FeedNavigationViewController: UINavigationController {
    weak var groupToPass: Group! //weak b/c I don't want this object to be retained
    
    var isPushingViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.title = groupToPass.groupName
        let feedVC = self.viewControllers[0] as! FeedViewController
        feedVC.group = groupToPass
        //print("view did load feed nav")
        
        //self.navigationBar.barTintColor = UIColor.darkGray
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
