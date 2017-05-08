//
//  ProfileNavigationViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 4/20/17.
//  Copyright © 2017 Akaro. All rights reserved.
//

import UIKit

class ProfileNavigationViewController: UINavigationController {
    var userToPass: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get this Navigation controller's sub view
        if let profileView = self.viewControllers[0] as? ProfileViewController {
            profileView.user = userToPass
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
