//
//  FeedViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/3/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var scrollView: UIScrollView!
    
    static var postsCache = NSCache<NSString, Post>()
    
    var group: Group! //the group this feed is reading from
    
    static let initialPostCount = 10 //the initial amount of posts to load
    var loadedPosts = [Post]() //when there are a lot of posts, this will contain only the most 'x' recent posts
    
    let transitionBackward = SlideBackwardAnimator(right: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //dont load the posts if there are already posts stored
        if loadedPosts.count == 0 {
            // group.loadPosts(numPostsToLoad: FeedViewController.initialPostCount)
        }
        
        if loadedPosts.count == 0 {
            loadedPosts = group.loadPosts(numPostsToLoad: FeedViewController.initialPostCount)
            for post in loadedPosts {
                if let cachedObject = FeedViewController.postsCache.object(forKey: post.getUniqueName() as NSString) { //if this posts exists in the cache
                } else { //if it doesn't add it to the postsCache
                    //priint(post.getUniqueName())
                    //FeedViewController.postsCache.object(forKey: post.getUniqueName() as NSString)
                }
            }
        } else {
            //loadedPosts.removeAll()
            //loadedPosts = group.loadPostsNew(numPostsToLoad: FeedViewController.initialPostCount)
        }
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //try to adjust the size of each cell according to the size of the picture
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! FeedTableViewCell
        
        let index = loadedPosts.count - 1 - indexPath.row
        cell.tag = index //set the tag so prepare for segue can recognize which post was selected
        
        let user: User = loadedPosts[index].poster
        cell.userImage.image = user.profilePhoto
        cell.setCustomImage(image: loadedPosts[index].image)
        
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width / 2
        cell.userImage.clipsToBounds = true
        
        //print("\(cell.userImage.image?.size.width) \(cell.userImage.image?.size.height)")
        
        //then adjust the size of the cell according to the photos - this is done in the FeedTableViewCell class
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedPosts.count
    }
    
    //Once the post is pressed, go to the comments
    //in the future this may change to a swipe on the post instead of a tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = loadedPosts.count - 1 - indexPath.row
        
        let post = loadedPosts[index] //get the specific post referred to by the pressed cell
        
        //then transition to the comment view through the comment's navigation controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commentNav:AddCommentNavigationViewController = storyboard.instantiateViewController(withIdentifier: "AddCommentNavigationController") as! AddCommentNavigationViewController
        
        commentNav.postToPass = post
        commentNav.passPost()
        
        self.present(commentNav, animated: true, completion: nil)
    }
    
    //search through all of the saved posts
    //and load the ones with the key that start with this group's unique name
    private func searchedCachedPosts() -> [Post] {
        var groupName = group.groupName
        
        return [Post]()
    }
    
    @IBAction func uploadPic(_ sender: AnyObject) {
    }
    
    @IBAction func groupSettings(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromFeedToComment" {
            if let commentNav = segue.destination as? AddCommentNavigationViewController {
                if let tag = (sender as? FeedTableViewCell)?.tag {
                    let post = loadedPosts[tag]
                    
                    commentNav.postToPass = post
                }
            }
        } else if segue.identifier == "segueFromFeedToUploadImage" {
            if let photoUploadPageNav = segue.destination as? PhotoUploadPageNavigationViewController {
                photoUploadPageNav.groupToPass = group
                
                var postsJSONToPass: JSON = []
                
                for post in loadedPosts {
                    postsJSONToPass.appendIfArray(json: post.convertToJSON())
                }
                
                group.setPostJSON(json: postsJSONToPass)
            }
        } else if segue.identifier == "segueFromFeedToGroup" {
            if let tabBar = segue.destination as? UITabBarController {
                tabBar.transitioningDelegate = transitionBackward
                
                if let groupView = tabBar.viewControllers?[0] as? GroupsViewController {
                    
                }
            }
        }
    }
}

class FeedTableViewCell: UITableViewCell/*, UIScrollViewDelegate */ {
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
    
    //sets the custom constraints for this
    func setCustomImage(image: UIImage) {
        let aspect = image.size.width / image.size.height
        let constraint = NSLayoutConstraint(item: postedImage, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: postedImage, attribute: NSLayoutAttribute.height, multiplier: aspect, constant: 0.0)
        constraint.priority = 999
        
        aspectConstraint = constraint
        
        postedImage.image = image
    }
}

enum FeedTableViewCellSide {
    case FeedTableViewCellSideLeft
    case FeedtableViewCellSideRight
}
