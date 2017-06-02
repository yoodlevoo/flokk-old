//
//  NewSignInViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/3/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    @IBOutlet weak var usernameEntry: UITextField!
    @IBOutlet weak var passwordEntry: UITextField!
    
    let transitionRight = SlideRightAnimator()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameEntry.becomeFirstResponder()

        passwordEntry.delegate = self
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
    }
    
    @IBAction func signInBttn(_ sender: Any) {
        // Make sure the fields are filled in correctly before trying to sign in
        
        signIn()
    }
    
    @IBAction func unwindToSignIn(segue: UIStoryboardSegue) {
        
    }
    
    func signIn() {
        var email = usernameEntry.text // Get the entered email
        var password = passwordEntry.text // Get the entered password
        
        if email == "" {
            //email = "gannonprudhomme@gmail.com"
            //password = "gannon123"
            email = "cheeseman123432@yahoo.com"
            password = "alex123"
        }
        
        // Authenticate and sign the user in
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
            if error == nil { // If there wasn't an error
                if let user = user { // Basically just removes the "optional" from user (so there's no need for doing "(user?.uid)!")
                    database.ref.child("uids").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in // Check the UID tree and get the user's handle
                        let handle = snapshot.value as! String // Get this user's handle from their UID
                        
                        // Get the user data from their handle
                        database.ref.child("users").child(handle).observeSingleEvent(of: .value, with: { (snapshot) in
                            let userValues = snapshot.value as! NSDictionary
                            let fullName = userValues["fullName"] as! String
                            
                            if let groupsDict = userValues["groups"] as? [String: Bool] {// Bool is basically just a placeholder
                                let groupHandles = Array(groupsDict.keys)
                                
                                print(fullName)
                                
                                let profilePhotoRef = storage.ref.child("users").child(handle).child("profilePhoto").child("\(handle).jpg")
                                profilePhotoRef.data(withMaxSize: 1 * 2048 * 2048, completion: { (data, error) in
                                    if error == nil { // If there wasn't an error
                                        let profilePhoto = UIImage(data: data!) // Load the image
                                        
                                        // Load in the user
                                        mainUser = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!, groupHandles: groupHandles)
                                    } else { // If there was an error
                                        // Load in the user
                                        mainUser = User(handle: handle, fullName: fullName, groupHandles: groupHandles)
                                    }
                                    
                                    // Attemp to load in the friends
                                    if let friendsDict = userValues["friends"] as? [String : Bool] { // If the user has any friends or not
                                        mainUser.friendHandles = Array(friendsDict.keys) // Set the friends for this user
                                    }
                                    
                                    // Whether there was an error in loading the profilePhoto or not, the mainUser will still exist so we can continue
                                    self.performSegue(withIdentifier: "segueFromSignInToGroups", sender: self) // Once we're done, segue to the next view
                                })
                                
                            } else { // Then the user is not in any groups
                                mainUser = User(handle: handle, fullName: fullName)
                                
                                let profilePhotoRef = storage.ref.child("users").child(handle).child("profilePhoto").child("\(handle).jpg")
                                profilePhotoRef.data(withMaxSize: 1 * 2048 * 2048, completion: { (data, error) in
                                    if error == nil { // If there wasn't an error
                                        let profilePhoto = UIImage(data: data!)
                                        
                                        // Load in the user
                                        mainUser = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!)
                                    } else { // If there was an error
                                        // Load in the user with the minimum criteria
                                        mainUser = User(handle: handle, fullName: fullName)
                                    }
                                    
                                    // Attemp to load in the friends
                                    if let friendsDict = userValues["friends"] as? [String : Bool] { // If the user has any friends or not
                                        mainUser.friendHandles = Array(friendsDict.keys) // Set the friends for this user
                                    }
                                    
                                    // Whether there was an error in loading the profilePhoto or not, the mainUser will still exist so we can continue
                                    self.performSegue(withIdentifier: "segueFromSignInToGroups", sender: self) // Once we're done, segue to the next view
                                })
                            }
                        })
                    })
                }
            } else { // If there was an error
                print(error!)
            }
        })
    }
    
    func animateButton() {
        UIView.animate(withDuration: 0.05, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            
            UIViewAnimationOptions.curveEaseIn, animations: { self.passwordEntry.center.x += 10}, completion: nil)
        
        UIView.animate(withDuration: 0.05, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            
            UIViewAnimationOptions.curveEaseIn, animations: { self.passwordEntry.center.x -= 20}, completion: nil)
        
        UIView.animate(withDuration: 0.05, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            
            UIViewAnimationOptions.curveEaseIn, animations: { self.passwordEntry.center.x += 10}, completion: nil)
        
        UIView.animate(withDuration: 0.05, delay: 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            
            UIViewAnimationOptions.curveEaseIn, animations: { self.passwordEntry.center.x -= 20}, completion: nil)
        
        UIView.animate(withDuration: 0.05, delay: 0.4, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            
            UIViewAnimationOptions.curveEaseIn, animations: { self.passwordEntry.center.x += 10}, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromSignInToGroups" {
            //segue.destination.transitioningDelegate = transitionRight
            
        } else if let openView = segue.destination as? OpenViewController {
            //segue.destination.transitioningDelegate = transitionRight
        }
    }
}

// Text Field functions
extension SignInViewController: UITextFieldDelegate {
    // Check if we should allow the user to continue editing
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == usernameEntry {
            
        } else if textField == passwordEntry {
            
        }
        
        return true
    }
}
