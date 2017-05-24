//
//  GroupsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 12/21/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit
import Firebase

class GroupsViewController: UIViewController {
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //var defaultGroups: [Group: UIImage] = [:] // Makes an empty dictionary
    var defaultGroups = [Group]() // An emptyarray of Groups - this is going to be a priorityqueue in a bit
    var groupQueue = PriorityQueue<Group>(sortedBy: <) // Hopefully this doesn't get reset each time
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    let transitionDown = SlideDownAnimator()
    let transitionUp = SlideUpAnimator()
    
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Attempt to load in all of the groups
        if groups.count < mainUser.groupHandles.count { // If we dont have all of the groups loaded in
            for groupHandle in mainUser.groupHandles {
                let matches = groups.filter{ $0.groupName == groupHandle } // Check if we already have a group with this handle, probably very inefficient
                if matches.count != 0 { // If we already contain a group with this handle, skip it
                    continue
                } else { // Otherwise, load it from the Database
                    let groupRef = database.ref.child("groups").child(groupHandle)
                    
                    groupRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        let values = snapshot.value as! NSDictionary
                        
                        // Load in all of the data for this group
                        let creatorHandle = values["creator"] as! String // No need to add a default, will never be empty
                        let memberHandles = values["members"] as! [String: Bool] // Again, no need to add a default, will never be empty
                        let postsData = values["posts"] as? [String: [String: Any?]] ?? [String: [String: String]]() // In case there are no posts in this group
                        
                        // Download the icon for this group
                        let iconRef = storage.ref.child("groups").child(groupHandle).child("icon/\(groupHandle).jpg")
                        iconRef.data(withMaxSize: 1 * 1024 * 1024, completion: { data, error in
                            if error == nil { // If there wasn't an error
                                // Then the data is returned
                                let groupIcon = UIImage(data: data!)
                                
                                // And we can finish loading the group
                                let group = Group(groupName: groupHandle, groupIcon: groupIcon!, memberHandles: Array(memberHandles.keys), postsData: postsData, creatorHandle: creatorHandle)
                                
                                groups.append(group) // Add this newly loaded group into the global groups variable
                                
                                self.tableView.reloadData() // Reload data every time a group is loaded
                            } else { // If there was an error
                                print(error!)
                                //continue // Skip this
                            }
                        })
                    })
                }
            }
        }
    
        self.loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Attach this to any view that requires information about this user??
        handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
        })
        
        // If the tab bar was previously hidden(like from the feed view), unhide it
        self.tabBarController?.showTabBar()
        self.navigationController?.showNavigationBar() // Unhide the nav bar
        
        // Check if there is a group already selected
        let selectedIndex = self.tableView.indexPathForSelectedRow
        if selectedIndex != nil { // If there is then deselect it
            self.tableView.deselectRow(at: selectedIndex!, animated: false)
        }
        
        self.tableView.reloadData() // Reload the data incase we added a new group??? should i do this in create group segue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FIRAuth.auth()?.removeStateDidChangeListener(handle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func unwindToGroup(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromGroupToFeed" {
            if let feedView = segue.destination as? FeedViewController {
                if let tag = (sender as? GroupTableViewCell)?.tag {
                    weak var group = groups[tag] // I want this to be weak to prevent memory leakage
                    
                    feedView.group = group
                    self.tabBarController?.hideTabBar()
                    self.navigationController?.title = group?.groupName
                    
                    //feedNav.passGroup()
                }
            }
        } else if segue.identifier == "segueFromGroupToCreateGroup" {
            if let createGroupView = segue.destination as? CreateGroupViewController {
                createGroupView.transitioningDelegate = transitionDown
            }
        }
    }
}

// Framework functions
extension GroupsViewController {
    func loadGroup(groupHandle: String) -> Group {
        let groupRef = database.ref.child("groups").child(groupHandle)
        
        groupRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
        })
        
        return Group()
    }
    
    func loadUserData() {
        // Load the user's friends whenever we can
        database.ref.child("users").child(mainUser.handle).child("friends").observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                let friendHandles = values.allKeys as! [String] // The tree is ordered as "userHandle": true, the value of this doesnt matter
                
                // Set the friend handles for the main user
                mainUser.friendHandles = friendHandles
            } else { // This user has no friends
                //mainUser.friends = [User]()
            }
        })
        
        // Load notifications too probably, just the first 10
        database.ref.child("notifications").child(mainUser.handle).queryOrdered(byChild: "timestamp").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for (_, value) in values {
                    if let data = value as? [String : Any] {
                        let type = NotificationType(rawValue: data["type"] as! Int)!
                        
                        let notification: Notification
                        
                        switch(type) {
                        case NotificationType.FRIEND_REQUESTED:
                            let senderHandle = data["sender"] as! String
                            let timestamp = NSDate(timeIntervalSinceReferenceDate: data["timestamp"] as! Double)
                            
                            notification = Notification(type: type, senderHandle: senderHandle)
                            
                            // Add the notification
                            mainUser.notifications.append(notification)
                            break
                        default: break
                        }
                    }
                }
            }
        })
        
        // Load all of the outgoing friend requests
        database.ref.child("users").child(mainUser.handle).child("outgoingrequests").observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                let requestHandles = values.allKeys as! [String]
                
                mainUser.outgoingFriendRequests = requestHandles
            }
        })
        
        // Load all of the incoming friend requests
        database.ref.child("users").child(mainUser.handle).child("incomingrequests").observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                let requestHandles = values.allKeys as! [String]
                
                mainUser.incomingFriendRequests = requestHandles
            }
        })
    }

}

// Table View Functions
extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! GroupTableViewCell
        
        cell.groupTitleLabel?.text = groups[indexPath.row].groupName
        
        // Set the group icon 
        cell.groupImageView?.image = groups[indexPath.row].groupIcon
        cell.groupImageView?.layer.cornerRadius = cell.groupImageView.frame.size.width / 2
        cell.groupImageView.clipsToBounds = true
        
        cell.tag = indexPath.row //or do i do indexPath.item
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count //this number will be loaded in later on
    }
}

// Custom Table View Cell Class
class GroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    
}
