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
    
    var posts = [Post]() //when there are a lot of posts, this will contain only the most 'x' recent posts
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadPosts()
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    //load the posts in from the JSON file - this is about to be replaced by posts being loaded in from the groups variable
    func loadPosts() {
        //all just for testing
        let userGannon = group.participants[0]
        posts.append(Post(poster: userGannon, image: UIImage(named: "FPSF2016")!))
        
        let userJared = group.participants[1]
        posts.append(Post(poster: userJared, image: UIImage(named: "TheWedding")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //try to adjust the size of each cell according to the size of the picture
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! FeedTableViewCell
        
        let user: User = posts[indexPath.row].poster
        cell.userImage.image = user.profilePhoto
        cell.setCustomImage(image: posts[indexPath.row].image)
        
        //then adjust the size of the cell according to the photos
        
        //print(group.groupName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count //this number will be loaded in later on
    }
    
    //Once the post is pressed, go to the comments
    //in the future this may change to a swipe on the post instead of a tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func uploadPic(_ sender: AnyObject) {
        
    }
    
    @IBAction func backPage(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let groupNav = storyboard.instantiateViewController(withIdentifier: "GroupsNavController")
        
        self.present(groupNav, animated: true, completion: nil)
    }
    
    @IBAction func groupSettings(_ sender: Any) {
        
    }
}

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var postedImage: UIImageView!
    
    //internally calculate the constraint for this aspect fit
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                postedImage.removeConstraint(oldValue!)
            }
            
            if aspectConstraint != nil {
                postedImage.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    func setCustomImage(image: UIImage) {
        let aspect = image.size.width / image.size.height
        let constraint = NSLayoutConstraint(item: postedImage, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: postedImage, attribute: NSLayoutAttribute.height, multiplier: aspect, constant: 0.0)
        constraint.priority = 999
        
        aspectConstraint = constraint
        
        postedImage.image = image
    }
}
