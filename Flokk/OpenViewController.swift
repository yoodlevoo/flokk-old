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
        
        tempReuploadProfilePhotos()
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
    
    private func tempReuploadProfilePhotos() {
        database.ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let values = snapshot.value as? [String : [String : Any]] {
                for (handle, _) in values {
                    storage.ref.child("users").child(handle).child("profilePhoto.jpg").data(withMaxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                        if error == nil {
                            let image = UIImage(data: data!)
                            
                            let compressed = image?.resized(withPercentage: 0.5)
                            
                            storage.ref.child("users").child(handle).child("profilePhotoIcon.jpg").put((compressed?.convertJpegToData())!, metadata: nil) { (metadata, error) in }
                            
                        } else {
                            print(error!)
                        }
                    })
                }
            }
        })
    }
}
