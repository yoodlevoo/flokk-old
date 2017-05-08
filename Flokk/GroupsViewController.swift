//
//  GroupsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 12/21/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit

class GroupsViewController: UIViewController {
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //var defaultGroups: [Group: UIImage] = [:] // Makes an empty dictionary
    var defaultGroups = [Group]() // An emptyarray of Groups - this is going to be a priorityqueue in a bit
    var groupQueue = PriorityQueue<Group>(sortedBy: <) // Hopefully this doesn't get reset each time
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    let transitionRight = SlideRightAnimator()
    let transitionUp = SlideUpAnimator()
    let transitionDown = SlideDownAnimator()
    let transitionRightNavigation = SlideRightNavigationAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available (iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        }else {
            tableView.addSubview(refreshControl)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if defaultGroups.count == 0 {

            mainUser.groups.removeAll()
            
            for groupHandle in findGroupHandlesNew() {
                let groupToLoad = loadGroup(groupHandle: groupHandle)
                
                defaultGroups.append(groupToLoad)
                mainUser.groups.append(groupToLoad)
            }
        }
    }
    
    // When the view is preparing to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If the tab bar was previously hidden(like from the feed view), unhide it
        self.tabBarController?.showTabBar()
        
        // Check if there is a group already selected
        let selectedIndex = self.tableView.indexPathForSelectedRow
        if selectedIndex != nil { // If there is then deselect it
            self.tableView.deselectRow(at: selectedIndex!, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func unwindToGroup(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromGroupToFeed" {
            if let feedNav = segue.destination as? FeedViewController {
                if let tag = (sender as? GroupTableViewCell)?.tag {
                    weak var group = defaultGroups[tag] // I want this to be weak to prevent memory leakage
                    
                    feedNav.group = group
                    feedNav.transitioningDelegate = transitionRight
                    self.tabBarController?.hideTabBar()
                    
                    //feedNav.passGroup()
                }
            }
        } else if segue.identifier == "segueFromGroupToCreateGroup" {
            if let createGroupView = segue.destination as? CreateGroupViewController {
                createGroupView.transitioningDelegate = transitionDown
            }
        }
    }
}

// Framework functions
extension GroupsViewController {
    // Load all about this user and what group(the handles) they're in
    // Use these handles to further load the groups from there separate files
    func findGroupHandles() -> [String] { //this will be removed later ons
        var groupHandles = [String]()
        
        let path = Bundle.main.url(forResource: mainUser.handle, withExtension: "json")
        do {
            let data = try Data(contentsOf: path!, options: .mappedIfSafe)
            
            let json = JSON(data: data)
            
            // Iterate through all of the groups and find the internal handles of the groups
            // So we know which ones to load
            for (_, group) in json["groups"] {
                groupHandles.append(group.string!)
            }
        }  catch let error as NSError {
            print("Error: \(error)")
        }
        
        return groupHandles
    }
    
    func findGroupHandlesNew() -> [String] {
        var groupHandles = [String]()
        
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let jsonURL = documentsURL?.appendingPathComponent(mainUser.handle + ".json")
        let jsonFile = URL(fileURLWithPath: (jsonURL?.absoluteString)!)
        
        do {
            let data = try Data(contentsOf: jsonFile, options: .mappedIfSafe)
            
            let json = JSON(data: data)
            
            // Iterate through all of the groups and to find the internal handles of the groups
            // So we know which ones to load
            for (_, group) in json["groups"] {
                groupHandles.append(group.string!)
            }
        }  catch let error as NSError {
            print("Error: \(error)")
        }
        
        return groupHandles
    }
    
    // Put this in FileUtils later
    func loadGroup(groupHandle: String) -> Group {
        // for groupHandle in handles {
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        // 'groupHandle' should already be a "friendly" group handle
        // b/c it is coming from the user's .json file
        let groupURL = documentsURL?.appendingPathComponent(groupHandle)
        let jsonURL = groupURL?.appendingPathComponent(groupHandle + ".json")
        let jsonFile = URL(fileURLWithPath: (jsonURL?.absoluteString)!)
        
        do {
            let data = try Data(contentsOf: jsonFile, options: .mappedIfSafe)
            
            let json = JSON(data: data)
            
            let creator = json["creator"].string
            let groupName = json["groupName"].string
            let totalPostsCount = json["postsCount"].int
            
            var users = [User]()
            for(_, subJSON) in json["users"] {
                if let userHandle = subJSON.string {
                    users.append(User(handle: userHandle, fullName:"filler"))
                }
            }
            
            let groupIconPhoto = FileUtils.loadGroupIcon(groupName: groupName!)
            
            let group = Group(groupName: groupName!, image: groupIconPhoto, users: users, creator: User(handle: creator!, fullName: "filler"))
            group.totalPostsCount = totalPostsCount!
            
            return group
        } catch let error as NSError {
            print(error.localizedDescription)
            return Group()
        }
        //}
    }
}

// Table View Functions
extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! GroupTableViewCell
        
        cell.groupTitleLabel?.text = defaultGroups[indexPath.row].groupName
        cell.groupImageView?.image = defaultGroups[indexPath.row].groupIcon
        cell.tag = indexPath.row //or do i do indexPath.item
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaultGroups.count //this number will be loaded in later on
    }
}

// Custom Table View Cell Class
class GroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    
}
