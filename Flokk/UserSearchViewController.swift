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

class UserSearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var searchBar: UISearchBar!
    
    var users = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchContent: String!
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.searchBar.delegate = self
        //self.searchBar.isHidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.definesPresentationContext = true // This fucks up the view controller somehow
        
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.keyboardAppearance = .dark
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.refreshControl.addTarget(self, action: #selector(UserSearchViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        self.refreshControl.tintColor = TEAL_COLOR
        
        
        //self.tableView.addSubview(self.refreshControl)
        //self.tableView.bringSubview(toFront: self.refreshControl)
        // self.tableView.refreshControl = self.refreshControl
        //self.refreshControl.beginRefreshing()
        
        /*
        self.searchController.searchBar.layer.cornerRadius = 2.0
        self.searchController.searchBar.layer.borderColor = UIColor.cyan.cgColor
        //self.searchController.searchBar.layer.backgroundColor = NAVY_COLOR.cgColor
        self.searchController.searchBar.tintColor =  TEAL_COLOR
        
        var textField = self.searchController.searchBar.value(forKey: "_searchField") as! UITextField
        textField.textColor = UIColor.brown
        textField.backgroundColor = NAVY_COLOR
        */
        
        self.searchContent = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.searchController.searchBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.searchController.isActive = false
        //self.searchController.searchBar.endEditing(true) // Deselect this search bar when we segue away, always does weird shit otherwise
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Search if there is a user in the database whose fullName matches the search criteria
    // aysnchronous loading is messing up the tableview
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.searchController.searchBar.isHidden = true
        
        if segue.identifier == "segueFromUserSearchToProfile" {
            if let profileView = segue.destination as? ProfileViewController {
                let selectedUser = users[(self.tableView.indexPathForSelectedRow?.row)!]
                
                profileView.user = selectedUser
                profileView.userHandle = selectedUser.handle
            }
        }
    }
}

// Table View functions
extension UserSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

// Search Bar Functions
extension UserSearchViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //let usersRef = database.ref.child("users").queryOrdered(byChild: "fullName").queryEqual(toValue: searchBar.text)
        let testRef = database.ref.child("users").queryOrdered(byChild: "fullName").queryStarting(atValue: searchBar.text) //insert queryLimited
        
        // Clear the users on every new search
        users.removeAll()
        self.tableView.reloadData()
        self.refreshControl.beginRefreshing() // Start the activity indicator / refresh control
        
        testRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for each in values {
                    let searchCount = searchBar.text?.characters.count // The number of characters in this search to compare
                    
                    // Get the user data
                    let handle = each.key as! String // Get the handle
                    let userData = values[handle] as! Dictionary<String, Any> // Get all the subset of data for this user
                    let fullName = userData["fullName"] as! String // Get the user's full name from the subset of data
                    let groupIDs = userData["groups"] as? [String : Bool] ?? [String : Bool]() // Load in the group IDs that this user is in
                    
                    // Make sure we're not getting users that don't match the search
                    let range = fullName.startIndex..<(fullName.index(fullName.startIndex, offsetBy: searchCount!))
                    let fullNameSplit = fullName.substring(with: range) // Get just the characters
                    
                    if searchBar.text == fullNameSplit { // If the search equates to this users full name
                        // Retrieve the profile photo
                        let profilePhotoRef = storage.ref.child("users").child(handle).child("profilePhoto.jpg")
                        profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                            if error == nil { // If there wasn't an error
                                let profilePhoto = UIImage(data: data!) // Create an image from the data retrieved
                                
                                // Create the user
                                let user = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                                user.groupIDs = Array(groupIDs.keys)
                                
                                // Add it to the list of users
                                self.users.append(user)
                                
                                // Update the data table
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    //self.refreshControl.endRefreshing() // Stop the activity indicator/refresh control
                                }
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
