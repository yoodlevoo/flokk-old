//
//  MainTabBarController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 4/5/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    let transitionRight = SlideRightAnimator()
    let transitionUp = SlideUpAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
