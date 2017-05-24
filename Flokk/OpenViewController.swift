//
//  OpenViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/3/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class OpenViewController: UIViewController {
    @IBOutlet weak var flokkLogo: UIImageView!

    let transitionRight = SlideRightAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
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
