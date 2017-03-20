//
//  ImageTransition.swift
//  Flokk
//
//  Created by Jared Heyen on 3/10/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class PostTransition: NSObject {
    
    var post = UIView()
    
    var startingPoint = CGPoint.zero {
        didSet {
            post.center = startingPoint
        }
    }
    
    var postColor = UIColor.white
    
    var duration = 0.3
    
    enum PostTransitionMode:Int {
        case present, dismiss, pop
    }
    
    var transitionMode:PostTransitionMode = .present
    
}

extension PostTransition:UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func  animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if transitionMode == .present {
            if let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
                let viewCenter = presentedView.center
                let viewSize = presentedView.frame.size
                
                post = UIView()
                
                post.frame = frameForPost(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
                
                post.layer.cornerRadius = post.frame.size.height / 2
                post.center = startingPoint
                post.backgroundColor = postColor
                post.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                containerView.addSubview(post)
                
                
                presentedView.center = startingPoint
                presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                presentedView.alpha = 0
                containerView.addSubview(presentedView)
                
                UIView.animate(withDuration: duration, animations: {
                    self.post.transform = CGAffineTransform.identity
                    presentedView.transform = CGAffineTransform.identity
                    presentedView.alpha = 1
                    presentedView.center = viewCenter
                    
                }, completion: { (success:Bool) in
                    transitionContext.completeTransition(success)
                    
                })
                
                
            }
            
        }else{
            let transitionModeKey = (transitionMode == .pop) ? UITransitionContextViewKey.to : UITransitionContextViewKey.from
            
            if let returningView = transitionContext.view(forKey: transitionModeKey) {
                let viewCenter =  returningView.center
                let viewSize = returningView.frame.size
                
                post.frame = frameForPost(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
                
                post.layer.cornerRadius = post.frame.size.height / 2
                post.center = startingPoint
                
                UIView.animate(withDuration: duration, animations: {
                    self.post.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    returningView.transform = CGAffineTransform(scaleX: 0.001, y:0.001)
                    returningView.center = self .startingPoint
                    returningView.alpha = 0
                    
                    if self.transitionMode == .pop {
                        containerView.insertSubview(returningView, belowSubview: returningView)
                        containerView.insertSubview(self.post, belowSubview: returningView)
                    }
                    
                    
                }, completion: { (success:Bool) in
                    returningView.center = viewCenter
                    returningView.removeFromSuperview()
                    
                    self.post.removeFromSuperview()
                    
                    transitionContext.completeTransition(success)
                    
                })
                
            }
        
        }

    }
    


func frameForPost (withViewCenter viewCenter:CGPoint, size viewSize:CGSize, startPoint:CGPoint) -> CGRect {
    let xLength = fmax(startPoint.x, viewSize.width - startPoint.x)
    let yLength = fmax(startPoint.y, viewSize.height - startPoint.y)
    
    let offsetVector = sqrt(xLength * xLength + yLength * yLength) * 2
    let size = CGSize(width: offsetVector, height: offsetVector)
    
    return CGRect(origin: CGPoint.zero, size: size)
    
   
    
    
    }

}


