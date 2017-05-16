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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func uploadPressed(_ sender: Any) {
        let postsRef = database.ref.child("groups").child(forGroup.groupName).child("posts") // Database
        let imageRef = storage.ref.child("groups").child(forGroup.groupName).child("posts") // Storage
        let key = postsRef.childByAutoId().key // Generate random ID for this post
        
        self.image = imageView.image
        
        imageRef.child("\(key)/post.jpg").put(image.convertJpegToData(), metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            
            //let downloadURL = metadata.downloadURL()
        }
        
        postsRef.child("\(key)").child("poster").setValue(mainUser.handle)
        postsRef.child("\(key)").child("timestamp").setValue(12341234)
        
        let post = Post(poster: mainUser, image: self.imageView.image!)
            
        //self.forGroup.posts.append(post) // Appending to a copy will do nothing
        
        let index = groups.index(where: { (item) -> Bool in
            item.groupName = forGroup.groupName
        })
        
        // Start storage here
        
        self.performSegue(withIdentifier: "unwindToFeedFromConfirmUpload", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feedView = segue.destination as? FeedViewController {
            
        }
    }
}
