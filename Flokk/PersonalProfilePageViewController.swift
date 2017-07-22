//
//  PersonalProfilePageViewController.swift
//  Flokk
//
//  Created by Gannon Prudomme on 7/16/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import PureLayout

class PersonalProfilePageViewController: TabmanViewController {
    var viewControllerPages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        self.bar.style = .buttonBar
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.layout.itemDistribution = TabmanBar.Appearance.Layout.ItemDistribution.centered
            appearance.indicator.compresses = true
            appearance.text.font = UIFont(name: "Josefin Sans", size: 17.5)
            appearance.indicator.color = TEAL_COLOR // Set the color to use for the bar indicator
            appearance.state.color = TEAL_COLOR // Set the color to use for unselected items
            appearance.state.selectedColor = TEAL_COLOR
            
            appearance.style.background = TabmanBarBackgroundView.BackgroundStyle.solid(color: NAVY_COLOR)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension PersonalProfilePageViewController: PageboyViewControllerDataSource {
    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        self.bar.items = [TabmanBarItem(title: "Saved"), TabmanBarItem(title: "Uploaded")] // Configure the bar
        
        // Initialize the first child page - your saved posts
        let viewController1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PersonalProfileSavedPageCollectionView") as! PersonalProfileSavedPageCollectionView
        
        viewControllerPages.append(viewController1)
        
        // Initialize the second child page - your uploaded posts
        let viewController2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PersonalProfileUploadedPageCollectionView") as! PersonalProfileUploadedPageCollectionView
        
        viewControllerPages.append(viewController2)
        
        return viewControllerPages
    }
    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        return nil // Use the default index
    }
}
