//
//  PushTransitionAnimation.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit


class PushTransitionManager: NSObject, UIViewControllerTransitioningDelegate  {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return PushTransitionAnimation()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return PopAnimationController()
    }
    
}


class PushTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.45
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        let toVC = transitionContext.viewController(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        // add the both views to our view controller
        container.addSubview(fromView)
        container.addSubview(toView)
        let screenBounds = UIScreen.main.bounds
        toView.frame = CGRect(x: screenBounds.width, y: 0, width: toView.bounds.width, height: toView.bounds.height)
    
        let duration = self.transitionDuration(using: transitionContext)
        
        let endFromFrame = CGRect(x: -screenBounds.width*0.5, y: 0, width: fromView.bounds.width, height: fromView.bounds.height)
        let cubicTimingParameters = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.215, y: 0.61), controlPoint2: CGPoint(x: 0.355, y: 1.0))
        let animator = UIViewPropertyAnimator(duration: 0.35, timingParameters: cubicTimingParameters)
        animator.addAnimations() {
                toView.frame = screenBounds
                fromView.frame = endFromFrame
                fromView.alpha = 0.75
                
        }
        
        animator.addCompletion() { _ in
            transitionContext.completeTransition(true)
        }
        
        animator.startAnimation()
    }
}


class PopAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as! UIViewController
        let toVC = transitionContext.viewController(forKey: .to)!
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        let screenBounds = UIScreen.main.bounds
        toView.frame = CGRect(x: -screenBounds.width*0.5, y: 0, width: toView.bounds.width, height: toView.bounds.height)
        
        toView.alpha = 0.75
        let duration = self.transitionDuration(using: transitionContext)
        
        print("RXC GAS BUDDY")
        let endFromFrame = CGRect(x: screenBounds.width, y: 0, width: fromView.bounds.width, height: fromView.bounds.height)
        let cubicTimingParameters = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.215, y: 0.61), controlPoint2: CGPoint(x: 0.355, y: 1.0))
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: cubicTimingParameters)
        animator.addAnimations() {
            toView.frame = screenBounds
            fromView.frame = endFromFrame
            toView.alpha = 1.0
        }
        
        animator.addCompletion() { _ in
            transitionContext.completeTransition(true)
        }
        
        animator.startAnimation()
    }
}




