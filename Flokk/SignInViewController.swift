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
        let email = usernameEntry.text // Get the entered email
        let password = passwordEntry.text // Get the entered password
        
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
            if error == nil { // If there wasn't an error
                if let user = user { // Basically just removes the "optional" from user (so there's no need for doing "(user?.uid)!")
                    database.ref.child("uids").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        let handle = snapshot.value as! String // Get this user's handle from their UID
                        
                        database.ref.child("users").child(handle).observeSingleEvent(of: .value, with: { (snapshot) in
                            let userValues = snapshot.value as! NSDictionary
                            let fullName = userValues["fullName"] as! String
                            
                            if let groupsDict = userValues["groups"] as? [String: Bool] {// Bool is basically just a placeholder
                                let groupHandles = Array(groupsDict.keys)
                                
                                print(fullName)
                                
                                mainUser = User(handle: handle, fullName: fullName, groupHandles: groupHandles) // Set the main user
                                
                            } else { // Then the user is not in any groups
                                mainUser = User(handle: handle, fullName: fullName)
                            }
                            
                            
                            self.performSegue(withIdentifier: "segueFromSignInToGroups", sender: self) // Once we're done, segue to the next view
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
