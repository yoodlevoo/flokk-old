//
//  CommentViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 2/11/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {
    @IBOutlet weak var post: UIImageView!
    @IBOutlet weak var profileCommenterPic: UIImageView!
    @IBOutlet weak var comment: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
