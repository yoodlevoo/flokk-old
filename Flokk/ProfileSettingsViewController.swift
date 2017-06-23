//
//  ProfileSettingsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/3/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileSettingsViewController: UIViewController {
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    
    //var mainUser: User!
    
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
        self.profilePictureButton.imageView?.image = mainUser.profilePhoto
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
extension ProfileSettingsViewController: UITextFieldDelegate {
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
extension ProfileSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
