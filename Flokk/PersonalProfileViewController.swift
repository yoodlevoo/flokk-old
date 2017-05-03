//
//  PersonalProfileViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/5/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class PersonalProfileViewController: UIViewController {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!

    var user: User!
    
    let transitionLeft = SlideLeftAnimator()

    override func viewDidLoad() {
        super.viewDidLoad()

        // This normally won't be here - only for testing
        user = mainUser
        
        profilePic.image = user.profilePhoto
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        
        name.text = user.fullName
        username.text = "@\(user.handle)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as! PersonalProfileNavigationViewController).hideNavigationBar()
        //self.navigationController?.navigationBar.isHidden = true
        (self.tabBarController as! MainTabBarController).showTabBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func editProfile(_ sender: Any) {
    }
    
    @IBOutlet weak var settings: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromProfileToFriends" {
            if let friendsNav = segue.destination as? FriendsViewController {
                friendsNav.transitioningDelegate = transitionLeft
            }
        }
    }
}
