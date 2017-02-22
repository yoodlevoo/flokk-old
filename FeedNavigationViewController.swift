//
//  FeedNavigationViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 2/2/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

//basically only used to change the navigation bar's color
class FeedNavigationViewController: UINavigationController {
    var groupToPass: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = groupToPass.groupName
        print("view did load feed nav")
        
        //self.navigationBar.barTintColor = UIColor.darkGray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func passGroup() {
        if let feedVC = self.viewControllers[0] as? FeedViewController {
            feedVC.group = groupToPass
            self.navigationItem.title = groupToPass.groupName
            
            print("pass to group feed nav")
        }
    }
}
