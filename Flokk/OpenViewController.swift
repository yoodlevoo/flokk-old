//
//  OpenViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/3/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class OpenViewController: UIViewController {
    @IBOutlet weak var flokkLogo: UIImageView!

    let transitionForward = SlideForwardAnimator(right: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        segue.destination.transitioningDelegate = transitionForward
    }
}
