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
    
    var group: Group! // This is just a copy of the actual group - no its not you fucking idiot its a reference
    
    override func viewDidLoad() {
        super.viewDidLoad() 

        /*
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func uploadPressed(_ sender: Any) {
        let postsRef = database.ref.child("groups").child(group.id).child("posts") // Database
        let imageRef = storage.ref.child("groups").child(group.id).child("posts") // Storage
        let key = postsRef.childByAutoId().key // Generate random ID for this post
        
        self.image = imageView.image
        
        // Upload the post image to Storage
        imageRef.child("\(key)/post.jpg").put(image.convertJpegToData(), metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
        }
        
        // Upload the data about this post to the Database
        postsRef.child("\(key)").child("poster").setValue(mainUser.handle)
        postsRef.child("\(key)").child("timestamp").setValue(NSDate.timeIntervalSinceReferenceDate)
        
        //let post = Post(poster: mainUser, image: self.imageView.image!, postID: key)
        let post = Post(posterHandle: mainUser.handle, image: self.imageView.image!, postID: key, timestamp: Date(timeIntervalSinceReferenceDate: NSDate.timeIntervalSinceReferenceDate))
        
        // Search for this group's index - I don't want to have to do this and I don't think it's necessary
        let index = groups.index(where: { (item) -> Bool in
            item.name == group.name
        })
        
        self.group.posts.append(post) // Add this post to the group
        self.group.loadingPostIDs.append(post.id) // Add this id to the loading post id's, so the feed view doesn't try to load this photo
        self.group.posts.sort(by: { $0.timestamp.timeIntervalSinceReferenceDate < $1.timestamp.timeIntervalSinceReferenceDate}) // Sort the post chronologically
        
        // Add a reference to this post in uploaded posts for the main user to be accessed in the personal profile
        let uploadedPostsRef = database.ref.child("users/\(mainUser.handle)/uploadedPosts/\(self.group.id)/\(post.id!)")
        uploadedPostsRef.setValue(NSDate.timeIntervalSinceReferenceDate)
        
        // Add the data locally to the uploadedPostsData
        mainUser.uploadedPostsData[self.group.id]?[post.id] = NSDate.timeIntervalSinceReferenceDate
        
        self.performSegue(withIdentifier: "unwindToFeedFromConfirmUpload", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feedView = segue.destination as? FeedViewController {
            // Do we need to pass anything
        }
    }
}
