//
//  PushTransitionAnimation.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol PushTransitionSourceDelegate {
    func staticTopView() -> UIImageView?
}

protocol PushTransitionDestinationDelegate {
    func staticTopView() -> UIImageView?
}

class PushTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let toVC = transitionContext.viewController(forKey: .to) as! PushTransitionDestinationDelegate
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        // add the both views to our view controller
        container.addSubview(fromView)
        container.addSubview(toView)
        let screenBounds = UIScreen.main.bounds
        
        let navBarFrame = CGRect(x: 0, y: 0, width: screenBounds.width, height: 70.0)
        let topView = fromView.snapshot(of: navBarFrame)
        if topView != nil {
            container.addSubview(topView!)
        }
        
        let topToView = toVC.staticTopView()
        topToView?.frame = navBarFrame
        if topToView != nil {
            topToView!.alpha = 0.0
            container.addSubview(topToView!)
        }
        
        toView.frame = CGRect(x: screenBounds.width, y: 0, width: toView.bounds.width, height: toView.bounds.height)
        
        
        let duration = self.transitionDuration(using: transitionContext)
        
        let endFromFrame = CGRect(x: -screenBounds.width*0.25, y: 0, width: fromView.bounds.width, height: fromView.bounds.height)
        
        let cubicTimingParameters = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.215, y: 0.61), controlPoint2: CGPoint(x: 0.355, y: 1.0))
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: cubicTimingParameters)
        animator.addAnimations() {
                topToView!.alpha = 1.0
                toView.frame = screenBounds
                fromView.frame = endFromFrame
                fromView.alpha = 0.5
        }

        animator.addCompletion() { _ in
            fromView.alpha = 1.0
            topView?.removeFromSuperview()
            topToView?.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        animator.startAnimation()
    }
}


class PopAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        let screenBounds = UIScreen.main.bounds
        toView.frame = CGRect(x: -screenBounds.width*0.25, y: 0, width: toView.bounds.width, height: toView.bounds.height)
    
        let navBarFrame = CGRect(x: 0, y: 0, width: screenBounds.width, height: 70.0)
        let topToView = toView.snapshot(of: navBarFrame)
        if topToView != nil {
            topToView!.alpha = 1.0
            container.addSubview(topToView!)
        }
        
        let topView = fromView.snapshot(of: navBarFrame)
        if topView != nil {
            topView!.alpha = 1.0
            container.addSubview(topView!)
        }
        
        //toView.alpha = 0.5
        toView.alpha = 0.5
        let duration = self.transitionDuration(using: transitionContext)
        let endFromFrame = CGRect(x: screenBounds.width, y: 0, width: fromView.bounds.width, height: fromView.bounds.height)
        
        UIView.animate(withDuration: duration, animations: {
            topView?.alpha = 0.0
            toView.frame = screenBounds
            fromView.frame = endFromFrame
            toView.alpha = 1.0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}




