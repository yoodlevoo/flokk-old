//
//  ConfirmUploadViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/1/17.
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
                var post = Post(poster: mainUser, image: image, postedGroup: forGroup, index: forGroup.posts.count)
                forGroup.posts.append(post)
                
                post.uploadPostToJSON()
                
                //FileUtils.saveImage(image: image, name: post.getUniqueName())
                
                feedNav.groupToPass = forGroup
            }
        }
    }
}
