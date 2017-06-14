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
    var createGroupViewReference: CreateGroupViewController! // What's this for?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.groupNameField.delegate = self
        
        self.imagePicker.delegate = self
        
        self.selectedUsersCollectionView.delegate = self
        self.selectedUsersCollectionView.dataSource = self
        
        // Tell the group picture button image to crop to a circle
        self.addGroupPictureButton.imageView?.layer.cornerRadius = self.addGroupPictureButton.frame.width / 2
        self.addGroupPictureButton.clipsToBounds = true
        
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
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.delegate = self
        self.searchController.view.backgroundColor = UIColor(colorLiteralRed: 23/255, green: 23/255, blue: 43/255, alpha: 1)
        
        self.definesPresentationContext = true
        
        // Load in the friends of this user
        for handle in mainUser.friendHandles {
            let userRef = database.ref.child("users").child(handle)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let values = snapshot.value as? NSDictionary {
                    let fullName = values["fullName"] as! String
                    
                    // Load the profile photo form Storage
                    let profilePhotoRef = storage.ref.child("users").child(handle).child("profilePhoto.jpg")
                    profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                        if error == nil { // If there wasn't an error
                            let profilePhoto = UIImage(data: data!)
                            
                            // Load the user
                            let user = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                            
                            // Add it to the users count
                            self.totalUsers.append(user)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } else { // If there was an error
                            print(error!)
                        }
                    })
                }
            })
        }
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
        //profilePicFromCrop = UIImage(named: "BasketballMob")
        
        // Check if all of the fields are filled out correctly first
        
        // Generate a reference to the user and a unique Identifier for this group
        let userRef = database.ref.child("users").child(mainUser.handle)
        let groupKey = userRef.child("groups").childByAutoId().key // Generate a unique identifier for this group
        userRef.child("groups").child(groupKey).setValue(true) // Add the group to the mainUser/creators list of groups
        
        let groupRef = database.ref.child("groups").child(groupKey)
        groupRef.child("creator").setValue(mainUser.handle) // Set group creator handle
        groupRef.child("name").setValue(groupName) // Set the groups name
        groupRef.child("creationDate").setValue(NSDate.timeIntervalSinceReferenceDate) // Set when this
        
        // Only the user will be a member for now
        let members: [String: Bool] = [mainUser.handle: true]
        groupRef.child("members").setValue(members)
        
        // Upload the groups profile icon to storage
        storage.ref.child("groups").child(groupKey).child("icon.jpg").put((self.addGroupPictureButton.imageView?.image?.convertJpegToData())!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // an error occured
                return
            }
        }
        
        var invitedMembers = [String : Bool]()
        
        // Invite the selected users here
        for user in self.selectedUsers {
            let handle = user.handle
            invitedMembers[handle] = true
            
            // Tell the groups database that this user has been invited
            groupRef.child("invitedUsers").child(handle).setValue(true)
            
            let userRef = database.ref.child("users").child(handle)
            userRef.child("groupInvites").child(groupKey).setValue(true) // Tell the database this user has been invited to the group, for verification purposes
            
            // Create a group invite notification for this user
            let notificationKey = database.ref.child("notifications").child(groupKey).childByAutoId().key
            let notificationRef = database.ref.child("notifications").child(groupKey).child(notificationKey) // Generate a new notification
            
            notificationRef.child("type").setValue(NotificationType.GROUP_INVITE.rawValue) // Set the notification's type
            notificationRef.child("sender").setValue(mainUser.handle) // Set who sent this invite
            notificationRef.child("groupID").setValue(groupKey) // Set which group this user has been invited to
            notificationRef.child("timestamp").setValue(NSDate.timeIntervalSinceReferenceDate) // Set when this notification was sent
        }
        
        // Actually create the group
        let group = Group(groupID: groupKey, groupName: groupName, image: (self.addGroupPictureButton.imageView?.image!)!, users: [mainUser], creator: mainUser)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! UserTableViewCell
        let user = totalUsers[indexPath.row]
        
        // Set the profilePhotoView picure and crop it to a circle
        cell.profilePhotoView.image = user.profilePhoto
        cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.width / 2
        cell.profilePhotoView.clipsToBounds = true
        
        cell.fullNameLabel.text = user.fullName
        cell.handleLabel.text = user.handle
        
        if selectedUsers.contains(user) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalUsers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //toggle it
        let user = totalUsers[indexPath.row]
        
        if self.selectedUsers.contains(user) { // If this user is already selected
            self.selectedUsers.remove(at: selectedUsers.index(of: user)!) // Remove it
            
        } else { // If this user hasn't been selected
            self.selectedUsers.append(user) // Select it
        }
        
        // This is already on the main thread, no need to call it to the main thread explicitly
        //DispatchQueue.main.async{
            tableView.reloadData()
            self.selectedUsersCollectionView.reloadData()
        //}
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
        textField.endEditing(true)
        
        return false
    }
}

// Image Picker Controller Functions
extension CreateGroupViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //let selectedImage: UIImage!
        
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profilePicFromCrop = selectedImage
            self.addGroupPictureButton.imageView?.contentMode = .scaleAspectFill
            self.addGroupPictureButton.setImage(selectedImage, for: .normal)
            
            
            dismiss(animated: false, completion: nil)
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

class SelectedUsersCell: UICollectionViewCell {
    @IBOutlet weak var profilePicture: UIImageView!

}
