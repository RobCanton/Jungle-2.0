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



protocol LightboxTransitionSourceDelegate:class {
    func transitionWillBegin(_ isPresenting:Bool)
    func transitionDidEnd(_ isPresenting:Bool)
    func transitionSourceImage() -> UIImage?
    func transitionSourceFrame(_ parentView:UIView) -> CGRect
}



class LightboxPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let sourceDelegate:LightboxTransitionSourceDelegate
    private let destinationDelegate:LightboxTransitionDestinationDelegate
    
    init(_ sourceDelegate:LightboxTransitionSourceDelegate, _ destinationDelegate:LightboxTransitionDestinationDelegate) {
        self.sourceDelegate = sourceDelegate
        self.destinationDelegate = destinationDelegate
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.sourceDelegate.transitionWillBegin(true)
        self.destinationDelegate.transitionWillBegin(true)
        
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        let toVC = transitionContext.viewController(forKey: .to) as! UIViewController
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        // add the both views to our view controller

        container.addSubview(fromView)
        container.addSubview(toView)
        
        toView.alpha = 0.0
        

        let videoTransitionView = UIImageView(frame: sourceDelegate.transitionSourceFrame(fromView))
        
        videoTransitionView.contentMode = .scaleAspectFill
        videoTransitionView.image = sourceDelegate.transitionSourceImage()
        videoTransitionView.layer.cornerRadius = 16.0
        videoTransitionView.clipsToBounds = true
        
        var imageSize = videoTransitionView.image!.size
        let toViewSize = UIScreen.main.bounds
        print("IMAGE SIZE: \(imageSize) | \(toView.bounds.size)")

        imageSize.height = (toViewSize.width / imageSize.width) * imageSize.height
        imageSize.width = toViewSize.width
        
        let destinationFrame = CGRect(x: 0, y: toViewSize.height / 2 - imageSize.height / 2, width: imageSize.width, height: imageSize.height)
        
        let color = UIColor(white: 0.0, alpha: 1.0)
        let offset = CGSize(width: 0, height: 18.0)
        
        videoTransitionView.applyShadow(radius: 18.0, opacity: 0.15, offset: offset, color: color, shouldRasterize: false)
        container.addSubview(videoTransitionView)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
            //button.alpha = 1.0
            toView.alpha = 1.0
            videoTransitionView.layer.cornerRadius = 0.0
            videoTransitionView.frame = destinationFrame
            
        }, completion: { finished in
            toView.alpha = 1.0
            videoTransitionView.removeFromSuperview()
            self.sourceDelegate.transitionDidEnd(true)
            self.destinationDelegate.transitionDidEnd(true)
            transitionContext.completeTransition(true)
        })
        
    }
}





