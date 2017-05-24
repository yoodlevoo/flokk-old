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
    @IBOutlet weak var settings: UIButton!

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
        
        loadFriends() // Load the user's friends - should we really do this here?
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.hideNavigationBar()
        //self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.showTabBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func editProfile(_ sender: Any) {
    }
    
    @IBAction func friendsButtonPressed(_ sender: Any) {
        
    }
    
    /*
    @IBAction func friendsButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let friendsView: FriendsNavigationViewController = storyboard.instantiateViewController(withIdentifier: "FriendsNavigationViewController") as! FriendsNavigationViewController
        
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        
        view.window!.layer.add(transition, forKey: kCATransition)
        present(friendsView, animated: false, completion: nil)
        
    } */
    
    @IBAction func unwindToPersonalProfile(segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.tabBarController?.hideTabBar()
        
        if segue.identifier == "segueFromPersonalProfileToFriends" {
            if let friendsNav = segue.destination as? FriendsNavigationViewController {
                friendsNav.transitioningDelegate = transitionLeft
                
            }
        }
    }
    
    // try to only run this once
    func loadFriends() {
        for handle in mainUser.friendHandles {
            let userRef = database.ref.child("users").child(handle)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                // Check if snapshot exists, just in case?
                
                if let values = snapshot.value as? NSDictionary {
                    let fullName = values["fullName"] as! String
                    //are we already loading groupHandles? If so, we might as well add it
                    
                    // Load the profile photo of this user
                    let profilePhotoRef = storage.ref.child("users").child(handle).child("profilePhoto").child("\(handle).jpg")
                    profilePhotoRef.data(withMaxSize: 1 * 2048 * 2048, completion: { (data, error) in
                        if error == nil {
                            let profilePhoto = UIImage(data: data!) // load the profile photo from the downloaded data
                            
                            let user = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                            
                            // Add this user to the main user's friends array
                            mainUser.friends.append(user)
                        }
                    })
                }
            })
        }
    }
}
