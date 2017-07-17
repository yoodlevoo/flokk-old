//
//  PersonalProfilePageViewController.swift
//  Flokk
//
//  Created by Gannon Prudomme on 7/16/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class PersonalProfilePageViewController: UIPageViewController {
    var viewControllerPages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the first child page - your saved posts
        let viewController1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PersonalProfileSavedPageCollectionView") as! PersonalProfileSavedPageCollectionView
        
        viewControllerPages.append(viewController1)
        
        // Initialize the second child page - your uploaded posts
        let viewController2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PersonalProfileUploadedPageCollectionView") as! PersonalProfileUploadedPageCollectionView
        
        viewControllerPages.append(viewController2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// Page View Controller Functions - basically just copied from GroupProfileView, serves same purpose
extension PersonalProfilePageViewController: UIPageViewControllerDataSource {
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
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
