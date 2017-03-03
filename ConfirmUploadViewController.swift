//
//  ConfirmUploadViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/1/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromConfirmedImageToFeed" {
            if let feedNav = segue.destination as? FeedNavigationViewController {
                //use the imageView because it might be changed asynchronously
                let post = Post(poster: mainUser, image: imageView.image!, postedGroup: forGroup, index: forGroup.posts.count)
                //forGroup.posts.append(post)
                
                post.uploadPostToJSONNew()
                
                FileUtils.savePostImage(post: post)
                
                feedNav.groupToPass = forGroup
            }
        } else if segue.identifier == "segueBackFromConfirmedImageToPhotoSelect" {
            if let photoUploadPageNav = segue.destination as? PhotoUploadPageNavigationViewController {
                photoUploadPageNav.groupToPass = forGroup
            }
        }
    }
}
