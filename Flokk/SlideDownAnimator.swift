//
//  SlideUpAnimator.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/21/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation
import UIKit

//dismiss this view
class SlideDownAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    private var presenting = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        // set up from 2D transforms that we'll use in the animation
        let offScreenDown = CGAffineTransform(translationX: 0, y: -containerView.frame.height)
        let offScreenUp = CGAffineTransform(translationX: 0, y: containerView.frame.height)
        
        toView.transform = offScreenDown
        //toView.transform = CGAffineTransform.identity
        
        //add both views to the container(so they're both rendered)
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        //then add whatever the "main view" is to the back
        containerView.sendSubview(toBack: fromView)
        
        //make the transition slightly transparent so it appears more smooth
        toView.alpha = 0.5
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            //fromView.transform = offScreenUp
            //set the alpha/transparency so it shows 100%
            toView.alpha = 1.0
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

