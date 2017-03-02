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
    
    //Load all of the most recent Posts from this group - uses SwiftyJSON
    func loadPosts(numPostsToLoad: Int) {
        if(numPostsToLoad <= 0) { //preventive error checking
            print("Num posts to load is <= 0")
            return
        }
        
        //load the file
        let path = Bundle.main.url(forResource: getUniqueName(), withExtension: "json")
        do {
            //load the contents of the file
            let data = try Data(contentsOf: path!, options: .mappedIfSafe)
            
            //parse the JSON
            let json = JSON(data: data)
            
            var index: Int = 0
            for (_, post) in json["group"]["posts"] {
                if index < FeedViewController.initialPostCount - 1 { //subtract 1 b/c index starts at 0
                    let userHandle = post["handle"].string
                    let imageName = post["imageName"].string
                    
                    posts.append(Post(poster: findUserWithHandle(handle: userHandle!), image: UIImage(named: imageName!)!, postedGroup: self, index: index))
                    index += 1
                } else { //stop loading after the right amount of posts have been loaded
                    break
                }
            }
            
        } catch let error as NSError {
            print("Error: \(error)")
        }
        //let json = JSON(data: data)
        //let handle = json["group"]
    }
    
    func loadPostsNew(numPostsToLoad: Int) {
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
                } else {
                    break
                }
            }
        } catch let error as NSError {
            print("Error: \(error)")
        }
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
            "posts": [] //fill this in later
        ]
        
        for post in posts {
            json["posts"].appendIfArray(json: post.convertToJSON())
        }
        
        return json
    }
}
