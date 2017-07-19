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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true // It might default to this
        
        // First, check if there are any saved posts in the first place
        
        posts.append(Post(posterHandle: "gannonprudhomme", image: UIImage(named: "BasketballFreethrow")!, postID: "nil"))
        
        // Load the posts from the savedPostsData
        for (groupID, postsData) in mainUser.savedPostsData { // Iterate through all of the groups
            for (postID, time) in postsData { // Iterate through all of the posts in the specific groups
                // Get the relevant post data from each group?
                
                // Get the image from storage
                let imageRef = storage.ref.child(groupID).child("posts").child(postID)
                imageRef.data(withMaxSize: MAX_POST_SIZE, completion: { (data, error) in
                    if error == nil {
                        let image = UIImage(data: data!)
                        
                        
                    } else {
                        print(error!)
                    }
                })
            }
        }
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
