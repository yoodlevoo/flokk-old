//
//  GroupsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 12/21/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //should probably only use this cache for feed view
    
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //var mainUser: User! //the user who is currently running the app
    
    //var defaultGroups: [Group: UIImage] = [:] //makes an empty dictionary
    var defaultGroups = [Group]() //an emptyarray of Groups - this is going to be a priorityqueue in a bit
    var groupQueue = PriorityQueue<Group>(sortedBy: <) //hopefully this doesn't get reset each time
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    let transitionForward = SlideForwardAnimator(right: true)
    let transitionDown = SlideDownAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available (iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        }else {
            tableView.addSubview(refreshControl)
        }
        
        //print(defaultGroups.count) //at this point is this ever not at 0 or is a new array created each time
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //mainUser = User(handle: "gannonprudhomme", fullName: "Gannon Prudhome")
        
        //FileUtils.deleteUserJSON(user: mainUser)
        //FileUtils.deleteGroupJSON(groupName: "Bball")
        //FileUtils.deleteGroupJSON(groupName: "Basketball")
        
        
        //FileUtils.findAllFilesInDocuments()
        
        if defaultGroups.count == 0 {
            //print("Loading groups")
            
            mainUser.groups.removeAll()
            
            for groupHandle in findGroupHandlesNew() {
                let groupToLoad = loadGroup(groupHandle: groupHandle)
                
                //print(groupHandle)
                defaultGroups.append(groupToLoad)
                mainUser.groups.append(groupToLoad)
            }
            
           // print("\n")
        }
        
        /*
        if defaultGroups.count == 0 {
            print(findGroupHandlesNew())
            for groupHandle in findGroupHandlesNew() {
                if let group = GroupsViewController.groupCache.object(forKey: groupHandle as NSString) {
                    defaultGroups.append(group)
                } else {
                    let groupToLoad = loadGroup(groupHandle: groupHandle)
                    GroupsViewController.groupCache.setObject(groupToLoad, forKey: groupHandle as NSString)
                    defaultGroups.append(groupToLoad)
                }
            }
        } else {
            //commented this out cause i dont want to reload each time
            //defaultGroups.removeAll()
            //loadGroupsNew(handles: findGroupHandles())
        } */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //Load all about this user and what group(the handles) they're in
    //use these handles to further load the groups from there separate files
    func findGroupHandles() -> [String] { //this will be removed later ons
        var groupHandles = [String]()
        
        let path = Bundle.main.url(forResource: mainUser.handle, withExtension: "json")
        do {
            let data = try Data(contentsOf: path!, options: .mappedIfSafe)
            
            let json = JSON(data: data)
            
            //iterate through all of the groups and to find the internal handles of the groups
            //so we know which ones to load
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
            
            //iterate through all of the groups and to find the internal handles of the groups
            //so we know which ones to load
            for (_, group) in json["groups"] {
                groupHandles.append(group.string!)
            }
        }  catch let error as NSError {
            print("Error: \(error)")
        }
        
        return groupHandles
    }

    //put this in FileUtils later
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
                //let groupIconName = json["groupIcon"].string
                
                var users = [User]()
                for(_, subJSON) in json["users"] {
                    if let userHandle = subJSON.string {
                        users.append(User(handle: userHandle, fullName:"filler"))
                    }
                }
                
                let groupIconPhoto = FileUtils.loadGroupIcon(groupName: groupName!)
                
                let group = Group(groupName: groupName!, image: groupIconPhoto, users: users, creator: User(handle: creator!, fullName: "filler"))

                return group
            } catch let error as NSError {
                print(error.localizedDescription)
                return Group()
            }
        //}
    }
    
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
    
    @IBAction func unwindFromFeedToGroup(segue: UIStoryboardSegue) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromGroupToFeed" {
            if let feedNav = segue.destination as? FeedNavigationViewController {
                if let tag = (sender as? GroupTableViewCell)?.tag {
                    weak var group = defaultGroups[tag] // I want this to be weak to prevent memory leakage
                    
                    feedNav.groupToPass = group
                    feedNav.transitioningDelegate = transitionForward
                    
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

class GroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    
}
