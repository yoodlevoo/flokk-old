//
//  AddCommentNavigationViewController.swift
//  Flokk
//
//  Created by Taylor High School on 2/17/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class AddCommentNavigationViewController: UINavigationController {
    var postToPass: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let commentVC = self.viewControllers[0] as! AddCommentViewController
        commentVC.post = postToPass
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func passPost() {
        if let commentVC = self.viewControllers[0] as? AddCommentViewController {
            commentVC.post = postToPass
        }
    }
}
