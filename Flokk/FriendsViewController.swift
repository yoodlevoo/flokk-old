//
//  FriendsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/6/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var totalFriends = [User]() // The total friends of the main users
    var displayedFriends = [User]() // Just the friends that are being displayed
    
    let transitionRight = SlideRightAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.tabBarController?.hideTabBar()
        self.navigationController?.showNavigationBar()
        //self.navigationController?.navigationBar.isHidden = false
        
        loadFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadFriends() {
        totalFriends = mainUser.friends // Fetch all of the main user's friends
        
        displayedFriends = totalFriends // Set the displayed friends to just show all of the friends for testing
    }
    
    // Simply dismiss this view manually when the back button is pressed, 
    //  as this view is segued to the left not the default right
    /*
    @IBAction func backButtonPressed(_ sender: Any) {
        
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        
        view.window!.layer.add(transition, forKey: kCATransition)
        
        self.navigationController?.hideNavigationBar()
        self.dismiss(animated: false, completion: nil)
    } */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromFriendsToProfile" {
            if let profileView = segue.destination as? ProfileViewController {
                // Get which friend was selected
                let friend = displayedFriends[self.tableView.indexPathForSelectedRow!.row]
                
                profileView.user = friend
            }
        }
    }
}

// Table View Functions
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! UserTableViewCell
        
        //get which friend should be referenced
        let friend = displayedFriends[indexPath.row]
        
        cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.width / 2
        cell.profilePhotoView.clipsToBounds = true
        cell.profilePhotoView.image = friend.profilePhoto
        cell.fullNameLabel.text = friend.fullName
        cell.handleLabel.text = "@\(friend.handle)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedFriends.count //ranges from [0,
    }
}
