//
//  InviteFriendsTableViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 5/26/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

// If there is no search, then just show some of the user's friends not in this group
class InviteFriendsTableViewController: UITableViewController, UISearchResultsUpdating {
    var users = [User]()
    var mainUserFriends = [User]()
    var selectedUsers = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchContent: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.delegate = self
        
        self.searchContent = ""
        
        self.users = self.mainUserFriends // If there isn't a search, set it to the user's friends
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! UserTableViewCell
        let user = users[indexPath.row]
        
        // Add the profile photo and make it crop to a circle
        cell.profilePhotoView.image = user.profilePhoto
        cell.profilePhotoView.clipsToBounds = true
        cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.width / 2
        
        cell.fullNameLabel.text = user.fullName
        cell.handleLabel.text = user.handle

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        
        if selectedUsers.contains(user) {
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            selectedUsers.remove(at: selectedUsers.index(of: user)!)
        } else {
            cell?.accessoryType =  UITableViewCellAccessoryType.none
            selectedUsers.append(user)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension InviteFriendsTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let testRef = database.ref.child("users").queryOrdered(byChild: "fullName").queryStarting(atValue: searchBar.text) //insert queryLimited
        
        // Clear the users on every new search
        users.removeAll()
        users = selectedUsers // Always show the selected Users
        self.tableView.reloadData()
        
        testRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for each in values {
                    let searchCount = searchBar.text?.characters.count // The number of characters in this search to compare
                    
                    // Get the user data
                    let handle = each.key as! String // Get the handle
                    
                    // Check if this user is a friend of the main user before acting on it
                    if mainUser.friendHandles.contains(handle) {
                        // If so, continue loading
                        let userData = values[handle] as! Dictionary<String, Any> // Get all the subset of data for this user
                        let fullName = userData["fullName"] as! String // Get the user's full name from the subset of data
                        
                        // Make sure we're not getting users that don't match the search
                        let range = fullName.startIndex..<(fullName.index(fullName.startIndex, offsetBy: searchCount!))
                        let fullNameSplit = fullName.substring(with: range) // Get just the characters
                        
                        if searchBar.text == fullNameSplit { // If the search equates to this users full name
                            // Retrieve the profile photo
                            let profilePhotoRef = storage.ref.child("users").child(handle).child("profilePhoto").child("\(handle).jpg")
                            profilePhotoRef.data(withMaxSize: 1 * 2048 * 2048, completion: { (data, error) in
                                if error == nil { // If there wasn't an error
                                    let profilePhoto = UIImage(data: data!) // Create an image from the data retrieved
                                    
                                    // Create the user
                                    let user = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                                    
                                    // Add it to the list of users
                                    self.users.append(user)
                                    
                                    // Update the data table
                                    self.tableView.reloadData()
                                } else { // If there was an error
                                    
                                }
                            })
                        } else { // If the search doesn't equate to this user
                            
                        }
                    } else { // If this user isn't friends with the main user
                        
                    }
                }
            }
        })
        
        self.searchContent = searchBar.text
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        users = selectedUsers
        self.tableView.reloadData()
    }
    
    // Chcek if there
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" { // If the user isn't searching anything, fill it with the user's friends
            users = mainUserFriends
            self.tableView.reloadData()
        }
    }
}

/*
class InviteFriendsTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    
    var buttonPressedObj: (() -> Void)? = nil
    
    
} */
