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
    
    var totalFriends = [User]() // The total friends of the main users
    var displayedFriends = [User]() // Just the friends that are being displayed
    
    let transitionRight = SlideRightAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.tabBarController as! MainTabBarController).hideTabBar()
        (self.navigationController as! PersonalProfileNavigationViewController).showNavigationBar()
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
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// Table View Functions
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! FriendsTableViewCell
        
        //get which friend should be referenced
        let friend = displayedFriends[indexPath.row]
        
        cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.width / 2
        cell.profilePhotoView.clipsToBounds = true
        cell.profilePhotoView.image = friend.profilePhoto
        cell.fullNameLabel.text = friend.fullName
        cell.handleLabel.text = friend.handle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedFriends.count //ranges from [0,
    }
}

class FriendsTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
}
