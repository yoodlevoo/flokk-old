//
//  FeedViewController.swift
//  Resort
//
//  Created by Jared Heyen on 11/3/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var group: Group! //the group this feed is reading from
    
    var feedTestImages = [UIImage]() //for testing 
    var posts = [Post]() //when there are a lot of posts, this will contain only the most 'x' recent posts
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        feedTestImages.append(UIImage(named: "FPSF2016")!)
        
        loadPosts()
    }
    
    //load the posts in from the JSON file - this is about to be replaced by posts being loaded in from the groups variable
    func loadPosts() {
        let user = group.participants[0]
        posts.append(Post(poster: user, image: UIImage(named: "FPSF2016")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //try to adjust the size of each cell according to the size of the picture
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! FeedTableViewCell
        
        let user: User = posts[indexPath.row].poster
        cell.userImage.image = user.profilePhoto
        cell.postedImage.image = posts[indexPath.row].image
        
        //then adjust the size of the cell according to the photos
        
        //print(group.groupName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1 //this number will be loaded in later on
    }
    
    //if this works, transition to the comments view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row at")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        
        if row == 0 {
            let image: UIImage = posts[row].image
            return image.size.height
        }
        
        return 500 //some random number cause i dont really know what the default height is
    }
    
    @IBAction func uploadPic(_ sender: AnyObject) {
        
    }
    
    @IBAction func backPage(_ sender: AnyObject) {
        
    }
    
    @IBAction func groupSettings(_ sender: Any) {
        
    }
}

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var postedImage: UIImageView!
}
