//
//  NewSignInViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/3/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {
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
        signIn()
    }
    
    @IBAction func unwindToSignIn(segue: UIStoryboardSegue) {
        
    }
    
    func signIn() {
        let email = usernameEntry.text // Get the entered email
        let password = passwordEntry.text //
        
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
            if let error = error {
                print("Sign in error: \(error)")
                print("with username: \(email!) and password \(password!)")
                
                return
            }
            
            print("signed in successfully")
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
            segue.destination.transitioningDelegate = transitionRight
            
        } else if let openView = segue.destination as? OpenViewController {
            segue.destination.transitioningDelegate = transitionRight
        }
    }
}
