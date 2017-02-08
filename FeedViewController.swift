//
//  FeedViewController.swift
//  Resort
//
//  Created by Jared Heyen on 11/3/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var group: Group! //the group this feed is reading from
    
    var feedTestImages = [UIImage]() //for testing 
    var posts = [Post]() //when there are a lot of posts, this will contain only the most 'x' recent posts
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedTestImages.append(UIImage(named: "FPSF2016")!)
        
        //posts.append(Post(poster: <#T##User#>, image: <#T##UIImage#>)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! FeedTableViewCell
        
        print(group.groupName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 //this number will be loaded in later on
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
