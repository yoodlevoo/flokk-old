//
//  1stSignUpViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/3/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class FirstSignUpViewController: UIViewController {
    @IBOutlet weak var nameEntry: UITextField!
    @IBOutlet weak var emailEntry: UITextField!
    
    let transitionRight = SlideRightAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameEntry.becomeFirstResponder()
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromFirstToSecondSignUp" {
            segue.destination.transitioningDelegate = transitionRight
        }
    }
}
