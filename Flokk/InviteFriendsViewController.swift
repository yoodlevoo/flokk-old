//
//  InviteFriendsTableViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 5/29/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

// If there is no search, then just show some of the user's friends not in this group
class InviteFriendsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var searchBar: UISearchBar!
    
    var users = [User]()
    var mainUserFriends = [User]() // The main user's friends that have been loaded in for this view
    var selectedUsers = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchContent: String!
    
    weak var group: Group! // The according group
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround() // Hides the search bar when tapped around
        self.definesPresentationContext = true // Set this to prevent the search bar from not disapppearing
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.keyboardAppearance = .dark
        
        self.tableView.tableHeaderView = self.searchController.searchBar

        self.searchContent = ""
        
        //self.users = self.mainUserFriends // If there isn't a search, set it to the main user's friends
        
        // You can only invite your friends to a group, so iterate over only them
        for handle in mainUser.friendHandles {
            if !group.memberHandles.contains(handle) && !group.invitedUsers.contains(handle) { // If this user isn't already a member of the group or already invited, continue to load it
                let userRef = database.ref.child("users").child(handle)
                
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let values = snapshot.value as? NSDictionary {
                        let fullName = values["fullName"] as! String
                        
                        // Download the profile photo
                        let profilePhotoRef = storage.ref.child("users").child(handle).child("profilePhotoIcon.jpg")
                        profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                            if error == nil {
                                let profilePhoto = UIImage(data: data!)
                                
                                let user = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                                
                                self.mainUserFriends.append(user)
                                
                                self.users = self.mainUserFriends
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            } else {
                                print(error!)
                            }
                        })
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Called when the user is done selecting all of the users and wants to invite them all
    // Should there be a max amount of users that can be selected at a time?
    @IBAction func inviteAllUsersPressed(_ sender: Any) {
        // Check if no users have been invited and pop up something
        if self.selectedUsers.count == 0 {
            // Pop up something telling the user no users have been selected
            
            return // Will this prevent the rest of the function being called?
        }
        
        let groupRef = database.ref.child("groups").child(self.group.id)
        
        // Notify each user that they have been invited
        for user in self.selectedUsers {
            let handle = user.handle
            
            // Tell the groups database that this user has been invited
            groupRef.child("invitedUsers").child(handle).setValue(NSDate.timeIntervalSinceReferenceDate)
            
            let userRef = database.ref.child("users").child(handle)
            userRef.child("groupInvites").child(self.group.id).setValue(NSDate.timeIntervalSinceReferenceDate) // Set this group as an incoming invite in the user's database
            
            // Create a group invite notification for this user
            let notificationKey = database.ref.child("notifications").child(handle).childByAutoId().key // Generate a UID for this notification
            let notificationRef = database.ref.child("notifications").child(handle).child(notificationKey)
            
            // Set the data for this notification
            notificationRef.child("type").setValue(NotificationType.GROUP_INVITE.rawValue) // Set the notification type
            notificationRef.child("sender").setValue(mainUser.handle) // Set who has invited this user
            notificationRef.child("groupID").setValue(self.group.id) // Set the group's ID this user has been invited to
            notificationRef.child("timestamp").setValue(NSDate.timeIntervalSinceReferenceDate) // Set the time this invite has been sent
            
            self.group.invitedUsers.append(handle) // Add these users to the local invited users array
        }
        
        // Go back to group settings
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

// Table View Functions
extension InviteFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! InviteFriendsTableViewCell
        let user = self.users[indexPath.row]
        
        // Add the profile photo and make it crop to a circle
        cell.profilePhotoView.image = user.profilePhoto
        cell.profilePhotoView.clipsToBounds = true
        cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.width / 2
        
        cell.fullNameLabel.text = user.fullName
        cell.handleLabel.text = user.handle
        
        if self.selectedUsers.contains(user) { // If the user has been selected to be invited
            cell.accessoryType = .checkmark
            cell.invited = true
        } else {
            cell.invited = false
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! InviteFriendsTableViewCell
        
        if self.selectedUsers.contains(user) { // If this user has already been selected
            // Deselect it
            cell.accessoryType = .none
            cell.invited = false
            self.selectedUsers.remove(at: selectedUsers.index(of: user)!)
        } else { // If the user has not already been selected
            // Select it
            cell.accessoryType = .checkmark
            self.selectedUsers.append(user)
        }
    }
}

// Search bar functions
extension InviteFriendsViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchRef = database.ref.child("users").queryOrdered(byChild: "fullName").queryStarting(atValue: searchBar.text) //insert queryLimited
        
        // Clear the users on every new search
        self.users.removeAll()
        self.users = self.selectedUsers // Always show the selected Users
        self.tableView.reloadData()
        
        // Load in the data about the users returned by the search query
        searchRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for each in values {
                    let searchCount = searchBar.text?.characters.count // The number of characters in this search to compare
                    
                    // Get the user data
                    let handle = each.key as! String // Get the handle
                    
                    // Check if this user is a friend of the main user before acting on it
                    if mainUser.friendHandles.contains(handle) && !self.group.memberHandles.contains(handle) && !self.group.invitedUsers.contains(handle) {
                        // If so, continue loading
                        let userData = values[handle] as! Dictionary<String, Any> // Get all the subset of data for this user
                        let fullName = userData["fullName"] as! String // Get the user's full name from the subset of data
                        
                        // Make sure we're not getting users that don't match the search
                        let range = fullName.startIndex..<(fullName.index(fullName.startIndex, offsetBy: searchCount!))
                        let fullNameSplit = fullName.substring(with: range) // Get just the characters
                        
                        if searchBar.text == fullNameSplit { // If the search equates to this users full name
                            // Retrieve the profile photo
                            let profilePhotoRef = storage.ref.child("users").child(handle).child("profilePhotoIcon.jpg")
                            profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                                if error == nil { // If there wasn't an error
                                    let profilePhoto = UIImage(data: data!) // Create an image from the data retrieved
                                    
                                    // Create the user
                                    let user = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                                    
                                    // Add it to the list of users
                                    self.users.append(user)
                                    
                                    // Update the data table
                                    self.tableView.reloadData()
                                } else { // If there was an error
                                    // Handle the error
                                    print(error!)
                                }
                            })
                        } else { // If the search doesn't equate to this user
                            // Do nothing
                        }
                    } else { // If this user isn't friends with the main user
                        // Do nothing
                    }
                }
            }
        })
        
        self.searchContent = searchBar.text
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.users = self.selectedUsers + self.mainUserFriends
        self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" { // If the user isn't searching anything, fill it with the user's friends
            self.users = mainUserFriends
            self.tableView.reloadData()
            //self.searchBar.setShowsCancelButton(false, animated: true)
        }
    }
    
    // Overrides the original function from hideKeyboardWhenTappedAround
    override func dismissKeyboard() {
        self.searchController.dismissKeyboard()
        self.searchController.resignFirstResponder()
    }
}

class InviteFriendsTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    //@IBOutlet weak var invitedView: UIImageView!
    
    var invited = false // If this user has been selected to be invited
}
