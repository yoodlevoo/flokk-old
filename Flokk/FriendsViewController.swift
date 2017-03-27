//
//  FriendsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/6/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {
    let transitionBackwards = SlideBackwardAnimator(right: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromFriendsToTabBar" {
            if let tabBar = segue.destination as? UITabBarController {
                tabBar.transitioningDelegate = transitionBackwards
                
                tabBar.selectedIndex = 2
            }
        }
    }
}
