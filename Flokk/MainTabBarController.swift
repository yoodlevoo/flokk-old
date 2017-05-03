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
    
    func showTabBar() {
        var frame = self.tabBar.frame
        frame.origin.y = self.view.frame.size.height - (frame.size.height)
        UIView.animate(withDuration: 0.5, animations: {
            self.tabBar.frame = frame
            print("y: \(frame.origin.y)")
        })
        
        self.tabBar.isHidden = false
    }
    
    func hideTabBar() {
        var frame = self.tabBar.frame
        frame.origin.y = self.view.frame.size.height + (frame.size.height)
        UIView.animate(withDuration: 0.5, animations: {
            self.tabBar.frame = frame
            
        }, completion: { (value: Bool) in
            //hide the tab bar once this animation is completed so the tableview is formatted correctly
            self.tabBar.isHidden = true
        })
    }

    @IBAction func unwindToGroup(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
        if let friendsView = segue.source as? FriendsViewController {
            self.selectedIndex = 2
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromPersonalProfileToAppSettings" {
            
        }
    }
}
