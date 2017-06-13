//
//  PhotoUploadPageViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/1/17.
//  Copyright © 2017 Akaro. All rights reserved.
//

import UIKit

class PhotoUploadPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    var groupToPass: Group!
    var groupIndexToPass: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
            
            if let photoSelect = firstViewController as? TempPhotoSelectViewController {
                photoSelect.forGroup = groupToPass
                photoSelect.groupIndex = groupIndexToPass
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Returns the view controller to be shown next
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        if viewControllerIndex == 0 {
            return orderedViewControllers.last
        }
        
        return nil
    }
    
    // Returns the view controller to be shown before this one
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        if viewControllerIndex == 1 {
            return orderedViewControllers.first
        }
        
        return nil
    }
    
    // Returns the number of items to be shown on the page indicator
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first, let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
            return 0
        }
        
        return firstViewControllerIndex
    }
    
    private func newColoredViewController(kind: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(kind)ViewController")
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController(kind: "PhotoSelect"), self.newColoredViewController(kind: "TakePhoto")]
    }()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromPhotoSelectPageToFeed" {
            if let feedNav = segue.destination as? FeedNavigationViewController {
                feedNav.groupToPass = groupToPass
            }
        }
    }
}
