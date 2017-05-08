//
//  OpenViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/3/17.
//  Copyright © 2017 Akaro. All rights reserved.
//

import UIKit

class OpenViewController: UIViewController {
    @IBOutlet weak var flokkLogo: UIImageView!

    let transitionRight = SlideRightAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Just for testing
        jaredUser.groups.append(friendGroup)
        jaredUser.groups.append(otherGroup)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signUpBttn(_ sender: Any) {
    }
    
    @IBAction func signInPageBttn(_ sender: Any) {
    }
    
    @IBAction func segueToInitialSignIn(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //it doesnt matter whether we segue to sign up or sign in
        //we will use the same transition
        
        segue.destination.transitioningDelegate = transitionRight
    }
}
