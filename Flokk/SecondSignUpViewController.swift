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
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var addProfilePhotoButton: UIButton! // Rename this
    
    private let imagePicker = UIImagePickerController()
    
    // Data passed in from the previous view
    var email: String!
    var password: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameField.becomeFirstResponder() // Set the usernameEntry to be selected by default
        
        self.imagePicker.delegate = self
        
        self.addProfilePhotoButton?.layer.cornerRadius = (self.addProfilePhotoButton?.frame.size.width)! / 2
        self.addProfilePhotoButton?.clipsToBounds = true
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
        
        let handle = usernameField.text!
        let fullName = fullNameField.text!
        let profilePhoto = addProfilePhotoButton.imageView?.image!
        
        // Create this user, these calls aren't asynchronous so no worries using it as a function - I think
        //database.createNewUser(email: email, password: passwordField.text!, handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil { // If there wasn't an error
                if let user = user { // Make sure we authenticate this new user without error - might be redundant
                    database.ref.child("uids").child(user.uid).setValue(handle) // Connect this user's UID with their handle, for logging in
                    
                    // While this(below) doesnt need to be synchronous necessarily, if there is an error in the creation,
                    // I don't want the rest of the user to be added to the database
                    
                    // Write this new user's data to the database
                    let userDataRef = database.ref.child("users").child(handle)
                    userDataRef.child("fullName").setValue(fullName)
                    userDataRef.child("email").setValue(self.email)
                    
                    // Attempt to upload this user's profilePhoto to the database
                    storage.ref.child("users").child(handle).child("profilePhoto").child("\(handle).jpg").put(profilePhoto!.convertJpegToData(), metadata: nil) { (metadata, error) in
                        if error != nil { // If there was an error
                            print(error!)
                        }
                    }
                    
                    // After creating the user, load it into the mainUser directly,
                    // instead of uploading it then downloading it again(b/c thats just stupid)
                    mainUser = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                    
                    // Initialize this as empty, as its not an empty array by default
                    mainUser.groupInvites = [String]()
                    mainUser.email = self.email
                    
                    // Segue to the next view, placed in the completion block so we don't segue when there was an error
                    self.performSegue(withIdentifier: "segueFromSecondSignUpToConnectContacts", sender: self)
                }
            } else {
                print(error!)
                
                if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                    case .errorCodeInvalidEmail: // If the email isn't valid
                        
                        
                        
                        break
                    case .errorCodeWeakPassword: // If the password isn't strong enough
                        
                        break
                    case .errorCodeAccountExistsWithDifferentCredential: // If this account already exists
                        
                        break
                    
                    case .errorCodeNetworkError: // If there was a network error. This should be checked like everywhere
                        
                        break
                    default: break
                    }
                }
            }
        })
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
