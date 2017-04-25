//
//  GroupProfilePageViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 4/21/17.
//  Copyright © 2017 Akaro. All rights reserved.
//

import UIKit

class GroupProfilePageViewController: UIPageViewController {
    var viewControllerPages = [UIViewController]()
    
    var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self

        // Attempt to initialize the first child view controller
        if let viewController1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupProfileViewControllerPage1") as? GroupProfileViewControllerPage1 {
            
            viewController1.group = group
            viewControllerPages.append(viewController1)
        }
        
        // Attempt to initialize the second child view controller
        if let viewController2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupProfileViewControllerPage2") as? GroupProfileViewControllerPage2 {
            viewController2.group = self.group
            viewControllerPages.append(viewController2)
        }
        
        // Set the initial view controller
        self.setViewControllers([viewControllerPages[0]], direction: .forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// Page View Controller functions
extension GroupProfilePageViewController: UIPageViewControllerDataSource {
    // Return what view controller should be shown when swiping left
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllerPages.index(of: viewController) else {
            return nil
        }
        
        if viewControllerIndex == 1 {
            return viewControllerPages[0]
        }
        
        return nil
    }
    
    // Return what view controller should be shown when swiping right
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllerPages.index(of: viewController) else {
            return nil
        }
        
        if viewControllerIndex == 0 {
            return viewControllerPages[1]
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 2 // No need to do viewControllerPages.count, this will always be 2
    }
}

// View Controller at the top of the group profile
// Contains the Group Icon and the Group Name
class GroupProfileViewControllerPage1: UIViewController {
    @IBOutlet weak var groupIconView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groupIconView.image = group.groupIcon
        self.groupIconView.layer.cornerRadius = self.groupIconView.frame.size.width / 2
        self.groupIconView.clipsToBounds = true
        
        self.groupNameLabel.text = group.groupName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// Second Page for the group info at the top of the group profile - not shown by default
// Contains when the group was created, who created it, and how many people are in the group
class GroupProfileViewControllerPage2: UIViewController {
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var groupSizeLabel: UILabel!
    
    var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.creatorNameLabel.text = group.groupCreator.fullName
        self.groupSizeLabel.text = "\(group.participants.count)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
