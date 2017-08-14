//
//  PersonalProfileCollectionViewPage2.swift
//  Flokk
//
//  Created by Gannon Prudomme on 7/16/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

// Your uploaded posts - basically the exact same thing as the saved page view
class PersonalProfileUploadedPageView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var posts = [Post]()
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noUploadedPostsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        //self.clearsSelectionOnViewWillAppear = true // It might default to this
        
        self.collectionView?.addSubview(self.activityIndicator)
        //self.activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let user = mainUser
        
        // Check to see if any posts need to be loaded
        for (groupID, postsData) in mainUser.uploadedPostsData { // Iterate through all of the groups
            for (postID, time) in postsData { // Iterate through all of the posts in the specific groups
                if !posts.contains(where: {$0.id == postID }) { // If this post is not already loaded, THEN we can load it
                    // Get the relevant post data from each group?
                    
                    // Get the image from storage
                    let imageRef = storage.ref.child("groups").child(groupID).child("posts").child(postID).child("postCompressed.jpg")
                    imageRef.data(withMaxSize: MAX_POST_SIZE, completion: { (data, error) in
                        if error == nil {
                            let image = UIImage(data: data!)
                            
                            let post = Post(posterHandle: "someone", image: image!, postID: postID)
                            post.timestamp = Date(timeIntervalSinceReferenceDate: time)
                            
                            self.posts.append(post)
                            
                            // Every time a post is loaded, reload
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        } else {
                            print(error!)
                        }
                    })
                }
            }
        }
        
        if mainUser.uploadedPostsData.count == 0 {
            self.noUploadedPostsLabel.isHidden = false
        } else {
            self.noUploadedPostsLabel.isHidden = true
        }
        
        self.collectionView?.reloadData()
      //  self.activityIndicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! PersonalPostsCollectionViewCell
        
        let post = posts[indexPath.item]
        
        cell.postImageView.image = post.image
        
        return cell
    }
}
