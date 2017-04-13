//
//  ProfileViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/4/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var groupNumber: UILabel!

    //var mainUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePic.image = mainUser.profilePhoto
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        
        username.text = mainUser.handle
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func followBttn(_ sender: AnyObject) {
    }
    @IBAction func profileSettings(_ sender: AnyObject) {
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profileSettingsView = segue.destination as? ProfileSettingsViewController {
            
        }
    }
}
