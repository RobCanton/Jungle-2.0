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
    
    let interactor = Interactor()
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PushTransitionAnimation()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PopAnimationController()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
}

