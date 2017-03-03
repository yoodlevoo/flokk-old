//
//  GroupsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 12/21/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //var cache: Cache
    
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //var mainUser: User! //the user who is currently running the app
    
    //var defaultGroups: [Group: UIImage] = [:] //makes an empty dictionary
    var defaultGroups = [Group]() //an emptyarray of Groups
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
                
        //mainUser = User(handle: "gannonprudhomme", fullName: "Gannon Prudhome")
        
        //FileUtils.deleteUserJSON(user: mainUser)
        
        if defaultGroups.count == 0 {
            print(findGroupHandlesNew())
            loadGroupsNew(handles: findGroupHandlesNew())
        } else {
            //commented this out cause i dont want to reload each time
            //defaultGroups.removeAll()
            //loadGroupsNew(handles: findGroupHandles())
        }
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
    func loadGroupsNew(handles: [String]) {
        for groupHandle in handles {
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
                let groupIconName = json["groupIcon"].string
                
                var users = [User]()
                for(_, subJSON) in json["users"] {
                    if let userHandle = subJSON.string {
                        users.append(User(handle: userHandle, fullName:"filler"))
                    }
                }
                
                var groupIconPhoto = FileUtils.loadGroupIcon(groupName: groupName!)
                
                var group = Group(groupName: groupName!, image: groupIconPhoto, users: users, creator: User(handle: creator!, fullName: "filler"))
                
                defaultGroups.append(group)
                mainUser.groups.append(group) //this won't be located here in the future
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
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
    
    //When one of the cells is selected
    //In the future, the feed should not be loaded each time
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let group = defaultGroups[indexPath.row] //get the specific group referred to by the pressed cell
        
        
        //then transition to the feedview controller through the Feed's navigation controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let feedNav:FeedNavigationViewController = storyboard.instantiateViewController(withIdentifier: "FeedViewNavController") as! FeedNavigationViewController
        
        feedNav.groupToPass = group
        feedNav.passGroup()
        
        self.present(feedNav, animated: true, completion: nil) */
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feedNav = segue.destination as? FeedNavigationViewController {
            if let tag = (sender as? GroupTableViewCell)?.tag {
                let group = defaultGroups[tag]
                
                feedNav.groupToPass = group
                //feedNav.passGroup()
            }
        } else if let feedView = segue.destination as? FeedViewController {
            if let tag = (sender as? GroupTableViewCell)?.tag {
                let group = defaultGroups[tag]
                
                feedView.group = group
            }
        }
    }
    
    /*
    @IBAction func createGroup(_ sender: Any) {
    }
     */
}

class GroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    
}
