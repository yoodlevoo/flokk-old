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
    
    init(poster: User, image: UIImage, postedGroup: Group) {
        self.poster = poster
        self.image = image
        self.postedGroup = postedGroup
        
        loadCommentsLocally()
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
        
    }
    
    //find the user from the participants in this group just by using their handle
    //when we have the database we can reduce storage by getting this frk
    func findUserInGroupWith(handle: String) -> User {
        for user in postedGroup.participants {
            if user.handle == handle {
                return user
            }
        }
        
        print("user with handle \(handle) is not listed in the participants group")
        return User(handle: "nil", fullName: "Nil Nil")
    }
    
    //loads the comments from the relevant JSON file
    //how should we decide how to store each post's comment(ie the file name)
    func loadCommentsNetwork() {
        //this is a URL to my dropbox, where a JSON file is located
        /*
        let requestUrl: URL = URL(string: "https://www.learnswiftonline.com/Samples/subway.json")!
        
        let urlRequest: URLRequest = URLRequest(url: requestUrl as URL)
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest){ data,response,error in
        
        let httpResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode
            
            if(statusCode == 200) { //if the resource was accessed correctly and exists, etc
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    
                    if let jsonData = json as? [String: Any] {
                        if let comments = jsonData["comments"] as? [[String: Any]] { //double square bracket means array of dicts
                            for comment in comments {
                                if let handle = comment["handle"] as? String {
                                    if let content = comment["content"] as? String {
                                        print("\(handle) said: \(content)")
                                    }
                                }
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Error with JSON: \(error)")
                }
            }
        }
        
        task.resume()
 
    */
    }
    
    func getUniqueName() {
        
    }
}

//A class that holds the values for comments on Posts
//I'm not happy this has to be a separate class lol
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
