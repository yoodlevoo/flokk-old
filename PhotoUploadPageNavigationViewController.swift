//
//  PhotoUploadPageNavigationViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/1/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class PhotoUploadPageNavigationViewController: UINavigationController {
    var groupToPass: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let photoUploadPage = viewControllers[0] as! PhotoUploadPageViewController
        photoUploadPage.groupToPass = groupToPass
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
