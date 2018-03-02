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

protocol LightboxTransitionDestinationDelegate:class {
    func transitionWillBegin(_ isPresenting:Bool)
    func transitionDidEnd(_ isPresenting:Bool)
    func transitionDestinationFrame() -> CGRect
}

class LightboxDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let sourceDelegate:LightboxTransitionSourceDelegate
    private let destinationDelegate:LightboxTransitionDestinationDelegate
    
    init(_ sourceDelegate:LightboxTransitionSourceDelegate, _ destinationDelegate:LightboxTransitionDestinationDelegate) {
        self.sourceDelegate = sourceDelegate
        self.destinationDelegate = destinationDelegate
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func adjustFrameForStatusBar(_ frame:CGRect) -> CGRect {
        var tempFrame = frame
        tempFrame.origin.y -= UIApplication.shared.statusBarFrame.size.height
        return tempFrame
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.sourceDelegate.transitionWillBegin(false)
        self.destinationDelegate.transitionWillBegin(false)
        
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let fromVC = transitionContext.viewController(forKey: .from) as! UIViewController
        let toVC = transitionContext.viewController(forKey: .to)!
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        fromView.alpha = 1.0
        
        let image = sourceDelegate.transitionSourceImage()!
        var imageSize = image.size
        let toViewSize = UIScreen.main.bounds
        

        imageSize.height = (toViewSize.width / imageSize.width) * imageSize.height
        imageSize.width = toViewSize.width

        let destinationFrame = CGRect(x: 0, y: toViewSize.height / 2 - imageSize.height / 2, width: imageSize.width, height: imageSize.height)
        
        let videoTransitionView = UIImageView(frame: destinationFrame)
        
        videoTransitionView.contentMode = .scaleAspectFill
        videoTransitionView.image = image
        videoTransitionView.layer.cornerRadius = 0.0
        videoTransitionView.clipsToBounds = true
        
        
        let sourceFrame = sourceDelegate.transitionSourceFrame(toView)
        
        container.addSubview(videoTransitionView)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
            fromView.alpha = 0.0
            videoTransitionView.layer.cornerRadius = 16.0
            videoTransitionView.frame = sourceFrame
            
            
        }, completion: { finished in
            videoTransitionView.removeFromSuperview()
            self.sourceDelegate.transitionDidEnd(false)
            self.destinationDelegate.transitionDidEnd(false)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

