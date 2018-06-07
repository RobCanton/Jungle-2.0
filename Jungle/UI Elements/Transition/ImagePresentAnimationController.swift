//
//  ImagePresentAnimationController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-27.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


class LightboxPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
   
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.45
    }
    
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        let toVC = transitionContext.viewController(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        // add the both views to our view controller

        container.addSubview(fromView)
        container.addSubview(toView)
        
        fromView.alpha = 1.0
        toView.alpha = 0.0
        
        toView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
       
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
            
            fromView.alpha = 0.5
            toView.alpha = 1.0
            toView.transform = CGAffineTransform.identity
        }, completion: { finished in
            fromView.alpha = 1.0
            transitionContext.completeTransition(true)
        })
        
    }
}





