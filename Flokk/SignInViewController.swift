//
//  NewSignInViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/3/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

let ALERT_DISAPPEAR_DELAY = 4.0

class SignInViewController: UIViewController {
    @IBOutlet weak var usernameEntry: UITextField! // This is actually the email, not the username/handle
    @IBOutlet weak var passwordEntry: UITextField!
    
    let transitionRight = SlideRightAnimator()
    
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
   
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
        
        let email = self.usernameEntry.text!
        let password = self.passwordEntry.text!
        
        self.signIn() // Sign in automatically, just for testing
        
        // Check the sign in criteria before signing in
        if email.characters.count > 0 { // If the user has entered anything in the text field
            if email.contains("@") && email.contains(".") { // Check if the email has the baseline criteria
                if password.characters.count > MIN_PASSWORD_LENGTH {
                    // If the baseline criteria is ok, then attempt to sign in
                    //self.signIn()
                } else {
                    self.animateTextField(self.passwordEntry)
                }
            } else {
                self.animateTextField(self.usernameEntry)
            }
        } else {
            self.animateTextField(self.usernameEntry)
        }
    }
    
    func signIn() {
        var email = usernameEntry.text // Get the entered email
        var password = passwordEntry.text // Get the entered password
        
        if email == "gannon" {
            email = "gannonprudhomme@gmail.com"
            password = "gannon123"
        } else if email == "jared" {
            email = "jaredheyen123@gmail.com"
            password = "jared123"
        } else if email == "madi" {
            email = "gannon@flokk.info"
            password = "madi123"
        } else if email == "alex" {
            email = "cheeseman123432@yahoo.com"
            password = "alex123"
        } else if email == "noble" {
            email = "n1ghtk1ng@live.com"
            password = "noble123"
        }
        
        self.showActivityIndicator("Attempting to sign in")
        
        // Authenticate and sign the user in - this can be simplified a lot by adding defaultsd
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
            if error == nil { // If there wasn't an error
                if let user = user { // Basically just removes the "optional" from user (so there's no need for doing "(user?.uid)!")
                    self.removeActivityIndicator()
                    self.showActivityIndicator("Success! Loading data...")
                    
                    database.ref.child("uids").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in // Check the UID tree and get the user's handle
                        let handle = snapshot.value as! String // Get this user's handle from their UID
                        
                        // Get the user data from their handle
                        database.ref.child("users").child(handle).observeSingleEvent(of: .value, with: { (snapshot) in
                            let userValues = snapshot.value as! NSDictionary
                            let fullName = userValues["fullName"] as! String
                            let groupsDict = userValues["groups"] as? [String : Bool] ?? [String : Bool]()
                            let savedPosts = userValues["savedPosts"] as? [String: [String : Double]] ?? [String : [String : Double]]()
                            let uploadedPosts = userValues["uploadedPosts"] as? [String: [String : Double]] ?? [String : [String : Double]]()
                            
                            let groupHandles = Array(groupsDict.keys)
                            
                            let profilePhotoRef = storage.ref.child("users").child(handle).child("profilePhoto.jpg")
                            profilePhotoRef.data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                                if error == nil { // If there wasn't an error
                                    let profilePhoto = UIImage(data: data!) // Load the image
                                    
                                    // Load in the user
                                    mainUser = User(handle: handle, fullName: fullName, profilePhoto: profilePhoto!, groupIDs: groupHandles)
                                } else { // If there was an error
                                    // Load in the user
                                    mainUser = User(handle: handle, fullName: fullName, groupIDs: groupHandles)
                                }
                                
                                // Attemp to load in the friends
                                if let friendsDict = userValues["friends"] as? [String : Bool] { // If the user has any friends or not
                                    mainUser.friendHandles = Array(friendsDict.keys) // Set the friends for this user
                                }
                                
                                mainUser.email = email
                                
                                // Whether there was an error in loading the profilePhoto or not, the mainUser will still exist so we can continue
                                self.performSegue(withIdentifier: "segueFromSignInToGroups", sender: self) // Once we're done, segue to the next view
                            })
                        })
                    })
                }
            } else { // If there was an error, handle it
                print(error!)
                
                self.removeActivityIndicator() // Remove the activity indicator alert when there was an error
                
                if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                    case .errorCodeUserNotFound:
                        self.showAlert("Invalid Email")
                        
                        // Wait for "ALERT_DISAPPEAR_DELAY" amount of seconds, then make the alert disappear
                        UIView.animate(withDuration: ALERT_DISAPPEAR_DELAY, animations: {
                            
                        }, completion: { (completed) in
                            UIView.animate(withDuration: 2.0, animations: {
                                self.effectView.alpha = 0
                            }, completion: { (completed) in
                                self.removeActivityIndicator()
                            })
                        })
                        
                        break
                    case .errorCodeInvalidCredential:
                        print("\n\n invalid credentials \n\n")
                        
                        break
                    case .errorCodeInvalidEmail: // If the user entered an invalid email
                        self.showAlert("Invalid email!")
                        
                        // Wait for "ALERT_DISAPPEAR_DELAY" amount of seconds, then make the alert disappear
                        UIView.animate(withDuration: ALERT_DISAPPEAR_DELAY, animations: {
                        
                        }, completion: { (completed) in
                            UIView.animate(withDuration: 2.0, animations: {
                                self.effectView.alpha = 0
                            }, completion: { (completed) in
                                self.removeActivityIndicator()
                            })
                        })
                        
                        break
                    case .errorCodeWrongPassword: // If the user entered an invalid password
                        self.showAlert("Incorrect password!")
                        
                        // Wait for "ALERT_DISAPPEAR_DELAY" amount of seconds, then make the alert disappear
                        UIView.animate(withDuration: ALERT_DISAPPEAR_DELAY, animations: {
                        }, completion: { (completed) in
                            UIView.animate(withDuration: 2.0, animations: {
                                self.effectView.alpha = 0
                            }, completion: { (completed) in
                                self.removeActivityIndicator()
                            })
                        })
                        
                        
                        break
                    case .errorCodeNetworkError: // If there was a network error
                        self.showAlert("Network error!")
                        
                        // Wait for "ALERT_DISAPPEAR_DELAY" amount of seconds, then make the alert disappear
                        UIView.animate(withDuration: ALERT_DISAPPEAR_DELAY, animations: {
                        }, completion: { (completed) in
                            UIView.animate(withDuration: 2.0, animations: {
                                self.effectView.alpha = 0
                            }, completion: { (completed) in
                                self.removeActivityIndicator()
                            })
                        })
                        
                        break
                    default: break
                    }
                }
            }
        })
    }
    
    // Show an alert with an activity indicator
    func showActivityIndicator(_ title: String) {
        self.strLabel.removeFromSuperview()
        self.activityIndicator.removeFromSuperview()
        self.effectView.removeFromSuperview()
        self.effectView.alpha = 1 // Just in case it was transparent
        
        self.strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        self.strLabel.text = title
        self.strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        self.strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        self.strLabel.frame.size.width = (self.strLabel.attributedText?.width(withConstrainedHeight: 46))!
        
        self.effectView.frame = CGRect(x: self.view.frame.midX - self.strLabel.frame.width/2 - 23, y: self.view.frame.height / 3, width: 30 + 46 + self.strLabel.frame.size.width, height: 46)
        self.effectView.layer.cornerRadius = 15
        self.effectView.layer.masksToBounds = true
        
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        self.activityIndicator.startAnimating()
        
        self.effectView.addSubview(activityIndicator)
        self.effectView.addSubview(strLabel)
        self.view.addSubview(effectView)
    }
    
    // Show an alert without an activity indicator
    func showAlert(_ title: String) {
        // Basically the same function as above, without the activity indicator portion
        self.strLabel.removeFromSuperview()
        self.effectView.removeFromSuperview()
        self.effectView.alpha = 1
        
        self.strLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 160, height: 46))
        self.strLabel.text = title
        self.strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        self.strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        self.strLabel.frame.size.width = (self.strLabel.attributedText?.width(withConstrainedHeight: 46))!
        
        self.effectView.frame = CGRect(x: self.view.frame.midX - self.strLabel.frame.width/2, y: self.view.frame.height / 3, width: 20 + self.strLabel.frame.size.width, height: 46)
        self.effectView.layer.cornerRadius = 15
        self.effectView.layer.masksToBounds = true
        
        self.effectView.addSubview(strLabel)
        self.view.addSubview(effectView)
    }
    
    // Remove either type of alert
    func removeActivityIndicator() {
        self.strLabel.removeFromSuperview()
        self.activityIndicator.removeFromSuperview()
        self.effectView.removeFromSuperview()
    }
    
    // Show a shake animation when the text field is filled out incorrectly
    func animateTextField(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            UIViewAnimationOptions.curveEaseIn, animations: { textField.center.x += 10}, completion: nil)
        
        UIView.animate(withDuration: 0.1, delay: 0.075, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            UIViewAnimationOptions.curveEaseIn, animations: { textField.center.x -= 20}, completion: nil)
        
        UIView.animate(withDuration: 0.1, delay: 0.15, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            UIViewAnimationOptions.curveEaseIn, animations: { textField.center.x += 10}, completion: nil)
        
        UIView.animate(withDuration: 0.1, delay: 0.225, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            UIViewAnimationOptions.curveEaseIn, animations: { textField.center.x -= 20}, completion: nil)
        
        UIView.animate(withDuration: 0.1, delay: 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            UIViewAnimationOptions.curveEaseIn, animations: { textField.center.x += 20}, completion: nil)
    }
    
    func animateButton() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromSignInToGroups" {
            //segue.destination.transitioningDelegate = transitionRight
            
        } else if let openView = segue.destination as? OpenViewController {
            //segue.destination.transitioningDelegate = transitionRight
        }
    }
    
    @IBAction func unwindToSignIn(segue: UIStoryboardSegue) {
        
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
