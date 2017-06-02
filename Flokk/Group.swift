//
//  File.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 1/27/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import Foundation
import UIKit

//how should i determine what this groups unique handle is?
class Group {
    var groupCreator: User! //whoever created the group, has all the "admin" rights on it - this should never be nil
    private var groupCreatorHandle: String! // Loaded in in the groups view, not needed immediately so no need to download extra data
    
    // rename these just to say index, id, name, icon, etc
    var groupIndex: Int! // The index of this group in the global groups array
    var groupID: String!
    var groupName: String
    //var internalGroupName: String! //this could still be the same as the groupName sometimes
    var groupIcon: UIImage
    var totalPostsCount: Int!
    
    var members = [User]() //the users that are in this group
    var memberHandles = [String]() // The user handles that are in this group, not fully loaded until Group Settings b/c useless otherwise?
    
    var posts = [Post]() // The posts that have been loaded in, from newest to oldest
    //var loadedPosts = [Post]() // The posts that have been loaded so far
    var postsData = [String : [String: Any?]]() // loaded in in the Groups view, then used by the feedView to quickly download the post images
    
    var numNewPosts: Int! //the amount of new posts the mainUser has missed from this group
    
    init() {
        self.groupID = "fillerID"
        self.groupName = "fillerName"
        self.groupIcon = UIImage(named: "HOME ICON")! //just some filler image
        self.groupCreator = User(handle: "filler", fullName: "filler")
        
        self.numNewPosts = 0
        self.totalPostsCount = 0
    }
    
    init(groupID: String, groupName: String, image: UIImage) {
        self.groupID = groupID
        self.groupName = groupName
        self.groupIcon = image
    }
    
    init(groupID: String, groupName: String, image: UIImage, users: [User], creator: User) {
        self.groupID = groupID
        self.groupName = groupName
        self.groupIcon = image
        self.members = users
        self.groupCreator = creator
        self.numNewPosts = 0
        self.totalPostsCount = 0
        
        //self.internalGroupName = Group.createFriendlyGroupName(name: groupName)
    }
    
    init(groupID: String, groupName: String, groupIcon: UIImage, memberHandles: [String], postsData: [String : [String: Any?]], creatorHandle: String) {
        self.groupID = groupID
        self.groupName = groupName
        self.groupIcon = groupIcon
        self.memberHandles = memberHandles
        self.postsData = postsData
        self.groupCreatorHandle = creatorHandle
        
    }
    
    //Load all of the most recent Posts from this group - uses SwiftyJSONb
    func loadPosts(numPostsToLoad: Int) -> [Post] {
        var posts = [Post]()
        
        return posts
    }
    
    /*
    
    //create an internal group name from the original group name
    //which is fixed so there are no characters that will cause errors(eg. spaces)
    //for things like file storing and such
    static func createFriendlyGroupName(name: String) -> String {
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
        return groupCreator.handle + getFriendlyGroupName()
    }
    
    func getFriendlyGroupName() -> String {
        return Group.createFriendlyGroupName(name: self.groupName)
    }
    
    static func createUniqueName(creatorsHandle:String, groupName:String) -> String {
         return creatorsHandle + groupName
    }
    
    //ONLY USE THIS IN FEED VIEW prepareForSegue to PhotoSelectView
    //this is the only work around i can se
    func setPostJSON(json: JSON) {
        postJSON = json
    }
 
    */
    
    //for sorting the posts in the GroupView's priority view
    //so the posts with the most recent/newest posts are at the top
    //should this be sorted by most recent posts/date instead of numNewPosts?
    static func < (leftGroup: Group, rightGroup: Group) -> Bool {
        return leftGroup.numNewPosts < rightGroup.numNewPosts
    }
}
