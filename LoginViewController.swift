//
//  LoginViewController.swift
//  Resort
//
//  Created by Jared Heyen on 11/3/16.
//  Copyright © 2016 Heyen Enterprises. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var flokkImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //we need to determine what the username and password character limit is in the future
    //for now im setting both of them to be 10
    //also we need to determine what symbols can and cannot be used in them(ie. ./#$%^&*_!-@ )
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == usernameTextField) {
            let characterCountLimit: Int = 10
            
            //?? is used so if we cant get the length of the text field it is set to 0 instead
            let startingLength: Int = usernameTextField.text?.characters.count ?? 0
            
            
        } else if(textField == passwordTextField) {
            
        }
        
        
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
        
    }
    @IBAction func createAcctBttn(_ sender: Any) {
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
