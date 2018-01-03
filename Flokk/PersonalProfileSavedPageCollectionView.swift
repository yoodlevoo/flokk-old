//
//  PersonalProfileCollectionViewPage1.swift
//  Flokk
//
//  Created by Gannon Prudomme on 7/16/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

// Your saved posts
class PersonalProfileSavedPageView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var posts = [Post]()
    
    var activityIndicator = UIActivityIndicatorView()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noSavedPostsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.collectionView.clearsSelectionOnViewWillAppear = true // It might default to this
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let width = self.activityIndicator.frame.size.width
        let topY = self.activityIndicator.frame.minY
        
        self.activityIndicator.center = self.collectionView.center
        
        self.view?.addSubview(self.activityIndicator)
        self.view.bringSubview(toFront: self.activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Get the relevant post data from each group?
        
        let user = mainUser
        
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
                                
                                // Check if all of the saved posts are loaded
                                if self.posts.count == mainUser.savedPostsData.count {
                                    // If so, stop refreshing
                                    self.activityIndicator.stopAnimating()
                                }
                            }
                        } else {
                            print(error!)
                        }
                    })
                }
            }
        }
        
        if mainUser.savedPostsData.count == 0 {
            self.noSavedPostsLabel.isHidden = false
        } else {
            self.noSavedPostsLabel.isHidden = true
        }
        
        //self.activityIndicator.stopAnimating()
        self.collectionView?.reloadData() // Reload the collection view every time
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
