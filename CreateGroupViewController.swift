//
//  CreateGroupViewController.swift
//  Resort
//
//  Created by Jared Heyen on 11/4/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var searchedUsers = [User]() //ill do this search thing later
    var selectedUsers: [User : Bool] = [:]
    
    private var groupName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hard code in the users just for testing
        searchedUsers.append(User(handle: "gannonprudhomme", fullName: "Gannon Prudhomme"))
        searchedUsers.append(User(handle: "jaredheyen", fullName:"Jared Heyen"))
        
        selectedUsers[searchedUsers[0]] = false
        selectedUsers[searchedUsers[1]] = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        groupNameTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! CreateGroupUserCell
        
        let user = searchedUsers[indexPath.row]
        
        cell.profilePicture.image = user.profilePhoto
        
        cell.fullNameLabel.text = user.fullName
        cell.usernameLabel.text = user.handle
        
        if selectedUsers[user] == true {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //toggle it
        let user = searchedUsers[indexPath.row]
        
        selectedUsers[user] = !selectedUsers[user]!
        
        DispatchQueue.main.async{
            tableView.reloadData()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == groupNameTextField) {
            let characterCountLimit = 15
            
            //?? is used so if we cant get the length of the text field it is set to 0 instead
            let startingLength = groupNameTextField.text?.characters.count ?? 0
            let lengthToAdd = string.characters.count
            let lengthToReplace = range.length
            
            let newLength = startingLength + lengthToAdd - lengthToReplace
            
            return newLength <= characterCountLimit
        }
        
        return true
    }
    
    @IBAction func addGroupPicture(_ sender: Any) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCancelCreateGroup" {
            
        } else if segue.identifier == "segueCreateGroup" {
            
        }
    }
}

class CreateGroupUserCell: UITableViewCell {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    var selectedToAdd: Bool!
}
