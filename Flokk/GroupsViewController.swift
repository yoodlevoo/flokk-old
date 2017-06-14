//
//  GroupsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 12/21/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit
import Firebase
import BRYXBanner

class GroupsViewController: UIViewController {
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //var defaultGroups: [Group: UIImage] = [:] // Makes an empty dictionary
    var defaultGroups = [Group]() // An emptyarray of Groups - this is going to be a priorityqueue in a bit
    var groupQueue = PriorityQueue<Group>(sortedBy: <) // Hopefully this doesn't get reset each time
    
    var refreshControl = UIRefreshControl()
    
    let transitionDown = SlideDownAnimator()
    let transitionUp = SlideUpAnimator()
    
    fileprivate var groupDict = [String : String]() // [groupID : groupName] i really dont like doing this
    
    //var handle: FIRAuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.refreshControl.addTarget(self, action: #selector(GroupsViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        self.refreshControl.tintColor = TEAL_COLOR
        //print(self.refreshControl.frame)
        
        self.tableView.refreshControl = self.refreshControl
        
        // Attempt to load in all of the groups
        if groups.count < mainUser.groupIDs.count { // If we dont have all of the groups loaded in
            self.refreshControl.beginRefreshing()
            
            for groupID in mainUser.groupIDs {
                let matches = groups.filter{ $0.groupID == groupID } // Check if we already have a group with this ID, probably inefficient
                if matches.count != 0 { // If we already contain a group with this handle, skip it
                    continue
                } else { // Otherwise, load it from the Database
                    let groupRef = database.ref.child("groups").child(groupID)
                    
                    groupRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        let values = snapshot.value as! NSDictionary
                        
                        // Load in all of the data for this group
                        let groupName = values["name"] as! String // Load in the group, will never be empty so no need for a default
                        let creatorHandle = values["creator"] as! String // No need to add a default, will never be empty
                        let memberHandles = values["members"] as! [String: Bool] // Again, no need to add a default, will never be empty
                        let postsData = values["posts"] as? [String: [String: Any?]] ?? [String: [String: String]]() // In case there are no posts in this group
                        
                        // Download the icon for this group
                        let iconRef = storage.ref.child("groups").child(groupID).child("icon.jpg")
                        iconRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { data, error in
                            if error == nil { // If there wasn't an error
                                // Then the data is returned
                                let groupIcon = UIImage(data: data!)
                                
                                // And we can finish loading the group
                                let group = Group(groupID: groupID, groupName: groupName, groupIcon: groupIcon!, memberHandles: Array(memberHandles.keys), postsData: postsData, creatorHandle: creatorHandle)
                                
                                // Attemp to load in the user handles that have been invited to this group already
                                if let invitedUsers = values["invitedUsers"] as? [String : Bool] { // Also checks if there are any invited users or not
                                    group.invitedUsers = Array(invitedUsers.keys)
                                } else { // Then there are probably no invites that are still pending for this group
                                    group.invitedUsers = [String]()
                                }
                                
                                groups.append(group) // Add this newly loaded group into the global groups variable
                                
                                self.groupDict[groupID] = groupName
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData() // Reload data every time a group is loaded
                                    self.refreshControl.endRefreshing()
                                }
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
        self.beginListeners()
        
        print("\n\n\n")
        print(NSDate.timeIntervalSinceReferenceDate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Attach this to any view that requires information about this user??
//        handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
//            
//        })
        
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
        
        //FIRAuth.auth()?.removeStateDidChangeListener(handle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func unwindToGroup(segue: UIStoryboardSegue) {
        
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromGroupToFeed" {
            if let feedView = segue.destination as? FeedViewController {
                if let tag = (sender as? GroupTableViewCell)?.tag {
                    weak var group = groups[tag] // I want this to be weak to prevent memory leakage
                    
                    feedView.group = group
                    feedView.groupIndex = tag // The index of this group globally, for now
                    self.tabBarController?.hideTabBar()
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
    // Load various data about the user immediately
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
        
        // Load all of the group invites
        database.ref.child("users").child(mainUser.handle).child("groupinvites").observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                
            }
        })
    }
    
    // Begin listening for changes throughout the app - mainly notifications
    func beginListeners() {
        print(NSDate.timeIntervalSinceReferenceDate)
        // Begin listening for notifications, sorted only from the ones we get after the app launched
        let notificationRef = database.ref.child("notifications").child(mainUser.handle)
        notificationRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: Double(NSDate.timeIntervalSinceReferenceDate)).observe(.childAdded, with: { (snapshot) in // Listen for additions
            // Depending on what kind of notification it is, handle it internally
            // So if its a friend invite notification, at it locally to the friend invite array for the main user
            // That way we don't have to listen to changes for the the friend invites part of the database
            if let notificationValues = snapshot.value as? NSDictionary {
                let type = NotificationType(rawValue: notificationValues["type"] as! Int)!
                let timestamp = Date(timeIntervalSinceReferenceDate: notificationValues["timestamp"] as! Double)
                let senderHandle = notificationValues["sender"] as! String // There's always a sender
                
                // Initialize the user a little bit
                let userRef = database.ref.child("users").child(senderHandle)
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let userValues = snapshot.value as? NSDictionary {
                        let fullName = userValues["fullName"] as! String
                        
                        // Load in the profile photo
                        let profilePhotoRef = storage.ref.child("users").child(senderHandle).child("profilePhoto.jpg")
                        profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (userData, error) in
                            if error == nil { // If there wasn't an error
                                let profilePhoto = UIImage(data: userData!)
                                
                                // Create the user
                                let user = User(handle: senderHandle, fullName: fullName, profilePhoto: profilePhoto!)
                                
                                // If the notification involves a group, load the group
                                if type == .GROUP_INVITE || type == .GROUP_JOINED || type == .NEW_POST || type == .NEW_COMMENT {
                                    let groupID = notificationValues["groupID"] as! String
                                    
                                    // Load the group data - only the group name
                                    let groupRef = database.ref.child("groups").child(groupID)
                                    groupRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let groupValues = snapshot.value as? NSDictionary {
                                            let groupName = groupValues["name"] as! String
                                            let invitedUsers = groupValues["invitedUsers"] as? [String : Bool] ?? [String : Bool]() // Load all of the user handles that have been invited
                                            let memberHandles = Array((groupValues["members"] as! [String : Bool]).keys) // Load all of the handles of the current members, this will never be empty
                                            
                                            // Load the group photo
                                            let groupIconRef = storage.ref.child("groups").child(groupID).child("icon.jpg")
                                            groupIconRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (groupData, error) in
                                                if error == nil { // If there wasn't an error
                                                    let groupIcon = UIImage(data: groupData!)
                                                    
                                                    let group = Group(groupID: groupID, groupName: groupName, image: groupIcon!)
                                                    
                                                    group.invitedUsers = Array(invitedUsers.keys)
                                                    group.memberHandles = memberHandles
                                                    
                                                    // This needs to be handled differently eventually
                                                    let notification = Notification(type: type, sender: user, group: group)
                                                    
                                                    mainUser.notifications.append(notification)
                                                } else { // If there was an error
                                                    print(error!)
                                                }
                                            })
                                        }
                                    })
                                } else { // FRIEND_REQUESTED, FRIEND_REQUEST_ACCEPTED
                                    let notification = Notification(type: type, sender: user)
                                    
                                    mainUser.notifications.append(notification)
                                }
                                
                                // Animate a banner
                            } else { // If there was an error
                                // Handle it more in depth
                                print(error!)
                            }
                        })
                    }
                })
                
            }
        })
        
        // Begin listening for group/posts changes? - this should be encapsulated within the notifications listener, except for things that don't trigger a notification
        
        // Begin listening for post changes within groups
        // What should i do if the group isn't loaded yet
        for groupID in mainUser.groupIDs { // Create a listener for each group the user is in
            let groupRef = database.ref.child("groups").child(groupID).child("posts")
            // Only listen for post changes after the app launched, otherwise we'll get old posts
            groupRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: Double(NSDate.timeIntervalSinceReferenceDate)).observe(.childAdded, with: { (snapshot) in
                if let values = snapshot.value as? NSDictionary {
                    let postID = snapshot.key
                    
                    let posterHandle = values["poster"] as! String
                    let timestamp = NSDate(timeIntervalSinceReferenceDate: values["timestamp"] as! Double)
                    
                    // Create a banner to notify the user
                    let groupName = self.groupDict[groupID]! // Load in the group ID
                    let banner = Banner(title: "Post Added", subtitle: "@\(posterHandle) uploaded a post to \(groupName)", image: UIImage(named: "Request to be Added New"), backgroundColor: TEAL_COLOR, didTapBlock: {
                        print("tapped")
                    })
                    
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    
                    // No point in loading the notification here
                }
            })
        }
        
        // Listen for friend requests and group invites
        let friendRequestRef = database.ref.child("users").child(mainUser.handle).child("incomingrequests")
        friendRequestRef.queryOrderedByValue().queryStarting(atValue: NSDate.timeIntervalSinceReferenceDate).observe(.childAdded, with: { (snapshot) in
            if let timestamp = snapshot.value as? Double, let senderHandle = snapshot.key as? String {
                let banner = Banner(title: "Friend Request", subtitle: "@\(senderHandle) requested to be your friend", image: UIImage(named: "Request to be Added New"), backgroundColor: TEAL_COLOR, didTapBlock: {
                    // Go to this user's profile
                    let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                    
                    profileView.userHandle = senderHandle
                })
                
                banner.dismissesOnSwipe = true
                banner.show(duration: 3.0)
            }
        })
        
        // Listen for group invites=
        let groupInvitesRef = database.ref.child("users").child(mainUser.handle).child("groupInvites")
        groupInvitesRef.queryOrderedByValue().queryStarting(atValue: NSDate.timeIntervalSinceReferenceDate).observe(.childAdded, with: { (snapshot) in
            if let timestamp = snapshot.value as? Double, let groupName = snapshot.key as? String {
                let banner = Banner(title: "Group Invite", subtitle: "@user hasd invited you to join \(groupName) ", image: UIImage(named: "Request to be Added New"), backgroundColor: TEAL_COLOR, didTapBlock: {
                    // Go to the group profile
                    
                })
                
                banner.dismissesOnSwipe = true
                banner.show(duration: 3.0)
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
        
        self.refreshControl.endRefreshing()
        
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
