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
    
    init(poster: User, image: UIImage) {
        self.poster = poster
        self.image = image
        
        loadComments()
    }
    
    //loads the comments from the relevant JSON file
    //how should we decide how to store each post's comment(ie the file name)
    func loadComments() {
        //this is a URL to my dropbox, where a JSON file is located
        /*
        let requestUrl: URL = URL(string: "https://www.dropbox.com/scl/fi/lgu88p1win7moqdkmas77/comments.json?dl=0&oref=e&r=AAUB1tJJJRvx8G1gO2WAp0H2Hpvn3sQ0qL8yVUg1nn0zD6CyMq0Sh3H_5j7g5chi-vG3ZncRmFicnfrdh30eN0dbRbsmvanFMbtQZSXPL_XUcjda2LVaXXWEr_SXtDe_GybrZmKTFhpBIkgpksBbZvczbBAG5JgIBNMEmJQg7StHx0gmluJPE4vP5nt5sBFjE1A&sm=1")!
        
        let urlRequest: URLRequest = URLRequest(url: requestUrl as URL)
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest){ data,response,error in
        
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if(statusCode == 200) { //if the resource was accessed correctly and exists, etc
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    
                    if let jsondata = json as? [String, Any] {
                        let data = jsondata["data"]
                    }
                    
                } catch let error as NSError {
                    
                }
            }
        }
        
        task.resume()
    }
 
 */
}

//A class that holds the values for comments on Posts
//I'm not happy this has to be a separate class lol
class Comment {
    var user: User //the user who posted the comment
    var comment: String //the text of the comment
    var date: Date
    
    init(user: User, comment: String) {
        self.user = user
        self.comment = comment
        self.date = Date() //later this needs to be loaded alongside the rest of the data, not created here
    }
}
