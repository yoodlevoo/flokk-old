//
//  Notification.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/2/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import Foundation
import UIKit

// Enum for the different kinds of Notifications
enum NotificationType: Int {
    case NEW_POST = 0,
    FRIEND_REQUESTED, // Someone requested to be your friend
    FRIEND_REQUEST_ACCEPTED, // Somone accepted your friend request
    GROUP_INVITE, // Someone invited the main user to join a group
    GROUP_JOINED, // Someone accepted an invite to a group the main user is in
    NEW_COMMENT // Should the user be notified for a new comment if its not on their post?
}

let GROUP_INVITE_DESCRIPTION = ""

class Notification {
    var type: NotificationType
    var sender: User? // Whoever caused this notification
    var senderHandle: String!
    var receiver: User? // Receiver is always going to be this(main) user
    var group: Group? // Optional, not all notifications are going to involve a group
    var post: Post? // Optional, not all notifications are going to involve a post
    var description: NSMutableAttributedString! // Set as a Attributed String so we can bold specific parts of it
    var comment: String!
    
    static var textSize: Float!
    
    // MARK: Different initializers for the different kinds of Notifications
    
    // Friend Request or Friend Accepted Your Friend Request
    init(type: NotificationType, senderHandle: String) {
        self.type = type
        self.senderHandle = senderHandle
        Notification.textSize = 20
        
        // Load the user
        if !storedUsers.keys.contains(senderHandle) { // If the user hasn't been loaded yet
            // Careful doing this, it's going to load all of the child data, not just the fullName
            database.ref.child("users").child(senderHandle).observeSingleEvent(of: .value, with: { (snapshot) in
                if let values = snapshot.value as? [String : Any] {
                    let fullName = values["fullName"] as! String
                    
                    // Bold the sender's name
                    let formattedString = NSMutableAttributedString()
                    if type == NotificationType.FRIEND_REQUESTED { // If someone requested to be your friend
                        formattedString.bold("\(fullName) ", Notification.textSize).normal("added you as a friend.")
                    } else if type == NotificationType.FRIEND_REQUEST_ACCEPTED { // If someone accepted your friend requests
                        formattedString.bold("\(fullName) ", Notification.textSize).normal("accepted your friend request.")
                    }
                    
                    self.description = formattedString
                    
                    // Download the profile Photo
                    let profilePhotoRef = storage.ref.child("users").child(senderHandle).child("profilePhoto.jpg")
                    profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                        if error == nil { // If there wasn't an error
                            let profilePhoto = UIImage(data: data!)
                            
                            self.sender = User(handle: senderHandle, fullName: fullName, profilePhoto: profilePhoto!)
                            storedUsers[senderHandle] = self.sender // Add this value to the stored user dict
                        } else { // If there was an error
                            print(error!)
                        }
                    })
                }
            })
        } else { // If the user has been loaded
            self.sender = storedUsers[senderHandle] // Get it from all of the stored users
        }
    }
    
    // Friend request or a friend Accepted your friend request
    init(type: NotificationType, sender: User) {
        self.type = type
        self.sender = sender
        Notification.textSize = 20
        
        // Bold the sender's name
        let formattedString = NSMutableAttributedString()
        if type == NotificationType.FRIEND_REQUESTED { // If someone requested to be your friend
            formattedString.bold("\(sender.fullName) ", Notification.textSize).normal("added you as a friend.")
        } else if type == NotificationType.FRIEND_REQUEST_ACCEPTED { // If someone accepted your friend requests
            formattedString.bold("\(sender.fullName) ", Notification.textSize).normal("accepted your friend request.")
        }
        
        self.description = formattedString
    }
    
    // Group Invite Notification
    init(type: NotificationType, sender: User, group: Group!) {
        self.type = type
        self.sender = sender
        self.group = group
        Notification.textSize = 20
        
        //print("\(sender.fullName)")
        //print(group.groupName)
        
        // Bold the sender's name and the group name
        let formattedString = NSMutableAttributedString()
        formattedString.bold("\(sender.fullName) ", Notification.textSize).normal("invited you to join").bold(" \(group.groupName).", Notification.textSize)
        
        self.description = formattedString
    }
    
    // New Comment Notification
    init(type: NotificationType, sender: User, group: Group, post: Post, comment: String) {
        self.type = type
        self.sender = sender
        self.group = group
        self.post = post
        self.comment = comment
        Notification.textSize = 20
        
        // Bold the sender's name
        let formattedString = NSMutableAttributedString()
        formattedString.bold("\(sender.fullName) ", Notification.textSize).normal("commented \" (comment here) \" in").bold(" \(group.groupName).", Notification.textSize)
        
        self.description = formattedString // Figure out how to shorten the comment it fits
    }
    
    // New Post Notification
    init(type: NotificationType, sender: User, group: Group, post: Post) {
        self.type = type
        self.sender = sender
        self.group = group
        self.post = post
        Notification.textSize = 20
        
        let formattedString = NSMutableAttributedString()
        formattedString.bold("\(sender.fullName) ", Notification.textSize).normal("uploaded a new post to").bold(" \(group.groupName).", Notification.textSize)
        
        self.description = formattedString
    }
    
    //
    
    //add this to the stack on the notification tab - I don't think i can do this
    func addToNotificationTab() {
        
    }
    
    func notifyReceiver() {
        
    }
}
