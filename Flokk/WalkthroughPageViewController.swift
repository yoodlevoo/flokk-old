//
//  WalkthroughPageViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 7/10/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController {
    var viewControllerPages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make the nav bar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        self.dataSource = self
        
        // Attempt to initialize the first child view controller
        let viewController1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalkthroughPage1")
        viewControllerPages.append(viewController1)
        
        // Attempt to initialize the second child view controller
        let viewController2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalkthroughPage2")
        viewControllerPages.append(viewController2)
        
        // Attempt to initialize the third child view controller
        let viewController3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalkthroughPage3")
        viewControllerPages.append(viewController3)
        
        // Set the initial view controller
        self.setViewControllers([viewControllerPages[0]], direction: .forward, animated: true, completion: nil)
        
        // Customize the page control indicator dots
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        pageControl.pageIndicatorTintColor = UIColor.init(colorLiteralRed: 43/255.0, green: 170/255.0, blue: 226/255.0, alpha: 0.4)
        pageControl.currentPageIndicatorTintColor = TEAL_COLOR
        pageControl.backgroundColor = NAVY_COLOR

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// Page View Controller functions
extension WalkthroughPageViewController: UIPageViewControllerDataSource {
    // Return what view controller should be shown when swiping left
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllerPages.index(of: viewController) else {
            return nil
        }
        
        if viewControllerIndex == 1 {
            return viewControllerPages[0]
        }
        
        if viewControllerIndex == 2 {
            return viewControllerPages[1]
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
        
        if viewControllerIndex == 1 {
            return viewControllerPages[2]
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllerPages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
