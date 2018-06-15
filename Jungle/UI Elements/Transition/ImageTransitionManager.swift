//
//  ImageTransitionManager.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-27.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class LightboxTransitionManager: NSObject, UIViewControllerTransitioningDelegate  {
    
    
    let interactor = Interactor()
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LightboxPresentAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if interactor.hasStarted {
            return DismissAnimator()
        }
        return LightboxDismissAnimationController()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
}


class DummyTransitionManager: NSObject, UIViewControllerTransitioningDelegate  {
    
    override init() {
        super.init()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
}
