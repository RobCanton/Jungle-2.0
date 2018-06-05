//
//  ImageDismissAnimationController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-27.
//  Copyright © 2018 Robert Canton. All rights reserved.
//


import Foundation
import UIKit
import AVFoundation

class LightboxDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func adjustFrameForStatusBar(_ frame:CGRect) -> CGRect {
        var tempFrame = frame
        tempFrame.origin.y -= UIApplication.shared.statusBarFrame.size.height
        return tempFrame
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let fromVC = transitionContext.viewController(forKey: .from) as! UIViewController
        let toVC = transitionContext.viewController(forKey: .to)!
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        fromView.alpha = 1.0

        fromView.transform = CGAffineTransform.identity
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseIn], animations: {
            fromView.alpha = 0.0
            fromView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

