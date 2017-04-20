//
//  NotificationsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 2/27/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    var notifications = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        notifications.append(Notification(type: NotificationType.FRIEND_REQUESTED, sender: jaredUser))
        
    }
    
    // When this view is being transitioned to - check for Notifications?
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! NotificationTableViewCell
        
        Notification.textSize = Float(cell.descriptionLabel.font.pointSize) // No point in casting back and forth between CGFloat and Float
        
        // Get the corresponding notification
        let notification = notifications[indexPath.row]
        
        cell.descriptionLabel.attributedText = notification.description
        //cell.nameLabel.text = notification.sender.fullName
        
        
        cell.profilePictureView.image = notification.sender.profilePhoto
        cell.profilePictureView.layer.cornerRadius = cell.profilePictureView.frame.size.width / 2
        cell.profilePictureView.clipsToBounds = true
        
        switch notification.type {
        case NotificationType.FRIEND_REQUESTED:
            
            break
        case NotificationType.FRIEND_REQUEST_ACCEPTED:
            
            break
        case NotificationType.GROUP_INVITE:
            
            break
        case NotificationType.NEW_COMMENT:
            
            break
        case NotificationType.NEW_POST:
        
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        switch notification.type {
        case NotificationType.FRIEND_REQUESTED:
            
            break
        case NotificationType.FRIEND_REQUEST_ACCEPTED:
            
            break
        case NotificationType.GROUP_INVITE:
            
            break
        case NotificationType.NEW_COMMENT:
            
            break
        case NotificationType.NEW_POST:
            
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var notificationDescriptionView: UIImageView!
    
}
