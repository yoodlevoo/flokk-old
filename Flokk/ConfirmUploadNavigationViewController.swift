//
//  ConfirmUploadNavigationViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/1/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class ConfirmUploadNavigationViewController: UINavigationController {
    
    var imageToPass: UIImage!
    
    var groupToPass: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let confirmUploadView = viewControllers[0] as! ConfirmUploadViewController
        confirmUploadView.image = imageToPass
        confirmUploadView.group = groupToPass
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
