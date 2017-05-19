//
//  2ndSignUpViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/3/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SecondSignUpViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var usernameField: UITextField! // The handle
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var addProfilePhotoButton: UIButton! // Rename this
    
    private let imagePicker = UIImagePickerController()
    
    // Data passed in from the previous view
    var fullName: String!
    var email: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameField.becomeFirstResponder() // Set the usernameEntry to be selected by default
        
        self.imagePicker.delegate = self
    }
    
    @IBAction func addProfilePic(_ sender: Any) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary

        // Present the imagePicker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func backGesture(_ sender: Any) {
    }
    
    @IBAction func unwindToSecondSignUp(segue: UIStoryboardSegue) {
        
    }

    @IBAction func signUpPressed(_ sender: Any) {
        // Make sure all of the fields are filled in correctly
        
        // Create this user, these calls aren't asynchronous so no worries using it as a function - I think
        database.createNewUser(email: email, password: passwordField.text!, handle: usernameField.text!, fullName: fullName, profilePhoto: (addProfilePhotoButton.imageView?.image)!)
        
        // Upload this user to the database
        let userRef = database.ref.child("users").child(usernameField.text!)
        userRef.child("fullName").setValue(fullName)
        userRef.child("email").setValue(email)
        
        // After creating the user, load it into the mainUser directly,
        // instead of uploading it then downloading it again(b/c thats just stupid)
        mainUser = User(handle: usernameField.text!, fullName: fullName, profilePhoto: addProfilePhotoButton.imageView?.image)
        
        // Segue to the next view - doesn't really need to be segued programmaticaly though
        self.performSegue(withIdentifier: "segueFromSecondSignUpToConnectContacts", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromSecondSignUpToConnectContacts" {
            if let connectContactsView = segue.destination as? ConnectContactsViewController {
                // What do i need to pass to this?
            }
        }
    }
}

// Text Field Functions
extension SecondSignUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}

// Image Picker Functions
extension SecondSignUpViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //imageView.contentMode = .scaleAspectFit
            addProfilePhotoButton.setImage(pickedImage, for: UIControlState.normal)
        } else {
            print("Something went wrong")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
