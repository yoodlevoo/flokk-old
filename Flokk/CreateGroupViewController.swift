//
//  CreateGroupViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/4/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addGroupPictureButton: UIButton!
    @IBOutlet weak var selectedUsersCollectionView: UICollectionView!
    
    var totalUsers = [User]()
    var filteredUsers = [User]()
    var selectedUsers = [User]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate let imagePicker = UIImagePickerController()
    
    var profilePicFromCrop: UIImage! // The profile photo retrieved from the crop

    let transitionUp = SlideUpAnimator()
    
    var createGroupViewReference: CreateGroupViewController! // What's this for
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hard code in the users just for testing
        //totalUsers.append(tavianUser)
        //totalUsers.append(jaredUser)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.groupNameField.delegate = self
        
        self.imagePicker.delegate = self
        
        self.selectedUsersCollectionView.delegate = self
        self.selectedUsersCollectionView.dataSource = self
        
        if profilePicFromCrop != nil {
            self.addGroupPictureButton.imageView?.image = profilePicFromCrop
            self.addGroupPictureButton.setImage(profilePicFromCrop, for: .normal)
        }
        
        // Set the collection view so it scrolls sideways
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 3
        selectedUsersCollectionView.collectionViewLayout = layout
        
        self.hideKeyboardWhenTappedAround()
        
        // Search bar
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.hideNavigationBar() // Hide the nav bar when this view appears
        self.tabBarController?.hideTabBar() // Hide the tab bar when this view appears
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // When the user tries to create the group
    @IBAction func createButtonPressed(_ sender: Any) {
        let groupName = groupNameField.text!
        profilePicFromCrop = UIImage(named: "BasketballMob")
        
        // Check if all of the fields are filled out correctly first
        
        let groupRef = database.ref.child("groups").child(groupName)
        groupRef.child("creator").setValue(mainUser.handle)
        
        // Just the user will be a member for now
        let members: [String: Bool] = [mainUser.handle: true]
        groupRef.child("members").setValue(members)
        
        // Upload the groups profile icon to storage
        storage.ref.child("groups").child(groupName).child("icon/\(groupName).jpg").put(profilePicFromCrop.convertJpegToData(), metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // an error occured
                
                return
            }
            
            //let downloadURl = metadata.
        }
        
        // Invite the selected users here
        
        // Add the group to the mainUser/creators list of groups
        database.ref.child("users").child(mainUser.handle).child("groups").child(groupName).setValue(true)
        
        // Actually create the group
        let group = Group(groupName: groupName, image: UIImage(named: "BasketballMob")!, users: [mainUser], creator: mainUser)
        groups.append(group) // Add this group to the global groups
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Navigation
    
    // Called whenever the user cancels the crop - not used currently
    @IBAction func unwindToCreateGroupCancelled(segue: UIStoryboardSegue) {
        
    }
    
    // Called whenever the user chooses the crop
    @IBAction func unwindToCreateGroupChoosen(segue: UIStoryboardSegue) {
        if let cropGroupPhotoView = segue.source as? CropGroupPhotoViewController {
            
            self.profilePicFromCrop = cropGroupPhotoView.getCroppedImage(image: (cropGroupPhotoView.imageView?.image)!)
        }
    }
    
    // Check to see if its okay to try to create this group - like if all of the fields are not filled out
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueCreateGroup" {
            let groupName = groupNameField.text
            
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
            //users.append(mainUser)
            
            let buttonImage = addGroupPictureButton.imageView?.image
            let groupName = groupNameField.text
            
            //let group = Group(groupName: groupName!, image: buttonImage!, users: users, creator: mainUser)
            //let json: JSON = group.convertToJSON()
            
            if let tabBar = segue.destination as? UITabBarController {
                if let groupsNav = tabBar.viewControllers![0] as? UINavigationController {
                    if let groupsView = groupsNav.viewControllers[0] as? GroupsViewController {
                        //groupsView.defaultGroups.append(group)
                        
                        //FileUtils.saveGroupJSON(json: json, group: group)
                        //FileUtils.saveGroupIcon(group: group)
                        
                        //mainUser.addNewGroup(group: group)
                    }
                }
            }
        }
    }
}

// Table View Functions
extension CreateGroupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! CreateGroupUserCell
        
        let user = selectedUsers[indexPath.row]
        
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
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //toggle it
        let user = selectedUsers[indexPath.row]
        
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
}

// Collection View Functions
extension CreateGroupViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
}

// Search Bar Functions
extension CreateGroupViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    // Filter the users by the searchText
    func filterContentForSearchText(searchText: String, scope: String = " All") {
        filteredUsers = totalUsers.filter({(user : User) -> Bool in
            return user.fullName.contains(searchText.lowercased())
        })
        
        self.tableView.reloadData()
    }
}

// Text Field Functions
extension CreateGroupViewController: UITextFieldDelegate {
    // Check if we should allow the user to change the characters, to prevent unwanted characters or to restrict length
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == groupNameField) {
            let characterCountLimit = 15
            
            //?? is used so if we cant get the length of the text field it is set to 0 instead
            let startingLength = groupNameField.text?.characters.count ?? 0
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
}

// Image Picker Controller Functions
extension CreateGroupViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //let selectedImage: UIImage!
        
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dismiss(animated: false, completion: nil)
            
            self.profilePicFromCrop = selectedImage
            /*
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cropView: CropGroupPhotoViewController = storyboard.instantiateViewController(withIdentifier: "CropGroupPhotoViewController") as! CropGroupPhotoViewController
            
            cropView.image = selectedImage
            
            // Pass the image picker to the cropView so we can unwind back to it
            
            self.present(cropView, animated: true, completion: nil)
            */
            
            //imageView.contentMode = .scaleAspectFit
            //print("picked image size \(pickedImage.size)")
            //addGroupPictureButton.setImage(pickedImage, for: UIControlState.normal)
        } else {
            print("Something went wrong")
            
            dismiss(animated: false, completion: nil)
        }
    }
    
    // If the image picker was cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // When the upload photo button is pressed
    @IBAction func addGroupPicture(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        //createGroupViewReference = self // Create a reference of this
        
        present(imagePicker, animated: true, completion: nil)
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
