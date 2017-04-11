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
    var groupCreator: User //whoever created the group, has all the "admin" rights on it - this should never be nil
    
    var groupName: String
    //var internalGroupName: String! //this could still be the same as the groupName sometimes
    var groupIcon: UIImage
    var totalPostsCount: Int
    
    var participants = [User]() //the users that are in this group
    //var posts = [Post]()
    
    var numNewPosts: Int //the amount of new posts the mainUser has missed from this group
    
    private var postJSON: JSON! //json used in convertToJSON, set by FeedViewController in prepareForSegue
    
    init() {
        self.groupName = "filler"
        self.groupIcon = UIImage(named: "HOME ICON")! //just some filler image
        self.groupCreator = User(handle: "filler", fullName: "filler")
        
        self.numNewPosts = 0
        self.totalPostsCount = 0
    }
    
    init(groupName: String, image: UIImage, users: [User], creator: User) {
        self.groupName = groupName
        self.groupIcon = image
        self.participants = users
        self.groupCreator = creator
        self.numNewPosts = 0
        self.totalPostsCount = 0
        
        //self.internalGroupName = Group.createFriendlyGroupName(name: groupName)
    }
    
    //Load all of the most recent Posts from this group - uses SwiftyJSONb
    func loadPosts(numPostsToLoad: Int) -> [Post] {
        var posts = [Post]()
        
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let groupURL = documentsURL?.appendingPathComponent(groupName)
        let jsonURL = groupURL?.appendingPathComponent(groupName + ".json")
        let jsonFile = URL(fileURLWithPath: (jsonURL?.absoluteString)!)
        
        do {
            let data = try Data(contentsOf: jsonFile, options: .mappedIfSafe)
            
            let json = JSON(data: data)
            
            var index: Int = 0
            for (_, post) in json["posts"] {
                if index < FeedViewController.initialPostCount - 1 {
                    let userHandle = post["handle"].string
                    let imageName = post["imageName"].string
                
                    let image = FileUtils.loadPostImage(group: self, fileName: imageName!)
                
                    posts.append(Post(poster: findUserWithHandle(handle: userHandle!), image: image, postedGroup: self, index: index))
                    index += 1
                    
                    print("image name \(imageName)")
                } else {
                    break
                }
            }
        } catch let error as NSError {
            print("Error: \(error)")
        }
        
        return posts
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
    
    func convertToJSON() -> JSON {
        var users = [String]()
        
        for user in participants {
            users.append(user.handle)
        }
        
        var json: JSON = [
            "groupName": groupName,
            "groupIcon": groupName + "Photo",
            "creator": mainUser.handle,
            "users": users,
            "postsCount": totalPostsCount,
            "posts": [] //fill this in later
        ]
        
        //for post in posts {
            //json["posts"].appendIfArray(json: post.convertToJSON())
        //}
        
        return json
    }
    
    func convertToJSONWithNewPost(post: Post) -> JSON{
        var users = [String]()
        
        for user in participants {
            users.append(user.handle)
        }
        
        var postToArray: JSON = [post.convertToJSON().object]
        
        var postsData = JSON(postJSON.arrayObject! + postToArray.arrayObject!)
        totalPostsCount += 1
        
        var json: JSON = [
            "groupName": groupName,
            "groupIcon": groupName + "Photo",
            "creator": mainUser.handle,
            "users": users,
            "postsCount": totalPostsCount, //this is increased in the 
            "posts": postsData.arrayObject! //fill this in later
        ]
        
        return json
    }
    
    //ONLY USE THIS IN FEED VIEW prepareForSegue to PhotoSelectView
    //this is the only work around i can se
    func setPostJSON(json: JSON) {
        postJSON = json
    }
    
    //for sorting the posts in the GroupView's priority view
    //so the posts with the most recent/newest posts are at the top
    //should this be sorted by most recent posts/date instead of numNewPosts?
    static func < (leftGroup: Group, rightGroup: Group) -> Bool {
        return leftGroup.numNewPosts < rightGroup.numNewPosts
    }
}
