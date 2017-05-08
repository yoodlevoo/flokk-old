//
//  User.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 2/3/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation
import UIKit

// A class that represents all user in Flokk.
// There will be a user clas created for the main user(the one that is logged in and using the local app),
//  as well as each user the main user interacts with.
class User: Hashable { // Hashable so it can be used as a key in a dictionary(for comments)
    var handle: String // A completely unique identifier(ie. @gannonprudhomme)
    var fullName: String
    var profilePhoto: UIImage
    
    var groups = [Group]() // The groups this user is in
    
    var mainUser: Bool! // Is it the main/local user - not sure if I want this or not.
    var friends = [User]() // Array of all friends this user has
    var openFriendRequests = [User]() // Array of users that requested to be this user's friend
    
    init(handle: String, fullName: String) {
        self.handle = handle
        self.fullName = fullName
        self.profilePhoto = UIImage(named: "AddProfilePic")! //temporary
        
        loadPicture()
        loadFriends()
        
        // Load in this user's group from the database
        //self.groups = ??
    }
    
    func loadFriends() {
        if self.handle == "gannonprudhomme" {
            self.friends = [jaredUser, tavianUser, crosbyUser, grantUser, ryanUser, berginUser, alexUser, chandlerUser, madiUser, lucasUser]
        }
    }
    
    func isFriendsWith(user: User) -> Bool {
        return false
    }
    
    func addNewGroup(group: Group) {
        var json = convertToJSON()
        json["groups"].appendIfArray(json: JSON(group.getFriendlyGroupName()))
        
        FileUtils.saveUserJSON(json: json, user: self)
        
        groups.append(group)
    }
    
    // Load in this user's profile photo from the database
    // For now just set it manually
    private func loadPicture() {
        //var ret: UIImage
        
        if let image = UIImage(named: handle + "ProfilePhoto") {
            self.profilePhoto = image
        } else {
            self.profilePhoto = UIImage(named: "AddProfilePic")!
        }
        
        //return ret
    }
    
    func convertToJSON() -> JSON {
        var json: JSON = [
            "handle": handle,
            "fullName": fullName,
            "profilePhoto": handle + "ProfilePhoto",
            
            "groups": [ ]
        ]
        
        for group in groups {
            json["groups"].appendIfArray(json: JSON(group.getFriendlyGroupName()))
        }
        
        return json
    }
    
    
    // Method needed to implement hashable
    // Used to store and match values in a dictionary
    var hashValue: Int {
        get {
            // As the handles are unique, this value is also unique
            return handle.hashValue
        }
    }
    
    // The func Equatable, needed to implement Hashable
    static func ==(lh: User, rh: User) -> Bool {
        return lh.handle == rh.handle //all handles are unique
    }
    
    // Override the description variable to display information
    // About this class when this class is printed - like Java's .toString() method
    public var description: String {
        return "User: handle: \(handle) full name: \(fullName)"
    }
}
