//
//  ProfileViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/4/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    //@IBOutlet weak var groupNumberLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var denyFriendRequestButton: UIButton!
    @IBOutlet weak var acceptFriendRequestButton: UIButton!
    
    @IBOutlet weak var headerView: UIView!
    
    var user: User! // The user this profile is showing
    
    var requestSent: Bool = false // Has the main user requested to be this user's friend
    var requestReceived: Bool = false // Has this user requested to be friends with the main user
    var alreadyFriends: Bool = false // Is the main user already friends with this user
    
    fileprivate var oldContentOffset = CGPoint.zero
    fileprivate var headerConstraintRange: Range<CGFloat>!
    fileprivate var headerViewCriteria = CGFloat(0) // Doesn't actually affect the header view, but used for the scroll view calculations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set this profile's data from the according User
        self.nameLabel.text = user.fullName
        self.usernameLabel.text = "@\(user.handle)"
        
        // Set the profile pic and make it crop to an image
        self.profilePhotoView.image = user.profilePhoto
        self.profilePhotoView.layer.cornerRadius = self.profilePhotoView.frame.size.width / 2
        self.profilePhotoView.clipsToBounds = true
        
        // If this user is already friends with the main user
        if mainUser.friendHandles.contains(self.user.handle) {
            // Then don't display the add friend button
            self.addFriendButton.isHidden = true
            self.alreadyFriends = true
            
        } else if mainUser.outgoingFriendRequests.contains(self.user.handle) { // Check if the main user has requested to be friends with this user
            self.addFriendButton.setImage(UIImage(named: "Added Friend New"), for: .normal)
            self.requestSent = true
            
        } else if mainUser.incomingFriendRequests.contains(self.user.handle) { // Check if this user has requested to be friends with the main user
            self.requestReceived = true
            self.addFriendButton.isHidden = true
            self.acceptFriendRequestButton.isHidden = false
            self.denyFriendRequestButton.isHidden = false
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Create the range for when the tableView should start & stop moving
        self.headerConstraintRange = (CGFloat(self.headerView.frame.origin.y - self.headerView.frame.size.height)..<CGFloat(self.headerView.frame.origin.y))
        self.view.bringSubview(toFront: self.tableView) // Make sure the table view is always shown on top of the header view
        self.headerViewCriteria = self.headerView.frame.origin.y // Variable that uses the headerView's dimensions but doesn't directly affect it
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if there is a group this user is participating in already selected
        let selectedIndex = self.tableView.indexPathForSelectedRow
        if selectedIndex != nil { // If there is then deselect it
            self.tableView.deselectRow(at: selectedIndex!, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // No need to check for the other states, this button won't appear if this user sent a request to the main User
    // this is for sending requests to the local user
    @IBAction func addFriendButtonPressed(_ sender: Any) {
        if !self.requestSent { // If the main user hasn't already added this friend
            //self.addFriendButton.imageView?.image = UIImage(named: "Add Friend Button New") // Change the buttons image to show that its already been pressed
            
            // Notify the other user the mainUser requested to be their friend
            database.ref.child("users").child(self.user.handle).child("incomingrequests").child(mainUser.handle).setValue(true)
            
            // Tell the database that the main user has an outgoing friend request to this (self.)user
            database.ref.child("users").child(mainUser.handle).child("outgoingrequests").child(self.user.handle).setValue(true)
            
            // This should probably be a server-side function, but we'll do it here
            let key = database.ref.child("notifications").child(self.user.handle).childByAutoId().key
            let notificationRef = database.ref.child("notifications").child(self.user.handle).child("\(key)")
            
            notificationRef.child("timestamp").setValue(NSDate.timeIntervalSinceReferenceDate)
            notificationRef.child("type").setValue(NotificationType.FRIEND_REQUESTED.rawValue)
            notificationRef.child("sender").setValue(mainUser.handle)
            
            // Update the button
            self.addFriendButton.setImage(UIImage(named: "Added Friend New"), for: .normal)
            self.requestSent = true
            
        } else { // If the main user requested to be this user's friend, "undo" the request
            // Remove the incoming request for this user
            database.ref.child("users").child(self.user.handle).child("incomingrequests").child(mainUser.handle).removeValue() { error in
            }
            
            // Remove the outgoing request for the main user
            database.ref.child("users").child(mainUser.handle).child("outgoingrequests").child(self.user.handle).removeValue() { error in
            }
            
            // Delete the notification for the user
            let notificationRef = database.ref.child("notifications").child(self.user.handle)
            notificationRef.queryOrdered(byChild: "sender").queryEqual(toValue: mainUser.handle).observeSingleEvent(of: .value, with: { (snapshot) in
                if let values = snapshot.value as? NSDictionary {
                    for (key, value) in values {
                        if let dict = value as? [String: Any] {
                            if dict["type"] as! Int == NotificationType.FRIEND_REQUESTED.rawValue {
                                notificationRef.child(key as! String).removeValue() // Delete this notification
                            }
                        }
                    }
                }
            })
            
            self.addFriendButton.setImage(UIImage(named: "Add Friend New"), for: .normal)
            self.requestSent = false
        }
    }
    
    // This button will only be shown if the local(self.) user has requested to be friends with the main User
    @IBAction func acceptFriendRequestPressed(_ sender: Any) {
        // Remove the outgoing request for this user
        database.ref.child("users").child(self.user.handle).child("outgoingrequests").child(mainUser.handle).removeValue() { error in
        }
        
        // Remove the incoming request for the main user
        database.ref.child("users").child(mainUser.handle).child("incomingrequests").child(self.user.handle).removeValue() { error in
        }
        
        // Remove the notification from local memory - mainUser.notifications
        
        // Remove the corresponding notification from the database
        let notificationRefMainUser = database.ref.child("notifications").child(mainUser.handle)
        notificationRefMainUser.queryOrdered(byChild: "sender").queryEqual(toValue: mainUser.handle).observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for (key, value) in values {
                    if let dict = value as? [String: Any] {
                        if dict["type"] as! Int == NotificationType.FRIEND_REQUESTED.rawValue {
                            notificationRefMainUser.child(key as! String).removeValue() // Delete this notification
                        }
                    }
                }
            }
        })

        // Tell the database these users are friends
        database.ref.child("users").child(self.user.handle).child("friends").child(mainUser.handle).setValue(true)
        database.ref.child("users").child(mainUser.handle).child("friends").child(self.user.handle).setValue(true)
        
        // Send a notification to this user that the mainUser accepted their friend request
        let notificationRefLocalUser = database.ref.child("notifcations").child(self.user.handle)
        let key = notificationRefLocalUser.childByAutoId().key // Unique ID for this notification
        notificationRefLocalUser.child("\(key)").child("type").setValue(NotificationType.FRIEND_REQUEST_ACCEPTED.rawValue)
        notificationRefLocalUser.child("\(key)").child("sender").setValue(mainUser.handle)
        notificationRefLocalUser.child("\(key)").child("timestamp").setValue(NSDate.timeIntervalSinceReferenceDate)
        
        // Set these users as friends locally
        //mainUser.friends.append(self.user)
        mainUser.friendHandles.append(self.user.handle)
        
        // Update the local booleans
        self.requestReceived = false
        self.alreadyFriends = true
        self.acceptFriendRequestButton.isHidden = true
        self.denyFriendRequestButton.isHidden = true
    }
    
    // This button will only be shown if the local(self.) user has requested to be friends with the main User
    @IBAction func denyFriendRequestPressed(_ sender: Any) {
        // Remove the outgoing request for this user
        database.ref.child("users").child(self.user.handle).child("outgoingrequests").child(mainUser.handle).removeValue() { error in
        }
        
        // Remove the outgoing request for the main user
        database.ref.child("users").child(mainUser.handle).child("incomingrequests").child(self.user.handle).removeValue() { error in
        }
        
        // Remove the notification from local memory - mainUser.notifications
        
        // Remove the corresponding notification from the database
        let notificationRef = database.ref.child("notifications").child(self.user.handle)
        notificationRef.queryOrdered(byChild: "sender").queryEqual(toValue: mainUser.handle).observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for (key, value) in values {
                    if let dict = value as? [String: Any] {
                        if dict["type"] as! Int == NotificationType.FRIEND_REQUESTED.rawValue {
                            notificationRef.child(key as! String).removeValue() // Delete this notification
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func profileSettings(_ sender: AnyObject) {
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        // Unwind to the previous view controller within this navigation controller
        // There are various different ways we segue to this view, so we can't really specify a single unwind segue to use
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromProfileToGroupProfile" {
            if let groupProfileView = segue.destination as? GroupProfileViewController {
                let indexPath = self.tableView.indexPathForSelectedRow
                
                groupProfileView.group = user.groups[(indexPath?.row)!]
            }
        }
    }
}

// Groups Table View Functions
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default") as! ProfileViewGroupTableViewCell
        
        // Load the according group from the user
        let group = user.groups[indexPath.row]
        
        // Set the group Icon and make it cropped to a circle
        cell.groupIconView.image = group.groupIcon
        cell.groupIconView.layer.cornerRadius = cell.groupIconView.frame.size.width / 2
        cell.groupIconView.clipsToBounds = true
        
        cell.groupNameLabel.text = group.groupName
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delta =  scrollView.contentOffset.y - oldContentOffset.y
        
        // We compress the header view
        if delta > 0 && headerViewCriteria > headerConstraintRange.lowerBound && scrollView.contentOffset.y > 0 {
            scrollView.contentOffset.y -= delta
            self.headerViewCriteria -= delta
            
            self.tableView.frame.origin.y -= delta
            self.tableView.frame.size.height += delta
        }
        
        // We expand the header view
        if delta < 0 && headerViewCriteria < headerConstraintRange.upperBound && scrollView.contentOffset.y < 0{
            scrollView.contentOffset.y -= delta
            self.headerViewCriteria -= delta
            
            self.tableView.frame.origin.y -= delta
            self.tableView.frame.size.height += delta
        }
        
        oldContentOffset = scrollView.contentOffset
    }
}

// Table View Cell for the groups section of this view
class ProfileViewGroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupIconView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
}
