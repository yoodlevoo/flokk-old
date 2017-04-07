//
//  FriendsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/6/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var friends = [User]() //friends of the main user
    var displayedFriends = [User]()
    
    let transitionRight = SlideRightAnimator()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! FriendsTableViewCell
        
        //get which friend should be referenced
        let friend = displayedFriends[indexPath.row]
        
        cell.profilePhotoView.image = friend.profilePhoto
        cell.fullNameLabel.text = friend.fullName
        cell.handleLabel.text = friend.handle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedFriends.count //ranges from [0,
    }
    
    func loadFriends() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "segueFromFriendsToTabBar" {
            if let tabBar = segue.destination as? MainTabBarController {
                
                tabBar.selectedIndex = 2
            }
        }
    }
}

class FriendsTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!

    
}
