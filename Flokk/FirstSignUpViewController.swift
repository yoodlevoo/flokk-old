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
    
    let transitionForward = SlideForwardAnimator(right: true)
    let transitionBackward = SlideBackwardAnimator(right: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameEntry.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func nextBttn(_ sender: Any) {
    }
    @IBAction func backBttn(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromFirstToSecondSignUp" {
            segue.destination.transitioningDelegate = transitionForward
        } else if segue.identifier == "segueFromSecondSignUpToInitial" {
            segue.destination.transitioningDelegate = transitionBackward
        }
    }
}
