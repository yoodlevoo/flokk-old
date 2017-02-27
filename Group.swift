//
//  File.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 1/27/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation
import UIKit

//how should i determine what this groups unique handle is?
class Group {
    var groupCreator: User! //whoever created the group, has all the "admin" rights on it
    
    var groupName: String
    var groupIcon: UIImage
    
    var participants = [User]() //the users that are in this group
    var posts = [Post]()
    
    init() {
        self.groupName = "filler"
        self.groupIcon = UIImage(named: "HOME ICON")! //just some filler image
    }
    
    init(groupName: String, image: UIImage, users: [User], creator: User) {
        self.groupName = groupName
        self.groupIcon = image
        self.participants = users
        self.groupCreator = creator
    }
    
    //Load all of the most recent Posts from this group
    func loadPosts() {
        //for now just have some temporary posts
        //does this need to happen inside this class?
    }
    
    //A unique name used for storing and sorting
    func getUniqueName() -> String {
        return "\(groupCreator.handle)\(groupName)"
    }
    
    static func createUniqueName(creatorsHandle:String, groupName:String) -> String {
        return "\(creatorsHandle)\(groupName)"
    }
}
