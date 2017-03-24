//
//  NavigationControllerDelegate.swift
//  Flokk
//
//  Created by Jared Heyen on 3/21/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation
import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        print("navigation controller delegate")
        return SlideForwardAnimator(right: true)
    }
}
