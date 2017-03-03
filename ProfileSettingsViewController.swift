//
//  ProfileSettingsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/3/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var editName: UITextField!
    
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editPassword: UITextField!
    @IBOutlet weak var editUsername: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    var mainUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backPage(_ sender: AnyObject) {
    }
    /*
    @IBAction func logoutBttn(_ sender: AnyObject) {
    } */
    
    @IBAction func saveBttn(_ sender: AnyObject) {
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //USE SEGUE IDENTIFIERS
        if let tabBar = segue.destination as? UITabBarController {
            if let profileView = tabBar.viewControllers?[2] as? ProfileViewController {
                //profileView.mainUser = mainUser
            }
            
            tabBar.selectedIndex = 2
        }
    }
}
