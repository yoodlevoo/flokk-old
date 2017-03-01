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
    
    //using SwiftyJSON
    func loadPosts() {
        //load the file
        let path = Bundle.main.url(forResource: group.getUniqueName(), withExtension: "json")
        do {
            //load the contents of the file
            let data = try Data(contentsOf: path!, options: .mappedIfSafe)
            
            //parse the JSON
            let json = JSON(data: data)
            
            for (key, post) in json["group"]["posts"] {
                let userHandle = post["handle"].string
                let imageName = post["imageName"].string
                
                self.posts.append(Post(poster: group.findUserWithHandle(handle: userHandle!), image: UIImage(named: imageName!)!, postedGroup: group))
            }
            
        } catch let error as NSError {
            print("Error: \(error)")
        }
        //let json = JSON(data: data)
        //let handle = json["group"]
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
        
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width / 2
        cell.userImage.clipsToBounds = true
        
        //then adjust the size of the cell according to the photos - this is done in the FeedTableViewCell class
        
        //print(group.groupName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count //this number will be loaded in later on
    }
    
    //Once the post is pressed, go to the comments
    //in the future this may change to a swipe on the post instead of a tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row] //get the specific post referred to by the pressed cell
        
        //then transition to the comment view through the comment's navigation controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commentNav:AddCommentNavigationViewController = storyboard.instantiateViewController(withIdentifier: "AddCommentNavigationController") as! AddCommentNavigationViewController
        
        commentNav.postToPass = post
        commentNav.passPost()
        
        self.present(commentNav, animated: true, completion: nil)
    }
    
    @IBAction func uploadPic(_ sender: AnyObject) {
        
    }
    
    //manually segue back to the tab bar controller
    @IBAction func backPage(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        
        self.present(tabBarController, animated: true, completion: nil)
    }
    
    @IBAction func groupSettings(_ sender: Any) {
        
    }
}

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
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
