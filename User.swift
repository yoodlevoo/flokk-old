//
//  User.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 2/3/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation
import UIKit

//A class that represents all user in Flokk.
//There will be a user clas created for the main user(the one that is logged in and using the local app),
//as well as each user the main user interacts with.
class User/*: Hashable*/ { //hashable so it can be used as a key in a dictionary(for comments)
    var usernameHandle: String //a completely unique identifier(ie. @gannonprudhomme)
    var fullName: String
    var profilePhoto: UIImage
    
    var groups = [Group]() //the groups this user is in
    
    var mainUser: Bool! //is it the main/local user - not sure if I want this or not.
    
    init(usernameHandle: String, fullName: String) {
        self.usernameHandle = usernameHandle
        self.fullName = fullName
        self.profilePhoto = UIImage(named: "AddProfilePic")! //temporary
        
        loadPicture()
        
        //load in this user's group from the database
        //self.groups = ??
    }
    
    //load in this user's profile photo from the database
    //for now just set it manually
    func loadPicture() {
        //var ret: UIImage
        
        if(usernameHandle == "gannonprudhomme") {
            profilePhoto = UIImage(named: "ellipse-4")!
        } else if(usernameHandle == "jaredheyen") {
            profilePhoto = UIImage(named: "ellipse-3")!
        } else {
            profilePhoto = UIImage(named: "ellipse-2")!
        }
        
        //return ret
    }
    
    /* this might not be needed
    //method needed to implement hashable
    //used to store and match values in a dictionary
    var hashValue: Int {
        get {
            //as the handles are unique, this value is also unique
            return usernameHandle.hashValue
        }
    }
    
    //the func Equatable, needed to implement Hashable
    static func ==(lh: User, rh: User) -> Bool {
        return lh.usernameHandle == rh.usernameHandle //all handles are unique
    } */
}
