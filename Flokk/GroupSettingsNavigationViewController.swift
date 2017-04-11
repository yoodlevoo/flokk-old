//
//  GroupSettingsNavigationViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 4/5/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class GroupSettingsNavigationViewController: UINavigationController {
    weak var groupToPass: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let groupSettingsView = self.viewControllers[0] as! GroupSettingsViewController
        groupSettingsView.group = groupToPass
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
