//
//  ProfileSettingsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/3/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit
import FirebaseAuth

class EditProfileViewController: UIViewController {
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    
    private let imagePicker = UIImagePickerController()
    
    let transitionRight = SlideRightAnimator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        self.fullNameField.delegate = self
        self.emailField.delegate = self
        self.currentPasswordField.delegate = self
        self.newPasswordField.delegate = self
        
        // Set the existing properties
        self.fullNameField.text = mainUser.fullName
        self.emailField.text = mainUser.email
        
        // Set the profile photo and make it crop to a circle
        self.profilePictureButton.setImage(mainUser.profilePhoto, for: .normal)
        self.profilePictureButton.layer.cornerRadius = self.profilePictureButton.frame.size.width / 2
        self.profilePictureButton.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profilePicture(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveBttn(_ sender: AnyObject) {
        // Upload the changed data to the database
        let userRef = database.ref.child("users").child(mainUser.handle)
        
        // First, compare all of the data to eachother and see if anything has changed
        if self.fullNameField.text != mainUser.fullName {
            // Upload the changed full name
            userRef.child("fullName").setValue(self.fullNameField.text)
            
            mainUser.fullName = self.fullNameField.text!
        }
        
        // Check if the profile photo changed
        if !(self.profilePictureButton.imageView?.image?.isEqual(mainUser.profilePhoto))! { // If the images are not equal, then the user uploaded a different profile photo
            
            // Upload the changed profile photo
            let profilePhotoRef = storage.ref.child("users").child(mainUser.handle).child("icon.jpg")
            profilePhotoRef.put((self.profilePictureButton.imageView?.image?.convertJpegToData())!, metadata: nil) {(metadata, error) in
                if error != nil {
                    print(error!)
                }
            }
            
            mainUser.profilePhoto = (self.profilePictureButton.imageView?.image!)!
        }
        
        // Check for changes in password i guess
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToProfileSettings(segue: UIStoryboardSegue) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromProfileSettingsToInitial" { // Log out
            mainUser = nil // De init the main user
            groups.removeAll()
            storedUsers.removeAll() // Not used anyways, but clear it just in case
            //storage = nil
            //database = nil
            
            // Attempt to actually sign out from Firebase
            do {
                try! FIRAuth.auth()?.signOut()
            } catch let signOutError as Error {
                print(signOutError)
            }
        }
    }
}

// Text Field Functions
extension EditProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.fullNameField {
            
        } else if textField == self.emailField {
            
        } else if textField == self.currentPasswordField {
            
        } else if textField == self.newPasswordField {
            
        }
        
        return true
    }
}

// Image Picker Functions
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //imageView.contentMode = .scaleAspectFit
            profilePictureButton.setImage(pickedImage, for: UIControlState.normal)
        } else {
            print("Something went wrong")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
