//
//  PersonalProfileCollectionViewPage1.swift
//  Flokk
//
//  Created by Gannon Prudomme on 7/16/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

// Your saved posts
class PersonalProfileSavedPageCollectionView: UICollectionViewController {
    var posts = [Post]()
    
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true // It might default to this
        
        let width = self.activityIndicator.frame.size.width
        let topY = self.activityIndicator.frame.minY
        
        self.activityIndicator.frame = CGRect(x: 337 / 2 - (width / 2), y: topY / 2 - (width / 2), width: width, height: width)
        
        self.collectionView?.addSubview(self.activityIndicator)
        //self.activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Get the relevant post data from each group?
        
        // Check to see if any posts need to be loaded - this might get inefficient
        for (groupID, postsData) in mainUser.savedPostsData { // Iterate through all of the groups
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
        
        //self.activityIndicator.stopAnimating()
        self.collectionView?.reloadData() // Reload the collection view every time
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! PersonalPostsCollectionViewCell
    
        let post = posts[indexPath.item]
        
        cell.postImageView.image = post.image
        
        return cell
    }
}
