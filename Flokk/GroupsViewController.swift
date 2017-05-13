//
//  GroupsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 12/21/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit
import Firebase

class GroupsViewController: UIViewController {
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //var defaultGroups: [Group: UIImage] = [:] // Makes an empty dictionary
    var defaultGroups = [Group]() // An emptyarray of Groups - this is going to be a priorityqueue in a bit
    var groupQueue = PriorityQueue<Group>(sortedBy: <) // Hopefully this doesn't get reset each time
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    let transitionDown = SlideDownAnimator()
    let transitionUp = SlideUpAnimator()
    
    // The handler for the auth state listener, to allow cancelling later.
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available (iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        }else {
            self.tableView.addSubview(refreshControl)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
    }
    
    // When the view is preparing to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Attach this to any view that requires information about this user
        handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
        })
        
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
        
        FIRAuth.auth()?.removeStateDidChangeListener(handle!)
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
                    weak var group = groups[tag] // I want this to be weak to prevent memory leakage
                    
                    feedNav.group = group
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
    // Put this in FileUtils later
    func loadGroup(groupHandle: String) -> Group {
        let groupRef = database.ref.child("groups").child(groupHandle)
        
        groupRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
        })
        
        return Group()
    }
}

// Table View Functions
extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! GroupTableViewCell
        
        cell.groupTitleLabel?.text = groups[indexPath.row].groupName
        cell.groupImageView?.image = groups[indexPath.row].groupIcon
        cell.tag = indexPath.row //or do i do indexPath.item
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count //this number will be loaded in later on
    }
}

// Custom Table View Cell Class
class GroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    
}
