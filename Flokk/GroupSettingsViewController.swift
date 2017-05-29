//
//  GroupSettingsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/4/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit

class GroupSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UINavigationItem!
    
    let transitionUp = SlideUpAnimator()
    
    weak var group: Group!
    var currentUserIndex: Int!
    var loadMoreUsersAmount = 10 // The amount to load each time we scroll down
    
    var members = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Add the group image and crop it to a circle
        self.groupImageView.image = group.groupIcon
        self.groupImageView.layer.cornerRadius = self.groupImageView.frame.size.width / 2
        self.groupImageView.clipsToBounds = true
        
        self.groupNameLabel.text = group.groupName

        self.tabBar.title = group.groupName
        
        // Put an overlay over the image so you know you can change it?
        
        // Load all of the friends
        for handle in group.memberHandles { // Iterate through all the member handles
            let userRef = database.ref.child("users").child(handle)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let values = snapshot.value as? NSDictionary { // If the data loaded correctly
                    let fullName = values["fullName"] as! String
                    
                    // Load this user's profile Photo
                    let profilePhotoRef = storage.ref.child("users").child(handle).child("profilePhoto").child("\(handle).jpg")
                    profilePhotoRef.data(withMaxSize: 1 * 2048 * 2048, completion: { (data, error) in
                        if error == nil { // If there wasn't an error
                            let profilePhoto = UIImage(data: data!)
                            
                            // Load the user
                            let user = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                            
                            self.members.append(user) // Add it to members array
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } else { // If there was an error
                            print(error!)
                        }
                    })
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Pagination? Load the first 10 users
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! UserTableViewCell
        let user = self.members[indexPath.row] // Get the corresponding user
        
        // Add the image and crop it to a circle
        cell.profilePhotoView.image = user.profilePhoto
        cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.width / 2
        cell.profilePhotoView.clipsToBounds = true
        
        cell.fullNameLabel.text = user.fullName
        cell.handleLabel.text = user.handle
        
        return cell
    }
    
    
    @IBAction func inviteFriendButtonPressed(_ sender: Any) {
        /*
        // Check if any friends not in this group are loaded - mainUser.friends. actually nah
        let inviteFriendsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InviteFriendsTableViewController") as! InviteFriendsTableViewController
        var loadedUsers = 0
        
        
        }
        
        self.present(inviteFriendsView, animated: true, completion: nil) */
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromGroupSettingsToInviteFriends" {
            if let inviteFriendsView = segue.destination as? InviteFriendsTableViewController {
                for handle in mainUser.friendHandles {
                    if !group.memberHandles.contains(handle) { // If this user isn't already a member
                        let userRef = database.ref.child("users").child(handle)
                        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            if let values = snapshot.value as? NSDictionary {
                                let fullName = values["fullName"] as! String
                                
                                let profilePhotoRef = storage.ref.child("users").child(handle)
                                profilePhotoRef.data(withMaxSize: 1 * 2048 * 2048, completion: { (data, error) in
                                    if error == nil {
                                        let profilePhoto = UIImage(data: data!)
                                        
                                        let user = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                                        
                                        inviteFriendsView.mainUserFriends.append(user)
                                    }
                                })
                            }
                        })
                    }
                }
            }
        }
    }
    
    func loadUsers() { // Load more members?
        
    }
}
