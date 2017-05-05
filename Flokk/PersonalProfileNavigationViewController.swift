//
//  PersonalProfileNavigationViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 5/1/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

let NAVIGATION_BAR_ANIMATION_DURATION = 0.25

class PersonalProfileNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationBar.barTintColor = UIColor(colorLiteralRed: 56, green: 161, blue: 159, alpha: 1)
        self.navigationBar.tintColor = UIColor(colorLiteralRed: 22, green: 23, blue: 43, alpha: 1)
        
        self.navigationBar.isHidden = true // Hidden by default
        
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "WhtieArrow")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// Global extension to the UINavigationController class to hide and show the navigation bar
extension UINavigationController {
    func showNavigationBar() {
        self.navigationBar.isHidden = false
        
        UIView.animate(withDuration: NAVIGATION_BAR_ANIMATION_DURATION, animations: {
            self.navigationBar.alpha = 1 // Make the navigation bar opaque
        }, completion: {
            (done: Bool) in
            
            
        })
    }
    
    func hideNavigationBar() {
        UIView.animate(withDuration: NAVIGATION_BAR_ANIMATION_DURATION, animations: {
            self.navigationBar.alpha = 0 // Make the navigation bar completely transparent
        }, completion: {
            (done: Bool) in
            
            self.navigationBar.isHidden = true
        })
    }
}
