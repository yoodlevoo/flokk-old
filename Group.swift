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
    var internalGroupName: String! //this could still be the same as the groupName sometimes
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
        
        self.internalGroupName = createFriendlyGroupName(name: groupName)
    }
    
    //Load all of the most recent Posts from this group
    func loadPosts() {
        //for now just have some temporary posts
        //does this need to happen inside this class?
    }
    
    //find the user with the specified handle
    //in the future use a more efficient search
    func findUserWithHandle(handle: String) -> User {
        for user in participants {
            if user.handle == handle {
                return user
            }
        }
        
        return User(handle: "nil", fullName: "nil")
    }
    
    //create an internal group name from the original group name
    //which is fixed so there are no characters that will cause errors(eg. spaces)
    //for things like file storing and such
    func createFriendlyGroupName(name: String) -> String {
        var usableName = name
        
        if usableName.contains(" ") {
            while usableName.characters.index(of: " ") != nil { //while the name still contains a space
                let spaceIndex = usableName.characters.index(of: " ")
                
                let indexAfterSpace = usableName.index(spaceIndex!, offsetBy: 1)
                let poststring = usableName.substring(from:indexAfterSpace)
                let prestring = usableName.substring(to: spaceIndex!)
                usableName = "\(prestring)_\(poststring)"
                
                //break
            }
        }
        
        return usableName
    }
    
    //A unique name used for storing and sorting
    func getUniqueName() -> String {
        return groupCreator.handle + internalGroupName
    }
    
    static func createUniqueName(creatorsHandle:String, groupName:String) -> String {
         return creatorsHandle + groupName
    }
}
