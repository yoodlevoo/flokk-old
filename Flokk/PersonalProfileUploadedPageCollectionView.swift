//
//  PersonalProfileCollectionViewPage2.swift
//  Flokk
//
//  Created by Gannon Prudomme on 7/16/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

// Your uploaded posts
class PersonalProfileUploadedPageCollectionView: UICollectionViewController {
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true // It might default to this
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! PersonalPostsCollectionViewCell
        
        let post = posts[indexPath.item]
        
        cell.postImageView.image = post.image
        
        return cell
    }
}
