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
    
    var comments = [Comment]() //holds all the comments
    
    init(poster: User, image: UIImage) {
        self.poster = poster
        self.image = image
    }
}

//A class that holds the values for comments on Posts
//I'm not happy this has to be a separate class lol
class Comment {
    var user: User //the user who posted the comment
    var comment: String //the text of the comment
    
    init(user: User, comment: String) {
        self.user = user
        self.comment = comment
    }
}
