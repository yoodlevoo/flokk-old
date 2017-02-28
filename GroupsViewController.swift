//
//  GroupsViewController.swift
//  Resort
//
//  Created by Jared Heyen on 12/21/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var mainUser: User! //the user who is currently running the app
    
    //var defaultGroups: [Group: UIImage] = [:] //makes an empty dictionary
    var defaultGroups = [Group]() //an emptyarray of Groups
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        mainUser = User(handle: "gannonprudhomme", fullName: "Gannon Prudhome")
        
        loadGroupsFromHandles(handles: findGroupHandles())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //Load all about this user and what group(the handles) they're in
    //use these handles to further load the groups from there separate files
    func findGroupHandles() -> [String] {
        //the handles of all of the groups this user is in
        //use these to load 
        var groupHandles = [String]()
        
        if let path = Bundle.main.url(forResource: mainUser.handle, withExtension:"json") {
            do {
                //load the file
                let data = try Data(contentsOf: path, options: .mappedIfSafe)
                do {
                    //load the contents of the file into a JSON object
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    //then parse the json
                    if let jsonData = json as? [String: Any] {
                        if let userJSON = jsonData["user"] as? [String: Any] {
                            if let groupsJSON = userJSON["groups"] as? [[String: Any]] {
                                for groupName in groupsJSON {
                                    if let groupHandle = groupName["groupHandle"] as? String {
                                        groupHandles.append(groupHandle)
                                    }
                                }
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Error: \(error)")
                }
            } catch let error as NSError {
                print("Error: \(error)")
            }
        }
        
        return groupHandles
    }
    
    func loadGroupsFromHandles(handles: [String]) {
        for handle in handles { //for ever different group handle given
            var group: Group
            
            var groupName: String!
            var groupIconName: String! //the groups "profile" photo's name
            var participants = [User]()
            var groupCreator: User!
            
            //find the file on disk
            if let path = Bundle.main.url(forResource: handle, withExtension:"json") {
                do {
                    //load the file
                    let data = try Data(contentsOf: path, options: .mappedIfSafe)
                    do {
                        //load the contents of the file into a JSON object
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        
                        if let jsonData = json as? [String: Any] {
                            if let groupJSON = jsonData["group"] as? [String: Any] {
                                if let creator = groupJSON["creator"] as? String {
                                    groupCreator = User(handle: creator, fullName: "filler")
                                }
                                
                                if let groupNameJSON = groupJSON["groupName"] as? String {
                                    groupName = groupNameJSON
                                }
                                
                                if let groupIconNameJSON = groupJSON["groupIcon"] as? String {
                                    groupIconName = groupIconNameJSON
                                }
                                
                                if let users = groupJSON["users"] as? [[String: Any]] {
                                    for user in users {
                                        if let handle = user["handle"] as? String {
                                            participants.append(User(handle: handle, fullName: "filler"))
                                        }
                                    }
                                }
                            }
                        }
                    } catch let error as NSError {
                        print("Error: \(error)")
                    }
                } catch let error as NSError {
                    print("Error: \(error)")
                }
            }
            
            group = Group(groupName: groupName, image: UIImage(named: groupIconName)!, users: participants, creator: groupCreator)
            defaultGroups.append(group)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! GroupTableViewCell
        
        cell.groupTitleLabel?.text = defaultGroups[indexPath.row].groupName
        cell.groupImageView?.image = defaultGroups[indexPath.row].groupIcon
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaultGroups.count //this number will be loaded in later on
    }
    
    //When one of the cells is selected
    //In the future, the feed should not be loaded each time
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = defaultGroups[indexPath.row] //get the specific group referred to by the pressed cell
        
        //then transition to the feedview controller through the Feed's navigation controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let feedNav:FeedNavigationViewController = storyboard.instantiateViewController(withIdentifier: "FeedViewNavController") as! FeedNavigationViewController
        
        feedNav.groupToPass = group
        feedNav.passGroup()
        
        self.present(feedNav, animated: true, completion: nil)
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
