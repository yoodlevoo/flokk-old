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
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.refreshControl.addTarget(self, action: #selector(FriendsViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        self.refreshControl.tintColor = TEAL_COLOR
        
        self.tableView.refreshControl = self.refreshControl
        
        if mainUser.friends.count < mainUser.friendIDs.count { // If there are still more friends to load
            self.refreshControl.beginRefreshing()
            
            for uid in mainUser.friendIDs {
                let matches = mainUser.friends.filter({ $0.uid == uid}) // Check if this user has already been loaded
                if matches.count > 0 {
                    continue
                } else { // If the user hasn't already been loaded, continue loading it
                    let userRef = database.ref.child("users").child(uid)
                    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        // Check if snapshot exists, just in case?
                        
                        if let values = snapshot.value as? NSDictionary {
                            let fullName = values["fullName"] as! String
                            let handle = values["handle"] as! String
                            let groupHandles = values["groups"] as? [String : Bool] ?? [String : Bool]()
                            //are we already loading groupHandles? If so, we might as well add it
                            
                            let user = User(uid: uid, handle: handle, fullName: fullName)
                            user.groupIDs = Array(groupHandles.keys)
                            
                            // Create the temp profile photo first
                            let tempProfilePhoto = UIImage.generateProfilePhotoWithText(text: user.getInitials())
                            
                            // Set the profile photo for the user
                            user.profilePhoto = tempProfilePhoto
                            
                            // Add the user to the list of friends
                            mainUser.friends.append(user)
                            self.displayedFriends = mainUser.friends
                            
                            // Refresh the table view
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.refreshControl.endRefreshing()
                            }
                            
                            // Load the profile photo of this user
                            let profilePhotoRef = storage.ref.child("users").child(uid).child("profilePhotoIcon.jpg")
                            profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                                if error == nil {
                                    let profilePhoto = UIImage(data: data!) // load the profile photo from the downloaded data
                                    
                                    // Check AGAIN if the user hasn't been added
                                    let matches = mainUser.friends.filter({ $0.handle == handle}) // Check if this user has already been loaded
                                    if matches.count > 0 { // If there is a match
                                        matches[0].profilePhoto = profilePhoto!
                                        
                                        self.displayedFriends = mainUser.friends
                                        
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                            
                                            // If all of the friends have been loaded
                                            if mainUser.friends.count == mainUser.friendIDs.count {
                                                // Then we can stop the refresh control
                                                self.refreshControl.endRefreshing()
                                            }
                                        }
                                    }
                                }
                            })
                        }
                    })
                }
            }
        }
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
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
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
