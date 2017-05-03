//
//  PersonalProfileNavigationViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 5/1/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class PersonalProfileNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = UIColor(colorLiteralRed: 56, green: 161, blue: 159, alpha: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func showNavigationBar() {
        var frame = self.navigationBar.frame
        frame.origin.y = 0 //final value
        UIView.animate(withDuration: 0.5, animations: {
            self.navigationBar.frame = frame
        })
    }
    
    func hideNavigationBar() {
        var frame = self.navigationBar.frame
        frame.origin.y = -frame.size.height //final value
        UIView.animate(withDuration: 0.5, animations: {
            self.navigationBar.frame = frame
        })
    }
}
