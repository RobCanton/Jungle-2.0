//
//  PushTransitionManager.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-15.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
class PushTransitionManager: NSObject, UIViewControllerTransitioningDelegate  {

    var navBarHeight:CGFloat?
    let interactor = Interactor()
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PushTransitionAnimation(navBarHeight: navBarHeight)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PopAnimationController(navBarHeight: navBarHeight)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
}

