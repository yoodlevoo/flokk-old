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
        
        defaultGroups.append(Group(text: "FPSF 2016", image: UIImage(named: "FPSF2016")!))
        defaultGroups.append(Group(text: "Christmas 2016", image: UIImage(named: "Christmas2016")!))
        defaultGroups.append(Group(text: "Ski Trip", image: UIImage(named: "SkiTrip")!))
        //defaultGroups.append(Group(text: "The Heyen Men", image: UIImage(named: "HeyenMen")!))
        defaultGroups.append(Group(text: "The Wedding", image: UIImage(named: "TheWedding")!))
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
        return 3 //this number will be loaded in later on
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = defaultGroups[indexPath.row]
        
        
    }
    
    @IBAction func createGroup(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class GroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    
}
