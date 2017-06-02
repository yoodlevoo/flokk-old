//
//  GroupProfileViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/3/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit

class GroupProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    
    var group: Group!
    
    var oldContentOffset = CGPoint.zero // The previous frame's offset
    var headerConstraintRange: Range<CGFloat>! // The range that determines the min/max of the tableView's expansion/contraction
    var headerViewCriteria = CGFloat(0) // Doesn't actually affect the header view, but used for the scroll view calculations
    
    var invitedReceived = false // If the main user has been invited to this group, by default is false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Create the range for when the tableView should start/stop moving
        self.headerConstraintRange = (CGFloat(self.headerView.frame.origin.y - self.headerView.frame.size.height)..<CGFloat(self.headerView.frame.origin.y))
        self.view.bringSubview(toFront: tableView) // Make sure the table view is always shown on top of the header view
        self.headerViewCriteria = self.headerView.frame.origin.y // Variable that uses the headerView's dimensions but doesn't directly affect it to achieve the desired effect
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backPage(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func requestToJoin(_ sender: AnyObject) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedSegueGroupProfileContainer" { //
            if let groupProfilePageView = segue.destination as? GroupProfilePageViewController {
                groupProfilePageView.group = self.group
            }
        }
    }
}

extension GroupProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default") as! UserTableViewCell
        
        let user = group.members[indexPath.row]
        
        cell.profilePhotoView.image = user.profilePhoto
        cell.profilePhotoView.layer.cornerRadius = cell.profilePhotoView.frame.size.width / 2
        cell.profilePhotoView.clipsToBounds = true
        
        cell.fullNameLabel.text = user.fullName
        cell.handleLabel.text = "@\(user.handle)"
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        
        // Compress the header view
        if delta > 0 && headerViewCriteria > headerConstraintRange.lowerBound && scrollView.contentOffset.y > 0 {
            scrollView.contentOffset.y -= delta
            self.headerViewCriteria -= delta
            
            self.tableView.frame.origin.y -= delta
            self.tableView.frame.size.height += delta
        }
        
        // Expand the header view
        if delta < 0 && headerViewCriteria < headerConstraintRange.upperBound && scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y -= delta
            self.headerViewCriteria -= delta
            
            self.tableView.frame.origin.y -= delta
            self.tableView.frame.size.height += delta
        }
        
        oldContentOffset = scrollView.contentOffset
    }
}
