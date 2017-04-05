//
//  Notification.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/2/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation

enum NotificationType {
    case NEW_POST
    case FRIEND_INVITE
    case GROUP_INVITE
}

class Notification {
    var type: NotificationType
    var sender: User
    var receiver: User
    var description: String
    
    init(type: NotificationType, sender: User, receiver: User, description: String) {
        self.type = type
        self.sender = sender
        self.receiver = receiver
        self.description = description
    }
    
    //add this to the stack on the notification tab
    func addToNotificationTab() {
        
    }
    
    func notifyReceiver() {
        
    }
}
