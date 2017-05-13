//
//  ConfirmUploadViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/1/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class ConfirmUploadViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var image: UIImage!
    
    var forGroup: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadPressed(_ sender: Any) {
        let postsRef = database.ref.child("groups").child(forGroup.groupName).child("posts")
        let imageRef = storage.ref.child("groups").child(forGroup.groupName).child("posts")
        var autoID = postsRef.childByAutoId() // Generate random ID for this post
        
        
        
        // Start storage here
        
        self.performSegue(withIdentifier: "segueFromConfirmedImageToFeed", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromConfirmedImageToFeed" {
            if let feedNav = segue.destination as? FeedNavigationViewController {
                // Use the imageView because it might be changed asynchronously
                //let post = Post(poster: mainUser, image: imageView.image!, postedGroup: forGroup, index: forGroup.totalPostsCount)
                //forGroup.posts.append(post)
                
               // post.uploadPostToFile()
                
                //FileUtils.savePostImage(post: post)
                
                // We increse the totalPostsCount inside of Group.convertToJSONWithNewPost()
                //forGroup.totalPostsCount += 1
                //feedNav.groupToPass = forGroup
                
                //print(post.description)
            }
        } else if let photoUploadPageNav = segue.destination as? PhotoUploadPageNavigationViewController {
            photoUploadPageNav.groupToPass = forGroup
        }
    }
}
