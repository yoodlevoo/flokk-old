//
//  FeedNavigationViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 2/2/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

//basically only used to change the navigation bar's color
class FeedNavigationViewController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    weak var groupToPass: Group! //weak b/c I don't want this object to be retained
    
    var isPushingViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.title = groupToPass.groupName
        let feedVC = self.viewControllers[0] as! FeedViewController
        feedVC.group = groupToPass
        //print("view did load feed nav")
        
        //self.navigationBar.barTintColor = UIColor.darkGray
        
        self.delegate = self
        self.interactivePopGestureRecognizer?.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        isPushingViewController = true
        super.pushViewController(viewController, animated: animated)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is UIScreenEdgePanGestureRecognizer else { return true }
        return viewControllers.count > 1 && !isPushingViewController
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        isPushingViewController = false
    }
}
