//
//  NewSignInViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/3/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class NewSignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameEntry: UITextField!
    @IBOutlet weak var passwordEntry: UITextField!
    let myPassword = "1"
   
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameEntry.becomeFirstResponder()

        passwordEntry.delegate = self
        
        
        
// Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func forgotPassword(_ sender: Any) {
    }
    @IBAction func signInBttn(_ sender: Any) {
        
        if passwordEntry.text == myPassword {print("Welcome")
        } else {
            
            UIView.animate(withDuration: 0.1, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
                
                UIViewAnimationOptions.curveEaseIn, animations: { self.passwordEntry.center.x += 10}, completion: nil)
            
            UIView.animate(withDuration: 0.1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
                
                UIViewAnimationOptions.curveEaseIn, animations: { self.passwordEntry.center.x -= 20}, completion: nil)
            
            UIView.animate(withDuration: 0.1, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 0, options:
                
                UIViewAnimationOptions.curveEaseIn, animations: { self.passwordEntry.center.x += 10}, completion: nil)
            
        }
        
    }
    
    @IBAction func backBttn(_ sender: Any) {
    }
    
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
