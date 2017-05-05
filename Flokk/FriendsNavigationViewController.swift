//
//  FriendsNavigationViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/27/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class FriendsNavigationViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.isHidden = true
        self.showNavigationBar() // Just to animate it
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
