//
//  SlideBackwardAnimator.swift
//  Flokk
//
//  Created by Gannon Prudhommes on 3/21/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit
import Foundation

//literally only 2 lines of code changed
class SlideBackwardAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    private var presenting = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        // set up from 2D transforms that we'll use in the animation
        let offScreenRight = CGAffineTransform(translationX: containerView.frame.width, y: 0)
        let offScreenLeft = CGAffineTransform(translationX: -containerView.frame.width, y: 0)
        
        toView.transform = offScreenLeft
        
        containerView.addSubview(toView)
        //toVC!.view.alpha = 0.0
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            // slide fromView off either the left or right edge of the screen
            // depending if we're presenting or dismissing this view
            fromView.transform = offScreenRight
            toView.transform = CGAffineTransform.identity
            
        }, completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!cancelled)
        })
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
