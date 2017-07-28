//
//  GroupProfileViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/3/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit

class GroupProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var group: Group! // Is this just a copy of the actual group?
    var groupID: String!
    var notification: Notification? // May not always exist, depending on where we segue from
    
    var oldContentOffset = CGPoint.zero // The previous frame's offset
    var headerConstraintRange: Range<CGFloat>! // The range that determines the min/max of the tableView's expansion/contraction
    var headerViewCriteria = CGFloat(0) // Doesn't actually affect the header view, but used for the scroll view calculations
    
    var invitedReceived = false // If the main user has been invited to this group, by default is false
    
    fileprivate var containerView: GroupProfilePageViewController! // A reference to the container View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationBar.title = self.group.name
        
        // Create the range for when the tableView should start/stop moving
        self.headerConstraintRange = (CGFloat(self.headerView.frame.origin.y - self.headerView.frame.size.height)..<CGFloat(self.headerView.frame.origin.y))
        self.view.bringSubview(toFront: tableView) // Make sure the table view is always shown on top of the header view
        self.headerViewCriteria = self.headerView.frame.origin.y // Variable that uses the headerView's dimensions but doesn't directly affect it to achieve the desired effect
        
        // If the group icon has already been loaded
        if self.group.icon != nil {
            let iconRef = storage.ref.child("groups").child(self.groupID).child("icon.png")
            iconRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                if error == nil { // If there wasn't an error
                    
                    let icon = UIImage(data: data!)
                    
                    self.group.icon = icon!
                    
                    // Set the group icon in the container now that it has loaded
                    self.containerView.setGroupIcon(icon!)
                } else { // If there was an error
                    // Handle the errors
                    print(error!)
                }
            })
        }
        
        // Check if the creator has been loaded in yet for the second page view
        if self.group.creator == nil {
            // Find out what the creator handle is first
            let groupRef = database.ref.child("groups").child(self.groupID).child("creator")
            groupRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let creatorHandle = snapshot.value as? String {
                    // Once we've loaded in the handle, load in the rest about the user
                    
                    
                    
                    // Load in the full name of the user
                    let creatorRef = database.ref.child("users").child(creatorHandle).child("fullName")
                    creatorRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let fullName = snapshot.value as? String {
                            
                            // Then, load in the profile photo of the user
                            let profilePhotoRef = storage.ref.child("users").child(creatorHandle).child("profilePhotoIcon.jpg")
                            profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                                if error == nil { // If there wasn't an error
                                    let profilePhoto = UIImage(data: data!)
                                    
                                    
                                } else {
                                    // Handle the error
                                    print(error!)
                                }
                            })
                        }
                    })
                }
            })
        }
        
        // Check what data has been loaded for this group that hasn't been loaded already
        // Probably gonna be the members at the least, so do that now
        if self.group.members.count == 0 { // If the members of this gorup haven't been loaded yet
            for uid in self.group.memberIDs { // Iterate through all of the member handles and load each user - should probably ignore the main user
                let userRef = database.ref.child("users").child(uid)
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let values = snapshot.value as? NSDictionary {
                        let fullName = values["fullName"] as! String
                        let handle = values["handle"] as! String
                        
                        // Load in the profile photo for this user
                        let profilePhotoRef = storage.ref.child("users").child(uid).child("profilePhotoIcon.jpg")
                        profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                            if error == nil { // If there wasn't an error
                                let profilePhoto = UIImage(data: data!)
                                
                                let user = User(uid: uid, handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                                
                                // Attempt to load in the user's friends handles
                                if let friends = values["friends"] as? [String : Bool] {
                                    user.friendIDs = Array(friends.keys)
                                }
                                
                                // Attempt to load in the user's group IDs
                                if let groups = values["groups"] as? [String : Bool] {
                                    user.groupIDs = Array(groups.keys)
                                }
                                
                                // Add the user to the local(specific to the view) group to be displayed
                                // This is going to do nothing as it's not a global change
                                self.group.members.append(user)
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            } else { // If there was an error
                                print(error!)
                            }
                        })
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backPage(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func requestToJoin(_ sender: AnyObject) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedSegueGroupProfileContainer" {
            if let groupProfilePageView = segue.destination as? GroupProfilePageViewController {
                groupProfilePageView.group = self.group
            }
        } else if segue.identifier == "segueFromGroupProfileToProfile" {
            if let profileView = segue.destination as? ProfileViewController {
                let indexPath = self.tableView.indexPathForSelectedRow
                
                let user = self.group.members[(indexPath?.row)!]
                
                profileView.user = user
            }
        }
    }
}

// Table and Scroll View Functions
extension GroupProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default") as! UserTableViewCell
        
        let user = group.members[indexPath.row]
        
        cell.profilePhotoView.image = user.profilePhoto
        cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.width / 2
        cell.profilePhotoView.clipsToBounds = true
        
        cell.fullNameLabel.text = user.fullName
        cell.handleLabel.text = "@\(user.handle)"
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        
        // Only scroll the view over the top view when there are enough users to do so
        if self.group.members.count > 4 {
            // Compress the header view
            if delta > 0 && headerViewCriteria > headerConstraintRange.lowerBound && scrollView.contentOffset.y > 0 {
                scrollView.contentOffset.y -= delta
                self.headerViewCriteria -= delta
                
                self.tableView.frame.origin.y -= delta
                self.tableView.frame.size.height += delta
            }
            
            // Expand the header view
            if delta < 0 && headerViewCriteria < headerConstraintRange.upperBound && scrollView.contentOffset.y < 0 {
                scrollView.contentOffset.y -= delta
                self.headerViewCriteria -= delta
                
                self.tableView.frame.origin.y -= delta
                self.tableView.frame.size.height += delta
            }
        }
        
        oldContentOffset = scrollView.contentOffset
    }
}
