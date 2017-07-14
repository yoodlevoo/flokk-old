//
//  GroupProfilePageViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 4/21/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class GroupProfilePageViewController: UIPageViewController {
    var viewControllerPages = [UIViewController]()
    
    var group: Group!
    var invitedToJoin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self

        // Attempt to initialize the first child view controller
        if let viewController1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupProfileViewControllerPage1") as? GroupProfileViewControllerPage1 {
            
            viewController1.group = group
            viewControllerPages.append(viewController1)
        } else {
            print("Couldn't instantiate GroupProfileViewController1")
        }
        
        // Attempt to initialize the second child view controller
        if let viewController2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewGroupProfileViewControllerPage2") as? GroupProfileViewControllerPage2 {
            
            viewController2.group = self.group
            viewControllerPages.append(viewController2)
        } else {
            print("Couldn't instantiate GroupProfileViewController2")
        }
        
        // If the group invites has been loaded yet
        if mainUser.groupInvites == nil {
            let userRef = database.ref.child("users").child(mainUser.handle).child("groupInvites")
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let values = snapshot.value as? NSDictionary {
                    let groupIDs = values.allKeys as! [String]
                    
                    mainUser.groupInvites = groupIDs
                    
                    // If this group has invited the main user to join
                    if groupIDs.contains(self.group.id) {
                        self.invitedToJoin = true
                        
                        // Show the accept and deny invite buttons
                        DispatchQueue.main.async {
                            self.showInviteButtons()
                        }
                    }
                }
            })
        } else { // If the groupInvites have been loaded
            if mainUser.groupInvites.contains(self.group.id) { // Check if this user has been invited to join
                self.invitedToJoin = true
                (viewControllerPages[0] as! GroupProfileViewControllerPage1).invitedToJoin = true
                
                // Show the accept and deny invite buttons
                self.showInviteButtons()
            }
        }
        
        // Set the initial view controller
        self.setViewControllers([viewControllerPages[0]], direction: .forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showInviteButtons() {
        if let page1 = viewControllerPages[0] as? GroupProfileViewControllerPage1 {
            if page1.acceptGroupInviteButton != nil && page1.declineGroupInviteButton != nil {
                page1.acceptGroupInviteButton.isHidden = false
                page1.declineGroupInviteButton.isHidden = false
            }
        }
    }
    
    func hideInviteButtons() {
        if let page1 = viewControllerPages[0] as? GroupProfileViewControllerPage1 {
            if page1.acceptGroupInviteButton != nil && page1.declineGroupInviteButton != nil {
                page1.acceptGroupInviteButton.isHidden = true
                page1.declineGroupInviteButton.isHidden = true
            }
        }
    }
    
    // Set the icon for the first page view, called from the parent GroupProfileView
    func setGroupIcon(_ icon: UIImage) {
        if let page1 = viewControllerPages[0] as? GroupProfileViewControllerPage1 {
            if page1.groupIconView != nil {
                page1.groupIconView.image = icon
            }
        }
    }
    
    // Set the creator handle for the second page view, called from the parent GroupProfileView
    func setCreatorHandle(_ handle: String) {
        if let page2 = viewControllerPages[1] as? GroupProfileViewControllerPage2 {
            if page2.creatorNameLabel != nil {
                page2.creatorNameLabel.text = handle
            }
        }
    }
    
    func setCreatorProfilePhoto(_ image: UIImage) {
        if let page2 = viewControllerPages[1] as? GroupProfileViewControllerPage2 {
            if page2.creatorProfilePhotoView != nil {
                page2.creatorProfilePhotoView.image = image
                // Make the profile photo crop to a circle
                page2.creatorProfilePhotoView.layer.cornerRadius = page2.creatorProfilePhotoView.frame.size.width / 2
                page2.creatorProfilePhotoView.clipsToBounds = true
            }
        }
    }
}

// Page View Controller functions
extension GroupProfilePageViewController: UIPageViewControllerDataSource {
    // Return what view controller should be shown when swiping left
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllerPages.index(of: viewController) else {
            return nil
        }
        
        if viewControllerIndex == 1 {
            return viewControllerPages[0]
        }
        
        return nil
    }
    
    // Return what view controller should be shown when swiping right
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllerPages.index(of: viewController) else {
            return nil
        }
        
        if viewControllerIndex == 0 {
            return viewControllerPages[1]
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 2 // No need to do viewControllerPages.count, this will always be 2
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

// View Controller at the top of the group profile
// Contains the Group Icon and the Group Name
class GroupProfileViewControllerPage1: UIViewController {
    @IBOutlet weak var groupIconView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var acceptGroupInviteButton: UIButton!
    @IBOutlet weak var declineGroupInviteButton: UIButton!
    
    weak var group: Group! // Why should this be weak?
    
    var activityIndicator = UIActivityIndicatorView() // This should be refresh control probably
    var invitedToJoin = false // Only set when the views are already loaded, so the show call is called before this page's viewDidLoad, resulting in an error
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If the icon has been set yet
        if self.group.icon != nil {
            self.groupIconView.image = self.group.icon!
        }
        
        // Crop the icon to a circle
        self.groupIconView.layer.cornerRadius = self.groupIconView.frame.size.width / 2
        self.groupIconView.clipsToBounds = true
        
        self.groupNameLabel.text = group.name
        
        // If the group invites have already been loaded and this group has an outgoing invite to the user
        // We have to show the buttons here, as they're not initialized yet when the page view controller initializes
        if self.invitedToJoin {
            self.acceptGroupInviteButton.isHidden = false
            self.declineGroupInviteButton.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // If the user accepts the invite to join this group
    @IBAction func acceptGroupInvitePressed(_ sender: Any) {
        let groupRef = database.ref.child("groups").child(self.group.id)
        groupRef.child("invitedUsers").child(mainUser.handle).removeValue() // Remove the outgoing invite from the groups json
        groupRef.child("members").child(mainUser.handle).setValue(true) // Tell
        
        let userRef = database.ref.child("users").child(mainUser.handle)
        userRef.child("groupInvites").child(self.group.id).removeValue() // Remove this group from the list of group invites for the user
        userRef.child("groups").child(self.group.id).setValue(true) // Set this group as one of the user's group
        
        // Delete the notification for the user
        let notificationRef = database.ref.child("notifications").child(mainUser.handle)
        // Sort by notifications sent from this group
        notificationRef.queryOrdered(byChild: "groupID").queryEqual(toValue: self.group.id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for (key, value) in values {
                    if let dict = value as? [String: Any] {
                        if dict["type"] as! Int == NotificationType.GROUP_INVITE.rawValue {
                            notificationRef.child(key as! String).removeValue() // Delete this notification
                        }
                    }
                }
            }
        })
        
        // Add a group join notification
        
        // Hide the invite buttons
        (self.parent as! GroupProfilePageViewController).hideInviteButtons()
        
        // Remove the notification somewhere
        //let matches = mainUser.notifications.filter({$0.group.groupID == self.group.groupID && $0.type == NotificationType.GROUP_INVITE })
        //if matches.count == 1 {
            //mainUser.notifications.index(of: matches[0])
        //}
        
        // Load the rest of the group data - mainly just the posts data
        groupRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                let postsData = values["posts"] as? [String : [String : Any]] ?? [String : [String : Any]]() // Default empty dictionary incase there are no posts
                
                self.group.postsData = postsData
                self.group.memberHandles.append(mainUser.handle)
                self.group.members.append(mainUser)
                
                groups.append(self.group)
            }
        })
        
        // Remove the group invite notification
        if let index = mainUser.notifications.index(where: { $0.group != nil && $0.group!.id == self.group.id && $0.type == NotificationType.GROUP_INVITE}) { // Attempt to find this notification
            mainUser.notifications.remove(at: index) // Then remove it
        }
        
        // Remove this group as a local incoming group invite
        mainUser.groupInvites.remove(at: mainUser.groupInvites.index(of: self.group.id)!)
        
        // Add this group to the local list of groups
        mainUser.groupIDs.append(self.group.id)
    }
    
    // If the user declines the invite to join this group - most of this is the same as acceptGroupInvitePressed(above)
    @IBAction func decineGroupInvitePressed(_ sender: Any) {
        let groupRef = database.ref.child("groups").child(self.group.id)
        groupRef.child("invitedUsers").child(mainUser.handle).removeValue() // Remove the outgoing invite from the groups json
        groupRef.child("members").child(mainUser.handle).setValue(true) // Tell
        
        // Remove this group from the list of group invites for the user
        database.ref.child("users").child(mainUser.handle).child("groupInvites").child(self.group.id).removeValue()
        
        // Delete the notification for the user
        let notificationRef = database.ref.child("notifications").child(mainUser.handle)
        // Sort by notifications sent from this group
        notificationRef.queryOrdered(byChild: "groupID").queryEqual(toValue: self.group.id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                for (key, value) in values {
                    if let dict = value as? [String: Any] {
                        if dict["type"] as! Int == NotificationType.GROUP_INVITE.rawValue {
                            notificationRef.child(key as! String).removeValue() // Delete this notification
                        }
                    }
                }
            }
        })
        
        // Hide the invite buttons
        (self.parent as! GroupProfilePageViewController).hideInviteButtons()
        
        // Remove the group invite notification
        if let index = mainUser.notifications.index(where: { $0.group != nil && $0.group!.id == self.group.id && $0.type == NotificationType.GROUP_INVITE}) { // Attempt to find this notification
            mainUser.notifications.remove(at: index) // Then remove it
        }

        // Remove this group as a local incoming group invite
        mainUser.groupInvites.remove(at: mainUser.groupInvites.index(of: self.group.id)!)
    }
}

// Second Page for the group info at the top of the group profile - not shown by default
// Contains when the group was created, who created it, and how many people are in the group
class GroupProfileViewControllerPage2: UIViewController {
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var groupSizeLabel: UILabel!
    @IBOutlet weak var creatorProfilePhotoView: UIImageView!
    
    weak var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Temporary check, in the future the groupCreator's name MUST be loaded at this time
        if self.group.creator == nil || self.group.creator.fullName == "" {
            self.creatorNameLabel.text = "Could not retrieve"
            
        } else {
            self.creatorNameLabel.text = "@\(group.creator.handle)"
            self.creatorProfilePhotoView.image = group.creator.profilePhoto
            self.dateCreatedLabel.text = convertDateToCalendar(date: group.creationDate)
            
            // Make the profile photo crop to a circle
            self.creatorProfilePhotoView.layer.cornerRadius = self.creatorProfilePhotoView.frame.size.width / 2
            self.creatorProfilePhotoView.clipsToBounds = true
        }
        
        self.groupSizeLabel.text = "\(group.members.count)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func convertDateToCalendar(date: Date) -> String {
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let ret = "\(month)/\(day)/\(year)"
        
        return ret
    }
}
