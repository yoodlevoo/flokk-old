//
//  1stSignUpViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/3/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class FirstSignUpViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let transitionRight = SlideRightAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.becomeFirstResponder()
        
        self.passwordField.delegate = self
        self.emailField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func nextBttn(_ sender: Any) {
        
    }
    
    // Check if all the fields are filled out correctly
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueFromFirstToSecondSignUp" {
            let email = emailField.text!
            let password = passwordField.text!
            
            // Check if the email address is valid
            if email.characters.count > 0 { // If the user has even submitted anything
                if email.contains("@") && email.contains(".") { // If the email doesn't have an '@' or a '.', there's no way its valid
                    if password.characters.count > MIN_PASSWORD_LENGTH { // If this password is long enough
                        return true // Then everything has gone OK
                    } else { // If the password is not long enough
                        self.animateTextField(self.passwordField) // Shake the field
                        return false // Prevent the segue
                    }
                } else { // If the email isn't valid(has no '@' or '.')
                    self.animateTextField(self.emailField) // Shake the field
                    
                    // Check if the password is messed up too
                    if password.characters.count < MIN_PASSWORD_LENGTH {
                        self.animateTextField(self.passwordField)
                    }
                    
                    return false // Prevent the segue
                }
            } else { // The email address has not even been typed in, the length is 0
                self.animateTextField(self.emailField) // Shake the field
                
                if password.characters.count < MIN_PASSWORD_LENGTH {
                    self.animateTextField(self.passwordField)
                }
                
                return false // Prevent the segue
            }
            
            if password.characters.count < MIN_PASSWORD_LENGTH {
                self.animateTextField(self.passwordField)
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromFirstToSecondSignUp" {
            if let secondSignUpView = segue.destination as? SecondSignUpViewController {
                // Pass this sign up's data to the next
                secondSignUpView.email = emailField.text!
                secondSignUpView.password = passwordField.text!
            }
        }
    }
    
    // Animate the text field when data is entered wrong
    func animateTextField(_ textField: UITextField) {
        let duration = 0.03
        let delay = 0.08
        var currDelay = 0.0
        let dist = CGFloat(15)
        
        UIView.animate(withDuration: duration, delay: currDelay, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            UIViewAnimationOptions.curveEaseIn, animations: { textField.center.x += dist}, completion: nil)
        currDelay += delay
        
        UIView.animate(withDuration: duration, delay: currDelay, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            UIViewAnimationOptions.curveEaseIn, animations: { textField.center.x -= dist}, completion: nil)
        currDelay += delay
        
        UIView.animate(withDuration: duration, delay: currDelay, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            UIViewAnimationOptions.curveEaseIn, animations: { textField.center.x += dist}, completion: nil)
        currDelay += delay
        
        UIView.animate(withDuration: duration, delay: currDelay, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            UIViewAnimationOptions.curveEaseIn, animations: { textField.center.x -= dist}, completion: nil)
        currDelay += delay
        
        UIView.animate(withDuration: duration, delay: currDelay, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            UIViewAnimationOptions.curveEaseIn, animations: { textField.center.x += dist}, completion: nil)
        currDelay += delay
        
        UIView.animate(withDuration: duration, delay: currDelay, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
            UIViewAnimationOptions.curveEaseIn, animations: { textField.center.x -= dist}, completion: nil)
        currDelay += delay
        
    }
}

// Text Field Functions
extension FirstSignUpViewController: UITextFieldDelegate {
    // Prevent certain characters from being typed
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    // When the "next" button is pressed in the bottom right of the keyboard, go to the next field or the next page
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            let email = self.emailField.text!
            
            if email.characters.count > 0 {
                if email.contains("@") && email.contains(".") { // If the field has the basic criteria for being an email
                    // Then it's okay to go to the next field
                    self.passwordField.becomeFirstResponder() // Focus on the next field
                    return true
                } else {
                    self.animateTextField(self.emailField)
                    return false
                }
            } else {
                self.animateTextField(self.emailField)
                return false
            }
        } else if textField == self.passwordField {
            let password = self.passwordField.text!
            
            if password.characters.count >= MIN_PASSWORD_LENGTH {
                // Do Something
                return true
            } else {
                self.animateTextField(self.passwordField)
                return false
            }
        }
        
        return true
    }
}
