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
    var groupName: String
    var groupIcon: UIImage
    
    var participants = [User]() //the users that are in this group
    var posts = [Post]()
    
    init() {
        self.groupName = "filler"
        self.groupIcon = UIImage(named: "HOME ICON")! //just some filler image
    }
    
    init(text: String, image: UIImage, users: [User]) {
        self.groupName = text
        self.groupIcon = image
        self.participants = users
    }
    
    //Load all of the most recent Posts from this group
    func loadPosts() {
        //for now just have some temporary posts
        
    }
}
