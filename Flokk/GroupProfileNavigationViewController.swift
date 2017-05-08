//
//  GroupProfileNavigationViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 4/26/17.
//  Copyright © 2017 Akaro. All rights reserved.
//

import UIKit

class GroupProfileNavigationViewController: UINavigationController {
    var groupToPass: Group!
    var userToPass: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let groupProfileView = self.viewControllers[0] as? GroupProfileViewController {
            groupProfileView.group = groupToPass
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
