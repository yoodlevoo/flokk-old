//
//  ProfileViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/4/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var groupNumber: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerView: UIView!
    
    var user: User! // The user this profile is showing
    
    var oldContentOffset = CGPoint.zero
    var headerConstraintRange: Range<CGFloat>!
    
    var headerViewCriteria = CGFloat(0) // Doesn't actually affect the header view, but used for the scroll view calculations
    
    var requestedFriend: Bool = false // Has the main user requested to be this user's friend
    var alreadyFriends: Bool = false // Is the main user already friends with this user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set this profile's data from the according User
        
        name.text = user.fullName
        username.text = "@\(user.handle)"
        
        // Set the profile pic and make it crop to an image
        profilePic.image = user.profilePhoto
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        
        // If this user is already friends with the main user
        if mainUser.isFriendsWith(user: user) {
            // Then don't display the add friend button
            addFriendButton.isHidden = true
        }
        
        // Check if the main user has requested to be friends with this user
        if mainUser.outgoingFriendRequests.contains(self.user) {
            
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Create the range for when the tableView should start & stop moving
        self.headerConstraintRange = (CGFloat(self.headerView.frame.origin.y - self.headerView.frame.size.height)..<CGFloat(self.headerView.frame.origin.y))
        self.view.bringSubview(toFront: tableView) // Make sure the table view is always shown on top of the header view
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
    
    @IBAction func addFriendButtonPressed(_ sender: Any) {
        if !requestedFriend { // If the main user hasn't already added this friend
            self.addFriendButton.imageView?.image = UIImage(named: "Add Friend Button New") // Change the buttons image to show that its already been pressed
            
            // Send a friend request to this user
            mainUser.sendFriendRequestTo(self.user)
        }
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
