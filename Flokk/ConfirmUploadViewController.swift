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
    
    var forGroup: Group! // This is just a copy of the actual group
    var groupIndex: Int! // The index of this group in the global groups array
    
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
        let postsRef = database.ref.child("groups").child(forGroup.groupID).child("posts") // Database
        let imageRef = storage.ref.child("groups").child(forGroup.groupID).child("posts") // Storage
        let key = postsRef.childByAutoId().key // Generate random ID for this post
        
        self.image = imageView.image
        
        // Upload the post image to Storage
        imageRef.child("\(key)/post.jpg").put(image.convertJpegToData(), metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            
            //let downloadURL = metadata.downloadURL()
        }
        
        // Upload the data about this post to the Database
        postsRef.child("\(key)").child("poster").setValue(mainUser.handle)
        postsRef.child("\(key)").child("timestamp").setValue(NSDate.timeIntervalSinceReferenceDate)
        
        let post = Post(poster: mainUser, image: self.imageView.image!, postID: key)
            
        //self.forGroup.posts.append(post) // Appending to a copy will do nothing
        
        // Search for this group's index
        let index = groups.index(where: { (item) -> Bool in
            item.groupName == forGroup.groupName
        })
        
        groups[index!].posts.append(post) // Add this post to the group
        
        // Start storage here
        
        self.performSegue(withIdentifier: "unwindToFeedFromConfirmUpload", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feedView = segue.destination as? FeedViewController {
            // Do we need to pass anything
        }
    }
}
