//
//  AddCommentViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 2/11/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class AddCommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var postView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var post: Post!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        postView.image = post.image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! CommentsTableViewController
        
        let comment = post.comments[indexPath.row]
        cell.userPhotoView.image = comment.user.profilePhoto
        cell.contentTextView.text = comment.content
        
        cell.contentTextView.isUserInteractionEnabled = false
        cell.contentTextView.isEditable = false
        
        return cell
    }
    
    //the number of rows depends on how many comments there are
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
     */
}

class CommentsTableViewController: UITableViewCell {
    @IBOutlet weak var userPhotoView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
}
