//
//  1stSignUpViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/3/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class FirstSignUpViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    let transitionRight = SlideRightAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.becomeFirstResponder()
        
        self.nameField.delegate = self
        self.emailField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func nextBttn(_ sender: Any) {
    }
    @IBAction func backBttn(_ sender: Any) {
    }
    
    @IBAction func unwindtoFirstSignUp(segue: UIStoryboardSegue) {
        
    }
    
    // Check if all the fields are filled out correctly
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromFirstToSecondSignUp" {
            if let secondSignUpView = segue.destination as? SecondSignUpViewController {
                // Pass this sign up's data to the next
                secondSignUpView.email = emailField.text!
                secondSignUpView.fullName = nameField.text!
            }
        }
    }
}

extension FirstSignUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
