//
//  UserSearchTableViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 5/16/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class UserSearchTableViewController: UITableViewController, UISearchResultsUpdating {
    var users = [User]()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchController.searchBar.isHidden = false
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
        
        // Set the profile photo and crop it to a circle
        cell.profilePhotoView.image = user.profilePhoto
        cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.width / 2
        cell.profilePhotoView.clipsToBounds = true
        
        cell.fullNameLabel.text = user.fullName
        cell.handleLabel.text = user.handle
        
        return cell
    }
    
    // Search if there is a user in the database whose fullName matches the search criteria
    // aysnchronous loading is messing up the tableview
    func updateSearchResults(for searchController: UISearchController) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.searchController.searchBar.isHidden = true
        
        if segue.identifier == "segueFromUserSearchToProfile" {
            if let profileView = segue.destination as? ProfileViewController {
                let selectedUser = users[(self.tableView.indexPathForSelectedRow?.row)!]
                
                profileView.user = selectedUser
            }
        }
    }
}

extension UserSearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //let usersRef = database.ref.child("users").queryOrdered(byChild: "fullName").queryEqual(toValue: searchBar.text)
        let testRef = database.ref.child("users").queryOrdered(byChild: "fullName").queryStarting(atValue: searchBar.text) //insert queryLimited
        
        // Clear the users on every new search
        users.removeAll()
        self.tableView.reloadData()
        
        testRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for each in values {
                    let searchCount = searchBar.text?.characters.count // The number of characters in this search to compare
                    
                    // Get the user data
                    let handle = each.key as! String // Get the handle
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
                }
            }
        })
        
        self.searchContent = searchBar.text
    }
    
    // Search on this as well?
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
}
