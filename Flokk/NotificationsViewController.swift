//
//  NotificationsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 2/27/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var notifications = [Notification]()
    
    var refreshControl = UIRefreshControl()
    
    let initialLoadCount = 20 // The maximum initial amount of notifications to load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Set the refresh control properties and action
        self.refreshControl.addTarget(self, action: #selector(NotificationsViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        self.refreshControl.tintColor = TEAL_COLOR
        self.tableView.refreshControl = refreshControl
        //self.tableView.refreshControl?.endRefreshing()
        
        // Listen for any changes in the user's notification tree
        loadNotifications()
    }
    
    // When this view is being transitioned to - check for Notifications?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.notifications = mainUser.notifications
        
        // Check if there is a group already selected
        let selectedIndex = self.tableView.indexPathForSelectedRow
        if selectedIndex != nil { // If there is then deselect it
            self.tableView.deselectRow(at: selectedIndex!, animated: false)
        }
        
        // Check if the tab bar is hidden
        if self.tabBarController?.tabBar.isHidden == true {
            self.tabBarController?.showTabBar() // if it is, animate the unhiding of it
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // Called when the user pulls down on this table
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

    func loadNotifications() {
        self.refreshControl.beginRefreshing()
        
        // Load notifications too probably, just the first 10
        database.ref.child("notifications").child(mainUser.handle).queryOrdered(byChild: "timestamp").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for (_, value) in values {
                    if let data = value as? [String : Any] {
                        let type = NotificationType(rawValue: data["type"] as! Int)!
                        
                        switch(type) {
                        case NotificationType.FRIEND_REQUESTED:
                            let senderHandle = data["sender"] as! String
                            let timestamp = NSDate(timeIntervalSinceReferenceDate: data["timestamp"] as! Double)
                            
                            // Load in the sender data
                            let userRef = database.ref.child("users").child(senderHandle)
                            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                if let userValues = snapshot.value as? NSDictionary {
                                    let fullName = userValues["fullName"] as! String
                                    
                                    // Load in the profile photo
                                    let profilePhotoRef = storage.ref.child("users").child(senderHandle).child("profilePhoto.jpg")
                                    profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                                        if error == nil { // If there wasn't an error
                                            let profilePhoto = UIImage(data: data!)
                                            
                                            let user = User(handle: senderHandle, fullName: fullName, profilePhoto: profilePhoto!)
                                            
                                            let notification = Notification(type: .FRIEND_REQUESTED, sender: user)
                                            
                                            // Add the notification
                                            mainUser.notifications.append(notification)
                                            
                                            // Reload the table
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
                                        } else {
                                            print(error!)
                                        }
                                    })
                                }
                            })
                            
                            break
                        case NotificationType.GROUP_INVITE:
                            let senderHandle = data["sender"] as! String
                            let timestamp = NSDate(timeIntervalSinceReferenceDate: data["timestamp"] as! Double)
                            let groupID = data["groupID"] as! String
                            
                            // Load all of the needed data for this type of notification
                            // The user profile photo & name and the group icon & name
                            let groupRef = database.ref.child("groups").child(groupID)
                            groupRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                if let values = snapshot.value as? NSDictionary {
                                    let groupName = values["name"] as! String
                                    let memberHandles = values["members"] as! [String : Bool] // This will never be nil/empty, will always have the creator
                                    let creatorHandle = values["creator"] as! String
                                    
                                    // Load the group icon first
                                    let groupIconRef = storage.ref.child("groups").child(groupID).child("icon.jpg")
                                    groupIconRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                                        if error == nil {
                                            let groupPhoto = UIImage(data: data!)
                                            // Create the group object
                                            let group = Group(id: groupID, name: groupName, icon: groupPhoto!)
                                            group.memberHandles = Array(memberHandles.keys) // Set the member handles to be loaded in the future
                                            group.creationDate = Date(timeIntervalSinceReferenceDate: Date.timeIntervalSinceReferenceDate) // Set the creation date temporarily
                                            
                                            // Load user data - we might as well load in everything while we're at it
                                            let userRef = database.ref.child("users").child(senderHandle)
                                            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                                if let userValues = snapshot.value as? NSDictionary {
                                                    // Only load values that are 100% going to exist here
                                                    // Everything else needs to be in a conditional in the block below, after the user object has been initialized
                                                    // Or we could just directly load the fullName?
                                                    let fullName = userValues["fullName"] as! String
                                                    
                                                    //print(snapshot.children)
                                                    
                                                    // Load in the user's profile photo
                                                    let userProfilePhotoRef = storage.ref.child("users").child(senderHandle).child("profilePhoto.jpg")
                                                    userProfilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                                                        if error == nil {
                                                            let profilePhoto = UIImage(data: data!)
                                                            // Create the user object
                                                            let user = User(handle: senderHandle, fullName: fullName, profilePhoto: profilePhoto!)
                                                            
                                                            // Set the group IDs
                                                            if let groups = userValues["groups"] as? [String : Bool] {
                                                                user.groupIDs = Array(groups.keys)
                                                            }
                                                            
                                                            if let friends = userValues["friends"] as? [String : Bool] {
                                                                user.friendHandles = Array(friends.keys)
                                                            }
                                                            
                                                            if senderHandle == creatorHandle { // If the sender and the creator are the same user
                                                                // Simply set the groups creator as the user we just loaded in
                                                                group.creator = user
                                                            }
                                                                
                                                            // Create and add the notification
                                                            let notification = Notification(type: NotificationType.GROUP_INVITE, sender: user, group: group)
                                                            mainUser.notifications.append(notification)
                                                            //mainUser.notifications.sort(by: {$0.)
                                                            
                                                            DispatchQueue.main.async {
                                                                self.tableView.reloadData()
                                                                self.refreshControl.endRefreshing()
                                                            }
                                                        } else {
                                                            // Handle the errors here
                                                            print(error!)
                                                        }
                                                    })
                                                }
                                            })
                                            
                                            // If the inviter is not the creator, load the creator's data - move this to the profile page later
                                            if creatorHandle != senderHandle {
                                                // Continue loading the group creator's data
                                                let creatorRef = database.ref.child("users").child(creatorHandle)
                                                creatorRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                                    if let creatorValues = snapshot.value as? NSDictionary {
                                                        let fullName = creatorValues["fullName"] as! String
                                                        
                                                        // Load the profile photo for the user
                                                        let creatorProfilePhotoRef = storage.ref.child("users").child(creatorHandle).child("profilePhoto.jpg")
                                                        creatorProfilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                                                            if error == nil {
                                                                let profilePhoto = UIImage(data: data!)
                                                                
                                                                let user = User(handle: creatorHandle, fullName: fullName, profilePhoto: profilePhoto!)
                                                                
                                                                // Set the group IDs
                                                                if let groups = creatorValues["groups"] as? [String : Bool] {
                                                                    user.groupIDs = Array(groups.keys)
                                                                }
                                                                
                                                                // Set the friend handles
                                                                if let friends = creatorValues["friends"] as? [String : Bool] {
                                                                    user.friendHandles = Array(friends.keys)
                                                                }
                                                                
                                                                // Set the group's creator hopefully before we segue - otherwise its going to do nothing probably
                                                                group.creator = user
                                                            } else {
                                                                // Handle the errors later
                                                                print(error!)
                                                            }
                                                        })
                                                    }
                                                })
                                            }
                                        } else {
                                            // Handle the errors later
                                            print(error!)
                                        }
                                    })
                                }
                            })
                            
                            break
                        default: break
                        }
                    }
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (self.tabBarController as! MainTabBarController).hideTabBar()
        
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        if segue.identifier == "segueFromNotificationsToProfile" {
            if let profileView = segue.destination as? ProfileViewController {
                let notification = notifications[indexPath.row]
                
                profileView.user = notification.sender
            }
        } else if segue.identifier == "segueFromNotificationsToGroupProfile" {
            if let groupProfileView = segue.destination as? GroupProfileViewController {
                let notification = notifications[indexPath.row]
                
                groupProfileView.group = notification.group
            }
        }
    }
}

// Table View Functions
extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // This is only called once every time the table view reloads, so it's reasonable to check if the
        // activity indicator needs to disappear
        self.notifications = mainUser.notifications
        
        if self.notifications.count > 0 { // If a certain minimum of posts have been loaded
            if let refresh = self.tableView.refreshControl {
                
            }
        }
        
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "default") as! NotificationTableViewCell
        
        // Get the corresponding notification
        let notification = notifications[indexPath.row]
        
        switch notification.type {
        case NotificationType.FRIEND_REQUESTED:
            // Don't need to do anything extra here
            
            break
        case NotificationType.FRIEND_REQUEST_ACCEPTED:
            // Probably don't need to do anything extra here
            
            break
        case NotificationType.GROUP_INVITE:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "groupInvite") as! NotificationTableViewCell
            
            cell.groupIconView.image = notification.group!.icon
            cell.groupIconView.layer.cornerRadius = cell.groupIconView.frame.size.width / 2
            cell.groupIconView.clipsToBounds = true
            cell.descriptionLabel.numberOfLines = 0
            cell.descriptionLabel.lineBreakMode = .byWordWrapping
            cell.descriptionLabel.sizeToFit()
            
            break
        case NotificationType.NEW_COMMENT:
            
            break
        case NotificationType.NEW_POST:
            
            break
        case NotificationType.GROUP_JOINED:
            
            break
        }
        
        Notification.textSize = Float(cell.descriptionLabel.font.pointSize) // No point in casting back and forth between CGFloat and Float
        
        cell.descriptionLabel.attributedText = notification.description
        //cell.nameLabel.text = notification.sender.fullName
        
        cell.profilePictureView.image = notification.sender!.profilePhoto
        cell.profilePictureView.layer.cornerRadius = cell.profilePictureView.frame.size.width / 2
        cell.profilePictureView.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        // We will do different things depending on which type of Notification we selected
        switch notification.type {
        case NotificationType.FRIEND_REQUESTED:
            // Attempt to instantiate a Profile Navigation Object
            guard let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {
                print("Could not instantiate view controller of type Profile Navigation View Controller from Notifications Tab")
                return
            }
            
            profileView.user = notification.sender
            profileView.userHandle = notification.sender?.handle
            
            // Then segue to it
            //self.present(profileView, animated: true, completion: nil)
            
            break
        case NotificationType.FRIEND_REQUEST_ACCEPTED:
            
            break
        case NotificationType.GROUP_INVITE:
            guard let groupProfileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupProfileViewController") as? GroupProfileViewController else {
                print("Could not instantiate view controller of type Group View Controller from Notifications Tab")
                return
            }
            
            groupProfileView.group = notification.group
            groupProfileView.invitedReceived = true
            //groupProfileView.user = notification.sender
            
            //
            self.performSegue(withIdentifier: "segueFromNotificationsToGroupProfile", sender: self)
            
            break
        case NotificationType.NEW_COMMENT:
            
            break
        case NotificationType.NEW_POST:
            
            break
        case NotificationType.GROUP_JOINED:
            
            break
        }
    }
}

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var notificationDescriptionView: UIImageView!
    @IBOutlet weak var groupIconView: UIImageView!
    
}
