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
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var keyboardHeightLayoutConstraint : NSLayoutConstraint?
    
    var post: Post!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        
        postView.image = post.image
        
        //tells the notification to
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! CommentsTableViewController
        
        let comment = post.comments[indexPath.row]
        cell.userPhotoView.image = comment.user.profilePhoto
        cell.userPhotoView.layer.cornerRadius = cell.userPhotoView.frame.size.width / 2
        cell.userPhotoView.clipsToBounds = true
        
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
    //what should we do when a comment is selected?
    //have a way to reply to it or a way to go to the user's profile?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
     */

    //so the text field doesnt try to line break when we press enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //whenever the keyboard is activated, this notifies the textField to shift upward with the keyboard
    //i got this entire code somewhere from satack overflow
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    @IBAction func posterProfile(_ sender: Any) {
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feedNav = segue.destination as? FeedNavigationViewController {
            feedNav.groupToPass = post.postedGroup
        }
    }
}

class CommentsTableViewController: UITableViewCell {
    @IBOutlet weak var userPhotoView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
}
