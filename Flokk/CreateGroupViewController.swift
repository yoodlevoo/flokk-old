//
//  CreateGroupViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/4/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource/*, UICollectionViewDelegateFlowLayout*/ {
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addGroupPictureButton: UIButton!
    @IBOutlet weak var selectedUsersCollectionView: UICollectionView!
    
    var searchedUsers = [User]() //ill do this search thing later
    var selectedUsers = [User]()
    
    //private var groupName: String!
    //private var groupPhoto: UIImage!
    
    private let imagePicker = UIImagePickerController()
    
    var profilePicFromCrop: UIImage!
    
    let transitionUp = SlideUpAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hard code in the users just for testing
        searchedUsers.append(User(handle: "taviansims", fullName: "Tavian Sims"))
        searchedUsers.append(User(handle: "jaredheyen", fullName:"Jared Heyen"))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        groupNameTextField.delegate = self
        
        imagePicker.delegate = self
        
        selectedUsersCollectionView.delegate = self
        selectedUsersCollectionView.dataSource = self
        
        if profilePicFromCrop != nil {
            addGroupPictureButton.imageView?.image = profilePicFromCrop
            addGroupPictureButton.setImage(profilePicFromCrop, for: .normal)
        }
        
        //set the collection view so it scrolls sideways
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 3
        selectedUsersCollectionView.collectionViewLayout = layout
        
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: Searched Users table view functions
    
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
            self.selectedUsersCollectionView.reloadData()
        }
    }
    
    // MARK: Group Name text field functions
    
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
        //groupName = textField.text
        
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
        //let selectedImage: UIImage!
        
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dismiss(animated: false, completion: nil)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cropView: CropGroupPhotoViewController = storyboard.instantiateViewController(withIdentifier: "CropGroupPhotoViewController") as! CropGroupPhotoViewController
            
            cropView.image = selectedImage
            
            self.present(cropView, animated: true, completion: nil)
            
            //imageView.contentMode = .scaleAspectFit
            //print("picked image size \(pickedImage.size)")
            //addGroupPictureButton.setImage(pickedImage, for: UIControlState.normal)
        } else {
            print("Something went wrong")
            
            dismiss(animated: false, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Selected Users collection view functions
    
    //When the selected user's icon is pressed show options to remove the user
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! SelectedUsersCell
        
        cell.tag = indexPath.item
        
        cell.profilePicture.image = selectedUsers[indexPath.item].profilePhoto
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.width / 2
        cell.profilePicture.clipsToBounds = true
        
        return cell
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
    }
    */
    
    // MARK: Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueCreateGroup" {
            let groupName = groupNameTextField.text
            
            if groupName == nil || groupName == "" { //add more exceptions here, like just spaces and stuff
                return false
            }
        }
        
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCreateGroup" { //then create the group and save it as a JSON file
            var users = selectedUsers //the selected users + main user
            users.append(mainUser)
            
            let buttonImage = addGroupPictureButton.imageView?.image
            let groupName = groupNameTextField.text
            
            let group = Group(groupName: groupName!, image: buttonImage!, users: users, creator: mainUser)
            let json: JSON = group.convertToJSON()
            
            if let tabBar = segue.destination as? UITabBarController {
                if let groupsNav = tabBar.viewControllers![0] as? UINavigationController {
                    if let groupsView = groupsNav.viewControllers[0] as? GroupsViewController {
                        groupsView.defaultGroups.append(group)
                        
                        FileUtils.saveGroupJSON(json: json, group: group)
                        FileUtils.saveGroupIcon(group: group)
                        
                        mainUser.addNewGroup(group: group)
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

class SelectedUsersCell: UICollectionViewCell {
    @IBOutlet weak var profilePicture: UIImageView!

}
