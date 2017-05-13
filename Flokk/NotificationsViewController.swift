//
//  NotificationsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 2/27/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    var notifications = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // When this view is being transitioned to - check for Notifications?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "default") as! NotificationTableViewCell
        
        // Get the corresponding notification
        let notification = notifications[indexPath.row]
        
        switch notification.type {
        case NotificationType.FRIEND_REQUESTED:
            
            break
        case NotificationType.FRIEND_REQUEST_ACCEPTED:
            
            break
        case NotificationType.GROUP_INVITE:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "groupInvite") as! NotificationTableViewCell
            
            cell.groupIconView.image = notification.group.groupIcon
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
        }
        
        Notification.textSize = Float(cell.descriptionLabel.font.pointSize) // No point in casting back and forth between CGFloat and Float
        
        cell.descriptionLabel.attributedText = notification.description
        //cell.nameLabel.text = notification.sender.fullName
        
        cell.profilePictureView.image = notification.sender.profilePhoto
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
            
            //groupProfileView.group = notification.group
            //groupProfileView.user = notification.sender
            
            //
            self.performSegue(withIdentifier: "segueFromNotificationsToGroupProfile", sender: self)
            
            break
        case NotificationType.NEW_COMMENT:
            
            break
        case NotificationType.NEW_POST:
            
            break
        }
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

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var notificationDescriptionView: UIImageView!
    @IBOutlet weak var groupIconView: UIImageView!
    
}
