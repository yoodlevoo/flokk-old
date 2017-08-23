//
//  File.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 1/27/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import Foundation
import UIKit

// A class that represents all groups in Flokk, the whole basis of Flokk
// On creation, at the very minimum, a group is given a completely unique identifier(groupID), a group name, and an icon/image.
class Group {
    var creator: User! //whoever created the group, has all the "admin" rights on it - this should never be nil
    var creatorID: String! // Loaded in in the groups view, not needed immediately so no need to download extra data
    
    // rename these just to say index, id, name, icon, etc
    var id: String // The (firebase) unique ID for this group in the database, generated by .childByAutoID()
    var name: String // The non-unique name for this group
    //var internalGroupName: String! //this could still be the same as the groupName sometimes
    var icon: UIImage? // The icon, or "profile photo", for this group
    var totalPostsCount: Int!
    
    var members = [User]() // The users that are in this group
    var memberIDs = [String]() // The user ids that are in this group, not fully loaded until Group Settings b/c useless otherwise?
    
    var creationDate: Date! // The date this group was created
    
    var invitedUsers = [String]() // All of the user ids that have been invited to this group
    
    var posts = [Post]() // The posts that have been loaded in, from newest to oldest
    //var loadedPosts = [Post]() // The posts that have been loaded so far
    var postsData = [String : [String: Any]]() // loaded in in the Groups view, then used by the feedView to quickly download the post images
    var sortedPostsKeys = [String]() // The keys
    var loadingPostIDs = [String]() // ID of posts that are loading/are loaded
    
    var numNewPosts: Int! //the amount of new posts the mainUser has missed from this group
    
    var mostRecentPost = Date() // The Date of the most recent post
    
    init() {
        self.id = "fillerID"
        self.name = "fillerName"
        self.icon = UIImage(named: "HOME ICON")! //just some filler image
        self.creator = User(uid: "filler", handle: "filler", fullName: "filler")
        
        self.numNewPosts = 0
        self.totalPostsCount = 0
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        //self.icon = UIImage()
    }
    
    init(id: String, name: String, icon: UIImage) {
        self.id = id
        self.name = name
        self.icon = icon
    }
    
    init(id: String, name: String, icon: UIImage, creationDate: Date) {
        self.id = id
        self.name = name
        self.icon = icon
        self.creationDate = creationDate
    }
    
    init(id: String, name: String, icon: UIImage, users: [User], creator: User) {
        self.id = id
        self.name = name
        self.icon = icon
        self.members = users
        self.creator = creator
        self.numNewPosts = 0
        self.totalPostsCount = 0
        
        //self.internalGroupName = Group.createFriendlyGroupName(name: groupName)
    }
    
    init(id: String, name: String, icon: UIImage, users: [User], creator: User, creationDate: Date) {
        self.id = id
        self.name = name
        self.icon = icon
        self.members = users
        self.creator = creator
        self.numNewPosts = 0
        self.totalPostsCount = 0
        self.creationDate = creationDate
        
        //self.internalGroupName = Group.createFriendlyGroupName(name: groupName)
    }
    
    init(id: String, name: String, icon: UIImage, memberIDs: [String], postsData: [String : [String: Any?]], creatorID: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.memberIDs = memberIDs
        self.postsData = postsData
        self.creatorID = creatorID
        
    }
    
    // Check for the most recent post
    func updateMostRecentPost() {
        var timestamp = 0.0
        
        for post in self.posts {
            // If this timestamp is greater than the previous, then it was more recent
            if post.timestamp.timeIntervalSinceReferenceDate > timestamp {
                timestamp = post.timestamp.timeIntervalSinceReferenceDate
            }
        }
        
        
        self.mostRecentPost = Date(timeIntervalSinceReferenceDate: timestamp)
    }
    
    // Go through all of postsData and put the keys with the most recent first at the beginning of sortedPostKeys
    // Try not to run this too much cause it's really inefficient
    func sortPostsData() {
        var sortDict = [String : Double]() // Dictionary of the postIDs and dates
        
        // Fill the sort dict with postIDs and the relevant timestamps
        for (id, data) in self.postsData {
            let timestamp = data["timestamp"] as! Double
            
            sortDict[id] = timestamp
        }
        
        let sortedKeys = Array(sortDict.keys).sorted(by: <)
        
        // Set the sortedPostsKeys variable to the more recent and reletave post
        self.sortedPostsKeys = sortedKeys
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
