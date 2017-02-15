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
    
    //var defaultGroups: [Group: UIImage] = [:] //makes an empty dictionary
    var defaultGroups = [Group]() //an emptyarray of Groups
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //let emptyUsers = [User]() //this won't be needed in the future, just so Group.init will work
        var fpsfUsers = [User]()
        fpsfUsers.append(User(usernameHandle: "gannonprudhomme", fullName: "Gannon Prudhomme"))
        fpsfUsers.append(User(usernameHandle: "jaredheyen", fullName: "Jared Heyen"))
        
        defaultGroups.append(Group(text: "FPSF 2016", image: UIImage(named: "FPSF2016")!, users: fpsfUsers))
        defaultGroups.append(Group(text: "Christmas 2016", image: UIImage(named: "Christmas2016")!, users: fpsfUsers))
        defaultGroups.append(Group(text: "Ski Trip", image: UIImage(named: "SkiTrip")!, users: fpsfUsers))
        defaultGroups.append(Group(text: "The Wedding", image: UIImage(named: "TheWedding")!, users: fpsfUsers))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! GroupTableViewCell
        
        cell.groupTitleLabel?.text = defaultGroups[indexPath.row].groupName
        cell.groupImageView?.image = defaultGroups[indexPath.row].groupIcon
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 //this number will be loaded in later on
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
