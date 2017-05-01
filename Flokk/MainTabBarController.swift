//
//  MainTabBarController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 4/5/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    let transitionRight = SlideRightAnimator()
    let transitionUp = SlideUpAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToGroup(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
        if let friendsView = segue.source as? FriendsViewController {
            self.selectedIndex = 2
        }
    }
}
