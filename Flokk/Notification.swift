//
//  Notification.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/2/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import Foundation

// Enum for the different kinds of Notifications
enum NotificationType {
    case NEW_POST
    case FRIEND_REQUESTED // Someone requested to be your friend
    case FRIEND_REQUEST_ACCEPTED // Somone accepted your friend request
    case GROUP_INVITE
    case NEW_COMMENT // Should the user be notified for a new comment if its not on their post?
}

let GROUP_INVITE_DESCRIPTION = ""

class Notification {
    var type: NotificationType
    var sender: User // Whoever caused this notification
    var receiver: User! // Receiver is always going to be this(main) user
    var group: Group! // Optional, not all notifications are going to involve a group
    var post: Post! // Optional, not all notifications are going to involve a post
    var description: NSMutableAttributedString! // Set as a Attributed String so we can bold specific parts of it
    var comment: String!
    
    static var textSize: Float!
    
    // MARK: Different initializers for the different kinds of Notifications
    
    // Friend Request or Friend Accepted Your Friend Request
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
