//
//  CreateGroupViewController.swift
//  Resort
//
//  Created by Jared Heyen on 11/4/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addGroupPictureButton: UIButton!
    
    var searchedUsers = [User]() //ill do this search thing later
    var selectedUsers = [User]()
    
    private var groupName: String!
    private var groupPhoto: UIImage!
    
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hard code in the users just for testing
        searchedUsers.append(User(handle: "taviansims", fullName: "Tavian Sims"))
        searchedUsers.append(User(handle: "jaredheyen", fullName:"Jared Heyen"))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        groupNameTextField.delegate = self
        groupPhoto = UIImage(named: "gannonprudhommeProfilePhoto")
        
        imagePicker.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! CreateGroupUserCell
        
        let user = searchedUsers[indexPath.row]
        
        cell.profilePicture.image = user.profilePhoto
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.width / 2
        cell.profilePicture.clipsToBounds = true
        
        cell.fullNameLabel.text = user.fullName
        cell.usernameLabel.text = user.handle
        
        if selectedUsers.contains(user) {
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
        
        if selectedUsers.contains(user) {
            selectedUsers.remove(at: selectedUsers.index(of: user)!)
        } else {
            selectedUsers.append(user)
        }
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        groupName = textField.text
        
        textField.endEditing(true)
        
        return false
    }
    
    // MARK: Add Group Picture image picker functions
    
    @IBAction func addGroupPicture(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //imageView.contentMode = .scaleAspectFit
            addGroupPictureButton.setImage(pickedImage, for: UIControlState.normal)
        } else {
            print("Something went wrong")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueCreateGroup" {
            if groupName == nil || groupName == "" { //add more exceptions here, like just spaces and stuff
                return false
            }
        }
        
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCancelCreateGroup" {
            //shouldnt need to do anything here
        } else if segue.identifier == "segueCreateGroup" { //then create the group and save it as a JSON file
            var users = selectedUsers //the selected users + main user
            users.append(mainUser)
            
            var group = Group(groupName: groupName, image: groupPhoto, users: users, creator: mainUser)
            var json: JSON = group.convertToJSON()
            
            if let tabBar = segue.destination as? UITabBarController {
                if let groupsNav = tabBar.viewControllers![0] as? UINavigationController {
                    if let groupsView = groupsNav.viewControllers[0] as? GroupsViewController {
                        //groupsView.defaultGroups.append(group)
                        
                        FileUtils.saveGroupJSON(json: json, group: group)
                    }
                }
            }
        }
    }
}

class CreateGroupUserCell: UITableViewCell {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    var selectedToAdd: Bool!
}
