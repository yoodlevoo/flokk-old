//
//  GroupsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 12/21/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import BRYXBanner

class GroupsViewController: UIViewController {
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGroupsView: UIImageView!
    @IBOutlet weak var noGroupsLabel: UILabel!
    
    //var defaultGroups: [Group: UIImage] = [:] // Makes an empty dictionary
    var defaultGroups = [Group]() // An emptyarray of Groups - this is going to be a priorityqueue in a bit
    
    var refreshControl = UIRefreshControl()
    
    let transitionDown = SlideDownAnimator()
    let transitionUp = SlideUpAnimator()
    
    fileprivate var groupDict = [String : String]() // [groupID : groupName] i really dont like doing this
    
    //var handle: FIRAuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.refreshControl.addTarget(self, action: #selector(GroupsViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        self.refreshControl.tintColor = TEAL_COLOR
        //print(self.refreshControl.frame)
        
        self.tableView.refreshControl = self.refreshControl

        self.refreshControl.beginRefreshing()
        
        // FIRST, check if the user is still signed in and if the mainUser data hasn't been loaded yet
        if FIRAuth.auth()?.currentUser != nil && mainUser == nil{
            self.loadInitialUserData() // Load the user data like you would if you were signing in
        } else if FIRAuth.auth()?.currentUser != nil && mainUser != nil { // If the user is logged in but the data has already been loaded(we came from sign up/sign in)
            // Since we already have all of the user data loaded, we can load in the groups
            self.loadGroups()
            
            // As well as beginning loading various small stuff and beginning listening for changes
            self.loadExtraUserData()
            self.beginListeners()
            
            // Check to see if we should show the "no group" icon
            self.checkGroupCount()
            
            self.sortGroups()
        } else { // If the user is not logged in at all
            // Segue to the Open/Initial/Title Screen View Controller
            let openNavView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OpenNavigationViewController") as! OpenNavigationViewController
            
            self.present(openNavView, animated: false, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make sure the user is loaded in first before checking the group count
        if mainUser != nil {
            // Check if the no group icon needs to be shown or not
            self.checkGroupCount()
            
            // Sort the groups, with the group with the most recent post first
            self.sortGroups()
        }
        
        // If the tab bar was previously hidden(like from the feed view), unhide it
        self.tabBarController?.showTabBar()
        self.navigationController?.showNavigationBar() // Unhide the nav bar
        
        // Check if there is a group already selected
        let selectedIndex = self.tableView.indexPathForSelectedRow
        if selectedIndex != nil { // If there is then deselect it
            self.tableView.deselectRow(at: selectedIndex!, animated: false)
        }
        
        self.tableView.reloadData() // Reload the data incase we added a new group??? should i do this in create group segue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //FIRAuth.auth()?.removeStateDidChangeListener(handle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func unwindToGroup(segue: UIStoryboardSegue) {
        
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    // Check how many groups there are to see if we need to show the No Group Icon
    func checkGroupCount() {
        // Check if the user has no groups to display
        if mainUser.groupIDs.count == 0 { // If the user has no groups. mainUser.groupIDs should always be loaded in
            self.noGroupsView.isHidden = false
            self.noGroupsLabel.isHidden = false
            
            // Make sure the activity indicator/refresh control isn't activated when there's no groups
            self.refreshControl.endRefreshing()
        } else {
            self.noGroupsView.isHidden = true
            self.noGroupsView.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromGroupToFeed" {
            if let feedView = segue.destination as? FeedViewController {
                if let tag = (sender as? GroupTableViewCell)?.tag {
                    weak var group = groups[tag] // I want this to be weak to prevent memory leakage
                    
                    feedView.group = group
                    self.tabBarController?.hideTabBar()
                }
            }
        } else if segue.identifier == "segueFromGroupToCreateGroup" {
            if let createGroupView = segue.destination as? CreateGroupViewController {
                createGroupView.transitioningDelegate = transitionDown
            }
        }
    }
}

// MARK: Framework functions
extension GroupsViewController {
    // Load the data that would otherwise be loaded in the Sign In View
    func loadInitialUserData() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        // Get the user data from their handle
        database.ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userValues = snapshot.value as? NSDictionary { // Attempt to load the user data into a dictionary
                // Load the various user data into objects
                let fullName = userValues["fullName"] as? String ?? "Error McDangit" // Load in the full name
                let handle = userValues["handle"] as? String ?? "Error" // Load in the handle
                let email = userValues["email"] as? String ?? "error@flokk.info" // Load in the email
                let groupsDict = userValues["groups"] as? [String : Bool] ?? [String : Bool]()
                let savedPosts = userValues["savedPosts"] as? [String: [String : Double]] ?? [String : [String : Double]]()
                let uploadedPosts = userValues["uploadedPosts"] as? [String: [String : Double]] ?? [String : [String : Double]]()
                
                let groupHandles = Array(groupsDict.keys)
                
                // Attempt to load the (full) profile photo first
                let profilePhotoRef = storage.ref.child("users").child(uid!).child("profilePhoto.jpg")
                profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                    if error == nil { // If there wasn't an error
                        let profilePhoto = UIImage(data: data!) // Load the image
                        
                        // Load in the user
                        mainUser = User(uid: uid!, handle: handle, fullName: fullName, profilePhoto: profilePhoto!, groupIDs: groupHandles)
                    } else { // If there was an error
                        // Load in the user
                        mainUser = User(uid: uid!, handle: handle, fullName: fullName, groupIDs: groupHandles)
                    }
                    
                    // Attemp to load in the friends
                    if let friendsDict = userValues["friends"] as? [String : Bool] { // If the user has any friends or not
                        mainUser.friendIDs = Array(friendsDict.keys) // Set the friends for this user
                    }
                    
                    mainUser.email = email
                    mainUser.uploadedPostsData = uploadedPosts
                    mainUser.savedPostsData = savedPosts
                    
                    // Once we have all of the user data loaded, we can continue loading the groups
                    self.loadGroups()
                    
                    // As well as beginning loading various small stuff and beginning listening for changes
                    self.loadExtraUserData()
                    self.beginListeners()
                    
                    self.checkGroupCount()
                })
            } else { // If we couldnt load the user data into a dict, there was an error
                //self.showAlert("There was an error logging in.")
            }
        })
    }
    
    // Load data about the groups
    func loadGroups() {
        // Attempt to load in all of the groups
        if groups.count < mainUser.groupIDs.count { // If we dont have all of the groups loaded in
            self.refreshControl.beginRefreshing()
            
            for groupID in mainUser.groupIDs {
                let matches = groups.filter{ $0.id == groupID } // Check if we already have a group with this ID, probably inefficient
                if matches.count != 0 { // If we already contain a group with this handle, skip it
                    continue
                } else { // Otherwise, load it from the Database
                    let groupRef = database.ref.child("groups").child(groupID)
                    
                    groupRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let values = snapshot.value as? NSDictionary {
                            // Load in all of the data for this group
                            let groupName = values["name"] as! String // Load in the group, will never be empty so no need for a default
                            let creatorHandle = values["creator"] as! String // No need to add a default, will never be empty
                            let memberHandles = values["members"] as! [String: Bool] // Again, no need to add a default, will never be empty
                            let postsData = values["posts"] as? [String: [String: Any?]] ?? [String: [String: String]]() // In case there are no posts in this group
                            
                            // Download the icon for this group
                            let iconRef = storage.ref.child("groups").child(groupID).child("iconCompressed.jpg")
                            iconRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { data, error in
                                if error == nil { // If there wasn't an error
                                    // Then the data is returned
                                    let groupIcon = UIImage(data: data!)
                                    
                                    // And we can finish loading the group
                                    let group = Group(id: groupID, name: groupName, icon: groupIcon!, memberIDs: Array(memberHandles.keys), postsData: postsData, creatorID: creatorHandle)
                                    
                                    var mostRecentPostStamp = 0.0
                                    
                                    // Check for the most recent post
                                    for (postID, data) in postsData {
                                        let timestamp = data["timestamp"] as! Double
                                        
                                        // If this post was "sooner"(greater than in nano/milliseconds), then this was more recent
                                        if timestamp > mostRecentPostStamp {
                                            mostRecentPostStamp = timestamp
                                        }
                                    }
                                    
                                    // Set the most recent post property for the group
                                    group.mostRecentPost = Date(timeIntervalSinceReferenceDate: mostRecentPostStamp)
                                    
                                    // Attemp to load in the user handles that have been invited to this group already
                                    if let invitedUsers = values["invitedUsers"] as? [String : Bool] { // Also checks if there are any invited users or not
                                        group.invitedUsers = Array(invitedUsers.keys)
                                    } else { // Then there are probably no invites that are still pending for this group
                                        group.invitedUsers = [String]()
                                    }
                                    
                                    groups.append(group) // Add this newly loaded group into the global groups variable
                                    
                                    self.groupDict[groupID] = groupName
                                    
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData() // Reload data every time a group is loaded
                                        self.refreshControl.endRefreshing()
                                    }
                                } else { // If there was an error
                                    print(error!)
                                    //continue // Skip this
                                }
                            })
                        }
                        
                    })
                }
            }
        }
    }
    
    // Load various data about the user immediately
    func loadExtraUserData() {
        // Load the user's friends whenever we can
        database.ref.child("users").child(mainUser.uid).child("friends").observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                let friendIDs = values.allKeys as! [String] // The tree is ordered as "userHandle": true, the value of this doesnt matter
                
                // Set the friend handles for the main user
                mainUser.friendIDs = friendIDs
            } else { // This user has no friends
                //mainUser.friends = [User]()
            }
        })
        
        // Load all of the outgoing friend requests
        database.ref.child("users").child(mainUser.uid).child("outgoingRequests").observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                let requestHandles = values.allKeys as! [String]
                
                mainUser.outgoingFriendRequests = requestHandles
            }
        })
        
        // Load all of the incoming friend requests
        database.ref.child("users").child(mainUser.uid).child("incomingRequests").observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                let requestHandles = values.allKeys as! [String]
                
                mainUser.incomingFriendRequests = requestHandles
            }
        })
        
        // Load all of the group invites
        database.ref.child("users").child(mainUser.uid).child("groupInvites").observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? NSDictionary {
                let groupInvites = values.allKeys as! [String]
                
                mainUser.groupInvites = groupInvites
            }
        })
    }
    
    // Begin listening for changes throughout the app - mainly notifications
    func beginListeners() {
        //print(NSDate.timeIntervalSinceReferenceDate)
        // Begin listening for notifications, sorted only from the ones we get after the app launched
        let notificationRef = database.ref.child("notifications").child(mainUser.uid)
        notificationRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: Double(NSDate.timeIntervalSinceReferenceDate)).observe(.childAdded, with: { (querySnapshot) in // Listen for additions
            // Depending on what kind of notification it is, handle it internally
            // So if its a friend invite notification, set it locally to the friend invite array for the main user
            // That way we don't have to listen to changes for the the friend invites part of the database
            
            // If this notification actually exists exists
            if querySnapshot.value != nil {
                // Load the rest of the notification - annoying that we have to do this
                notificationRef.child(querySnapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let notificationValues = snapshot.value as? NSDictionary {
                        let type = NotificationType(rawValue: notificationValues["type"] as! Int)!
                        let timestamp = Date(timeIntervalSinceReferenceDate: notificationValues["timestamp"] as! Double)
                        let senderID = notificationValues["sender"] as! String // There's always a sender
                        
                        // Initialize the user a little bit
                        let userRef = database.ref.child("users").child(senderID)
                        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            if let userValues = snapshot.value as? NSDictionary {
                                let fullName = userValues["fullName"] as! String
                                let handle = userValues["handle"] as! String
                                
                                // Load in the (compressed) profile photo
                                let profilePhotoRef = storage.ref.child("users").child(senderID).child("profilePhotoIcon.jpg")
                                profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (userData, error) in
                                    if error == nil { // If there wasn't an error
                                        let profilePhoto = UIImage(data: userData!)
                                        
                                        // Create the user
                                        let user = User(uid: senderID, handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                                        
                                        // If the notification involves a group, load it as well
                                        if type == .GROUP_INVITE || type == .GROUP_JOINED || type == .NEW_POST || type == .NEW_COMMENT {
                                            let groupID = notificationValues["groupID"] as! String
                                            
                                            // Load the group data - only the group name
                                            let groupRef = database.ref.child("groups").child(groupID)
                                            groupRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                                if let groupValues = snapshot.value as? NSDictionary {
                                                    let groupName = groupValues["name"] as! String
                                                    let invitedUsers = groupValues["invitedUsers"] as? [String : Bool] ?? [String : Bool]() // Load all of the user handles that have been invited
                                                    let memberHandles = Array((groupValues["members"] as! [String : Bool]).keys) // Load all of the handles of the current members, this will never be empty
                                                    
                                                    // Load the group photo
                                                    let groupIconRef = storage.ref.child("groups").child(groupID).child("iconCompressed.jpg")
                                                    groupIconRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (groupData, error) in
                                                        if error == nil { // If there wasn't an error
                                                            let groupIcon = UIImage(data: groupData!)
                                                            
                                                            let group = Group(id: groupID, name: groupName, icon: groupIcon!)
                                                            
                                                            group.invitedUsers = Array(invitedUsers.keys)
                                                            group.memberIDs = memberHandles
                                                            
                                                            // This needs to be handled differently eventually
                                                            let notification = Notification(type: type, sender: user, group: group)
                                                            
                                                            mainUser.notifications.append(notification)
                                                        } else { // If there was an error
                                                            print(error!)
                                                        }
                                                    })
                                                }
                                            })
                                        } else { // FRIEND_REQUESTED, FRIEND_REQUEST_ACCEPTED
                                            let notification = Notification(type: type, sender: user)
                                            
                                            mainUser.notifications.append(notification)
                                        }
                                    } else { // If there was an error
                                        // TODO: Handle it more in depth
                                        print(error!)
                                    }
                                })
                            }
                        })
                        
                        // Show the banner for each notification, load the user's handle first
                        database.ref.child("users").child(senderID).child("handle").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let senderHandle = snapshot.value as? String {
                                // Show the banner for each notification
                                switch type {
                                case .GROUP_INVITE: // If someone invites the mainUser to join a group
                                    // Load only the group name from the database first
                                    
                                    let groupID = notificationValues["groupID"] as! String // Get the Group UID
                                    
                                    // Load the group name
                                    let groupRef = database.ref.child("groups").child(groupID).child("name")
                                    groupRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let groupName = snapshot.value as? String {
                                            
                                            // Create and display the banner
                                            let banner = Banner(title: "Group Invite", subtitle: "@\(senderHandle) has invited you to join \(groupName)", image: UIImage(named: "GROUPS ICON"), backgroundColor: TEAL_COLOR, didTapBlock: { // If the user tapped on this banner
                                                
                                                let group = Group(id: groupID, name: groupName)
                                                
                                                // If this was selected, load the member handles before we segue
                                                let groupMemberHandlesRef = database.ref.child("groups").child(groupID).child("members")
                                                groupMemberHandlesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                                    if let memberHandles = snapshot.value as? [String : Bool] {
                                                        group.memberIDs = Array(memberHandles.keys) // Set the member handles in the group
                                                    }
                                                    
                                                    // Whether there are member handles or not, load and segue into the according Group Profile View
                                                    let groupProfileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupProfileViewController") as! GroupProfileViewController
                                                    groupProfileView.group = group
                                                    groupProfileView.groupID = groupID
                                                    
                                                    self.navigationController?.pushViewController(groupProfileView, animated: true)
                                                    //self.present(groupProfileView, animated: true, completion: nil) // Segue to the group profile
                                                })
                                            })
                                            
                                            banner.dismissesOnSwipe = true
                                            banner.show(duration: BANNER_DURATION)
                                        }
                                    })
                                    
                                    break
                                case .FRIEND_REQUESTED: // If someone requests to be the mainUser's friend
                                    mainUser.incomingFriendRequests.append(senderID)
                                    
                                    // No need to load anything extra, just create and show the banner
                                    let banner = Banner(title: "Friend Request", subtitle: "@\(senderHandle) requested to be your friend.", image: UIImage(named: "Friends Icon"), backgroundColor: TEAL_COLOR, didTapBlock: { // If this banner was tapped
                                        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                                        
                                        profileView.userID = senderID
                                        profileView.userHandle = senderHandle
                                        
                                        self.navigationController?.pushViewController(profileView, animated: true)
                                        //self.present(profileView, animated: true, completion: nil)
                                    })
                                    
                                    banner.dismissesOnSwipe = true
                                    banner.show(duration: BANNER_DURATION)
                                    
                                    break
                                case .FRIEND_REQUEST_ACCEPTED:
                                    mainUser.outgoingFriendRequests.remove(at: mainUser.outgoingFriendRequests.index(of: senderID)!) // Remove this from the local outgoing requests array
                                    mainUser.friendIDs.append(senderID) // Add this user to the local friend handles array
                                    
                                    // No needf to load anything, just create and show the banner
                                    let banner = Banner(title: "Friend Request Accepted", subtitle: "@\(senderHandle) accepted your friend request.", image: UIImage(named: "Friends Icon"), backgroundColor: TEAL_COLOR, didTapBlock: { // If this banner was tapped
                                        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                                        
                                        profileView.userID = senderID
                                        profileView.userHandle = senderHandle
                                        
                                        self.navigationController?.pushViewController(profileView, animated: true)
                                        //self.present(profileView, animated: true, completion: nil)
                                    })
                                    
                                    banner.dismissesOnSwipe = true
                                    banner.show(duration: BANNER_DURATION)
                                    
                                    break
                                default:
                                    let banner = Banner(title: "\(type)", subtitle: "Notification of type:\(type)", backgroundColor: TEAL_COLOR, didTapBlock: {})
                                    
                                    banner.dismissesOnSwipe = true
                                    banner.show(duration: BANNER_DURATION)
                                    
                                    break
                                }
                            }
                        })
                    }
                })
            }
        })
        
        // Begin listening for group/posts changes? - this should be encapsulated within the notifications listener, except for things that don't trigger a notification
        
        // Begin listening for post changes within groups
        // What should i do if the group isn't loaded yet
        for groupID in mainUser.groupIDs { // Create a listener for each group the user is in
            let groupRef = database.ref.child("groups").child(groupID).child("posts")
            // Only listen for post changes after the app launched, otherwise we'll get old posts
            groupRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: Double(NSDate.timeIntervalSinceReferenceDate)).observe(.childAdded, with: { (snapshot) in
                if let values = snapshot.value as? NSDictionary {
                    let postID = snapshot.key
                    
                    let posterID = values["poster"] as! String
                    let timestamp = Date(timeIntervalSinceReferenceDate: values["timestamp"] as! Double)
                    
                    // Add the post to the group's post data property
                    let matches = groups.filter({$0.id == groupID})
                    //if matches.count == 1 { // It should always equal 1
                    let group = matches[0] // Get the actual group
                        
                    var data = [String : Any]()
                    data["poster"] = posterID
                    data["timestamp"] = timestamp.timeIntervalSinceReferenceDate
                
                    // Add the post data to the group
                    group.postsData[postID] = data
                    
                    // Set the most recent post
                    group.mostRecentPost = timestamp
                    
                    if posterID != mainUser.uid { // Make sure we don't show a banner when the main user uploads a photo
                        // Load the handle of the poster
                        let posterRef = database.ref.child("users").child(posterID).child("handle")
                        posterRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            if let handle = snapshot.value as? String {
                                // Create a banner to notify the user
                                let groupName = self.groupDict[groupID]! // Load in the group ID
                                let banner = Banner(title: "Post Added", subtitle: "@\(handle) uploaded a post to \(groupName)", image: group.icon, backgroundColor: TEAL_COLOR, didTapBlock: { // When tapped
                                    // TODO: Go to the corresponding group
                                })
                                
                                banner.dismissesOnTap = true
                                banner.show(duration: BANNER_DURATION)
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        })
                    }
                    // No point in loading the notification here
                }
            })
        }
    }
    
    // Sort the group, with the group with the most recent post first
    func sortGroups() {
        groups.sort(by: {$0.mostRecentPost.timeIntervalSinceReferenceDate > $1.mostRecentPost.timeIntervalSinceReferenceDate})
    }
}

// MARK: Table View Functions
extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! GroupTableViewCell
        
        let group = groups[indexPath.row]
        
        cell.groupTitleLabel?.text = group.name
        
        // Set the group icon 
        cell.groupImageView?.image = group.icon
        cell.groupImageView?.layer.cornerRadius = cell.groupImageView.frame.size.width / 2
        cell.groupImageView.clipsToBounds = true
        
        cell.tag = indexPath.row //or do i do indexPath.item
        
        // Check what we should set for the timeOfLastPost label
        let calendar = Calendar.current
        let date = group.mostRecentPost
        // Check if the post was today
        if calendar.isDateInToday(date) {
            // Get the individual components from the most recent post
            var hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            
            // check if this was in the AM or PM
            var amPM = "AM"
            if hour > 12 {
                amPM = "PM"
                hour -= 12
            }
            
            cell.timeOfLastPostLabel.text = "\(hour):\(minutes) \(amPM)"
        } else if calendar.isDateInTomorrow(date) {
            cell.timeOfLastPostLabel.text = "Yesterday"
        } else if date.timeIntervalSinceReferenceDate == 0 {
            // If there are no posts, dont put anything there
            cell.timeOfLastPostLabel.text = "No posts."
        } else {
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let year = calendar.component(.year, from: date)
            
            cell.timeOfLastPostLabel.text = "\(month)/\(day)/\(year)"
        }
        
        
        self.refreshControl.endRefreshing()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count //this number will be loaded in later on
    }
}

// MARK: Custom Table View Cell Class
class GroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var timeOfLastPostLabel: UILabel!
    
}
