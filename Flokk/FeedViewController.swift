//
//  FeedViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/3/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var noPostsImageView: UIImageView!
    @IBOutlet weak var noPostsLabel: UILabel!
    
    var group: Group! // The group this feed is reading from
    var groupIndex: Int! // The index of this group in the global group variable
    
    static let initialPostCount = 10 // The initial amount of posts to load
    var loadedPosts = [Post]() // When there are a lot of posts, this will contain only the most 'x' recent posts
    
    let transitionDown = SlideDownAnimator()
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    var postCount = initialPostCount
    
    fileprivate var userProfilePhotos = [String : UIImage]()
    
    //fileprivate var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.refreshControl.addTarget(self, action: #selector(FeedViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        self.refreshControl.tintColor = TEAL_COLOR
        
        self.tableView.refreshControl = self.refreshControl
        
        //self.imagePicker.delegate = self
        
        self.loadedPosts = self.group.posts
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.edgesForExtendedLayout = .bottom
        
        // Set the navigation bar title to the group name
        self.navigationBar.title = group.groupName
        
        self.loadPosts() // Load the posts
        self.beginListeners() // Begin listening for changes
        
        // Check if there are no posts, so we know to show the "No Posts" Frowny Face
        if self.group.postsData.keys.count == 0 { // If there are no posts
            self.noPostsImageView.isHidden = false
            self.noPostsLabel.isHidden = false
            self.refreshControl.endRefreshing() // Don't refresh if there are no posts to load
        }
        
        if self.loadedPosts.count > 0 { // If there are already posts loading, don't refresh anymore
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData() // Reload data every time this view appears, in case we just uploaded a photowe
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToFeed(segue: UIStoryboardSegue) {
    }
    
    @IBAction func uploadPic(_ sender: AnyObject) {
        //imagePicker.allowsEditing = false
        //imagePicker.sourceType = .photoLibrary
        
        //present(imagePicker, animated: true, completion: nil)
    }
    
    // Called when the user pulls down on this table
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        
        // Have a little delay here
        refreshControl.endRefreshing()
    }
    
    // Load the posts from the database
    func loadPosts() {
        if self.group.posts.count < self.postCount { // If we need to load more posts
            self.refreshControl.beginRefreshing()
            
            let groupPostsRef = database.ref.child("groups").child(self.group.groupID).child("posts")
            groupPostsRef.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: { (snapshot) in
                if let values = snapshot.value as? [String : [String : Any]] {
                    if values.count == 0 {
                        self.refreshControl.endRefreshing()
                    }
                    
                    for (id, data) in values {
                        let matches = self.group.loadingPostIDs.filter{$0 == id} // Check if there is a loaded/loading post that matches this ID
                        if matches.count != 0 { // If this post has already been loaded
                            return // Then skip loading this post
                        } else { // This post hasn't been loaded yet, nor has started to load, begin to load it
                            groups[self.groupIndex].loadingPostIDs.append(id) // Add this post to the loading posts IDs array to global groups array
                            
                            // Load in the basic data for this post
                            let dataDict = data
                            let posterHandle = dataDict["poster"] as! String // Handle for who uploaded this post
                            let timestamp = NSDate(timeIntervalSinceReferenceDate: (dataDict["timestamp"] as! Double)) // When this post was uploaded
                            //print("timestamp \(timestamp)")
                            
                            // Load this user's profile photo if it hasn't been loaded already
                            if !self.userProfilePhotos.keys.contains(posterHandle) {
                                let profilePhotoRef = storage.ref.child("users").child(posterHandle).child("profilePhoto").child("\(posterHandle).jpg")
                                profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                                    if error == nil { // If there wasn't an error
                                        let profilePhoto = UIImage(data: data!) // Load the profile photo from the received data
                                        
                                        self.userProfilePhotos[posterHandle] = profilePhoto
                                    } else {
                                        print(error!)
                                    }
                                })
                            }
                            
                            // Load the post image
                            let postRef = storage.ref.child("groups").child(self.group.groupID).child("posts")
                            postRef.child("\(id)/post.jpg").data(withMaxSize: MAX_POST_SIZE, completion: { (data, error) in
                                if error == nil { // If there wasn't an error
                                    let postImage = UIImage(data: data!)
                                    
                                    // Generate the post
                                    let post = Post(posterHandle: posterHandle, image: postImage!, postID: id, timestamp: timestamp)
                                    
                                    // Store it in the various arrays
                                    self.group.posts.append(post)
                                    
                                    // Sort the group posts by the upload date, with the more recent posts first
                                    self.group.posts.sort(by: { $0.timestamp.timeIntervalSinceReferenceDate < $1.timestamp.timeIntervalSinceReferenceDate })
                                    
                                    self.loadedPosts = self.group.posts
                                    
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                        self.refreshControl.endRefreshing()
                                    }
                                } else { // If there was an error
                                    print(error!)
                                }
                            })
                        }
                    }
                }
            })
        } else { // If all of the posts are loaded
            // Load the poster profile photos
        }
    }
    
    // Begin listening for changes in this group
    // That being mainly post uploads, but also comments, group invites, group additions/accepts, someone changing the profile photo
    func beginListeners() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromFeedToComment" {
            if let commentView = segue.destination as? AddCommentViewController {
                if let tag = (sender as? FeedTableViewCell)?.tag {
                    let post = loadedPosts[tag]
                    
                    commentView.post = post
                    commentView.group = self.group
                }
            }
        } else if segue.identifier == "segueFromFeedToPhotoUploadPage" {
            if let photoUploadPageView = segue.destination as? PhotoUploadPageViewController {
                photoUploadPageView.groupToPass = group

            }
        } else if segue.identifier == "segueFromFeedToGroupSettings" {
            if let groupSettings = segue.destination as? GroupSettingsViewController {
                groupSettings.group = self.group
            }
        }
    }
}


// Table View Functions
extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    // Try to adjust the size of each cell according to the size of the picture
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! FeedTableViewCell
        
        let index = loadedPosts.count - 1 - indexPath.row
        cell.tag = index // Set the tag so prepare for segue can recognize which post was selected
        
        let post = loadedPosts[index]
        
        cell.setCustomImage(image: post.image)
        
        // Set the poster's profile photo & crop it to a circle
        cell.userImage.image = self.userProfilePhotos[post.posterHandle] ?? UIImage(named: "AddProfilePic")
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width / 2
        cell.userImage.clipsToBounds = true
        
        //print("\(cell.userImage.image?.size.width) \(cell.userImage.image?.size.height)")
        
        // Then adjust the size of the cell according to the photos - this is done in the FeedTableViewCell class
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedPosts.count
    }
    
    // Once the post is pressed, go to the comments
    // In the future this may change to a swipe on the post instead of a tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let index = loadedPosts.count - 1 - indexPath.row
        
        let post = loadedPosts[index] // Get the specific post referred to by the pressed cell
        
        // Then transition to the comment view through the comment's navigation controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commentNav:AddCommentNavigationViewController = storyboard.instantiateViewController(withIdentifier: "AddCommentNavigationController") as! AddCommentNavigationViewController
        
        commentNav.postToPass = post
        commentNav.passPost()
        
        self.present(commentNav, animated: true, completion: nil)
 
        */
    }
}

// Image Picker Functions
/*
extension FeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //let selectedImage: UIImage!
        
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let confirmUpload = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConfirmUploadViewController") as! ConfirmUploadViewController
            
            confirmUpload.image = selectedImage
            
            dismiss(animated: true, completion: nil)
            present(confirmUpload, animated: true, completion: nil)
            //self.parent?.parent?.present(confirmUpload, animated:true, completion: nil)
            //UIApplication.shared.keyWindow?.rootViewController?.present(confirmUpload, animated: true, completion: nil)
            
            if confirmUpload.imageView != nil {
                confirmUpload.imageView.image = selectedImage
            }
        } else {
            print("Something went wrong")
            
            dismiss(animated: false, completion: nil)
        }
    }
    
    // If the image picker was cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
} */

class FeedTableViewCell: UITableViewCell/*, UIScrollViewDelegate */ {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postedImage: UIImageView!
    
    // Internally calculate the constraint for this aspect fit
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
    
    // Sets the custom constraints for this
    func setCustomImage(image: UIImage) {
        let aspect = image.size.width / image.size.height
        let constraint = NSLayoutConstraint(item: postedImage, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: postedImage, attribute: NSLayoutAttribute.height, multiplier: aspect, constant: 0.0)
        constraint.priority = 999
        
        aspectConstraint = constraint
        
        postedImage.image = image
    }
}

// Tf is this used for
enum FeedTableViewCellSide {
    case FeedTableViewCellSideLeft
    case FeedtableViewCellSideRight
}
