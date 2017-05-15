//
//  Post.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 2/3/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation
import UIKit

//A class that represents each indivual image post in a group's feed.
//This class will contain all of a posts likes, the image itself, and all of the comments on it.
class Post {
    var poster: User //the user who posted the image
    var image: UIImage //the image posted
    
    var comments = [Comment]() //holds all the comments, hopefully stored in order
    var postedGroup: Group
    
    var index: Int //represents this posts position in the post array from the group
    
    init(poster: User, image: UIImage, postedGroup: Group, index: Int) {
        self.poster = poster
        self.image = image
        self.postedGroup = postedGroup
        self.index = index
        
        loadCommentsLocallySwifty()
    }
    
    func loadCommentsLocally() {
        if let path = Bundle.main.url(forResource: "comments", withExtension:"json") {
            do {
                let data = try Data(contentsOf: path, options: .mappedIfSafe)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    if let jsonData = json as? [String: Any] {
                        if let commentsJSON = jsonData["comments"] as? [[String: Any]] {
                            for comment in commentsJSON {
                                if let handle = comment["handle"] as? String{
                                    if let content = comment["content"] as? String {
                                        comments.append(Comment(user: findUserInGroupWith(handle: handle), content: content))
                                    }
                                }
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Error: \(error)")
                }
            } catch let error as NSError {
                print("Error: \(error)")
            }
        }
    }
    
    func loadCommentsLocallySwifty() {
        if let path = Bundle.main.url(forResource: postedGroup.getUniqueName(), withExtension:"json") {
            do {
                let data = try Data(contentsOf: path, options: .mappedIfSafe)
                
                let json = JSON(data: data)
                for (_, comment) in json["comments"] {
                    let handle = comment["handle"].string
                    let content = comment["content"].string
                    
                    comments.append(Comment(user: findUserInGroupWith(handle: handle!), content: content!))
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    //find the user from the participants in this group just by using their handle
    //when we have the database we can reduce storage by getting this frk
    //this should be in the Group class anyways
    func findUserInGroupWith(handle: String) -> User {
        for user in postedGroup.members {
            if user.handle == handle {
                return user
            }
        }
        
        print("user with handle \(handle) is not listed in the participants group")
        return User(handle: "nil", fullName: "Nil Nil")
    }
    
    func getUniqueName() -> String {
        return postedGroup.getUniqueName() + poster.handle + "\(index)"
    }
    
    func convertToJSON() -> JSON {
        let imageName = getUniqueName()
        let postData: JSON = [
            "handle": "gannonprudhomme",
            "imageName": imageName,
            "date": "12341234",
            "comments": []
        ]
        
        return postData
    }

    //upload the post to the group's json file
    func uploadPostToFile() {
        let imageName = getUniqueName()
        let postData = convertToJSON()
        
        //var groupJSON = postedGroup.convertToJSONWithNewPost(post: self)
        
        //groupJSON["posts"].appendIfArray(json: convertToJSON())
        
        //write over the file
        //FileUtils.saveGroupJSON(json: groupJSON, group: postedGroup)
    }
    
    //override the description variable to display information
    //about this class when this class is printed - like Java's .toString() method
    public var description: String {
        return "Posted by: (\(poster.description)) in group: (\(postedGroup.groupName)) at index: (\(index))"
    }
}

// A class that holds the values for comments on Posts
// I'm not happy this has to be a separate class lol
class Comment {
    var user: User //the user who posted the comment
    var content: String //the text of the comment
    var date: Date
    
    init(user: User, content: String) {
        self.user = user
        self.content = content
        self.date = Date() //later this needs to be loaded alongside the rest of the data, not created here
    }
}
