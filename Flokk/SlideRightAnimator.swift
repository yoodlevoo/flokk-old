//
//  SlideRightAnimator.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 4/6/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import Foundation
import UIKit

class SlideRightAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    var presenting: Bool
    
    override init() {
        presenting = true
    }
    
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
        
        if self.presenting {
            toView.transform = offScreenRight
        }
        
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        containerView.sendSubview(toBack: self.presenting ? fromView : toView)
        //toVC!.view.alpha = 0.0
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            // slide fromView off either the left or right edge of the screen
            // depending if we're presenting or dismissing this view
            
            if !self.presenting {
                fromView.transform = offScreenRight
            }
            
            toView.transform = CGAffineTransform.identity
            
        }, completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!cancelled)
        })
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        
        return self
    }
}
