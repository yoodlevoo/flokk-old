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
    
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
       // self.refreshControl.tintColor =
        
        self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        self.activityIndicator.frame = CGRect(x: self.tableView.frame.width / 2 - 30, y: 0.0, width: 60, height: 60)
//        self.activityIndicator.scale(factor: 1.25)
        //self.activityIndicator.center = self.tableView.center
        self.activityIndicator.color = TEAL_COLOR
        self.activityIndicator.hidesWhenStopped =  true // what does this do
        self.activityIndicator.startAnimating() // Start the activity indicator
        
        //self.tableView.tableHeaderView = self.activityIndicator
        self.tableView.addSubview(self.activityIndicator)
        
        // Add the group image and crop it to a circle
        self.groupImageView.image = group.icon
        self.groupImageView.layer.cornerRadius = self.groupImageView.frame.size.width / 2
        self.groupImageView.clipsToBounds = true
        
        self.groupNameLabel.text = group.name
        
        // Put an overlay over the image so you know you can change it?
        
        // Load all of the friends
        for handle in group.memberHandles { // Iterate through all the member handles
            let userRef = database.ref.child("users").child(handle)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let values = snapshot.value as? NSDictionary { // If the data loaded correctly
                    let fullName = values["fullName"] as! String
                    let groupsDict = values["groups"] as? [String : Bool] ?? [String : Bool]()
                    
                    // Load this user's profile Photo
                    let profilePhotoRef = storage.ref.child("users").child(handle).child("profilePhotoIcon.jpg")
                    profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                        if error == nil { // If there wasn't an error
                            let profilePhoto = UIImage(data: data!)
                            
                            // Load the user
                            let user = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                            user.groupIDs = Array(groupsDict.keys)
                            
                            self.members.append(user) // Add it to members array
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.activityIndicator.stopAnimating()
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
        
        cell.tag = indexPath.row // Set the cell's tag so we know which tag was selected - only used in tableView(..., didSelectAt: ...)
        
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
            if let inviteFriendsView = segue.destination as? InviteFriendsViewController {
                inviteFriendsView.group = self.group
                
                // Load all of the user's friends
                // Should probably do this in the viewDidLoad of inviteFriends
                
            }
        } else if segue.identifier == "segueFromGroupSettingsToProfile" {
            if let profileView = segue.destination as? ProfileViewController {
                let user = self.members[(self.tableView.indexPathForSelectedRow?.row)!]
                
                profileView.user = user
                profileView.userHandle = user.handle
            }
        }
    }
    
    func loadUsers() { // Load more members?
        
    }
}

// Put this somewhere else
extension UIActivityIndicatorView {
    func scale(factor: CGFloat) {
        guard factor > 0.0 else { return }
        
        transform = CGAffineTransform(scaleX: factor, y: factor)
    }
}
