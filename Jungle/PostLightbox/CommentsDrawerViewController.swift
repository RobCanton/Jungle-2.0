//
//  CommentsDrawerViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-13.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase
import Pulley

class CommentsDrawerViewController:UIViewController {
    var currentPost:Post?
    var commentsVC:CommentsViewController?
    
    var showComments = false
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        pulleyViewController?.view.addGestureRecognizer(pan)
        if showComments, let post = currentPost {
            showComments = false
            let commentsVC = pulleyViewController?.drawerContentViewController as! CommentsDrawerViewController
            commentsVC.setup(withPost: post, showKeyboard: false)
            self.pulleyViewController?.setDrawerPosition(position: .open, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    var interactor:Interactor? = nil
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        
        if self.pulleyViewController?.drawerPosition != .collapsed { return }
        //        if let _ = self.pulleyViewController?.parent as? JViewController {
        //            print("OOH YEA BABY!")
        //        }
        
        let percentThreshold:CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        if translation.y < 0 {
            if translation.y < -5,
                let post = currentPost{
                print("THIS IS HAPPENING")
                
                let commentsVC = pulleyViewController?.drawerContentViewController as! CommentsDrawerViewController
                commentsVC.setup(withPost: post, showKeyboard: false)
                self.pulleyViewController?.setDrawerPosition(position: .open, animated: true)
            }
            interactor?.hasStarted = false
            interactor?.shouldFinish = false
            interactor?.cancel()
            return
        }
        
        let lightBox = self.pulleyViewController?.primaryContentViewController as! LightboxViewController
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        lightBox.setCurrentCellVolume(1 - progress)
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
    
    func setup(withPost post:Post, showKeyboard:Bool?=nil) {
        if let showKeyboard = showKeyboard, showKeyboard {
            DispatchQueue.main.async {
                self.commentsVC?.commentBar.textView.becomeFirstResponder()
            }
        }
        
        commentsVC?.willMove(toParentViewController: nil)
        commentsVC?.view.removeFromSuperview()
        commentsVC?.didMove(toParentViewController: nil)
        commentsVC = nil
        
        self.currentPost = post
        commentsVC = CommentsViewController()
        commentsVC!.post = post
        commentsVC!.willMove(toParentViewController: self)
        addChildViewController(commentsVC!)
        commentsVC!.view.frame = view.bounds
        view.addSubview(commentsVC!.view)
        commentsVC!.didMove(toParentViewController: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        get { return true }
    }
    
}

extension CommentsDrawerViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 0.0
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return view.bounds.height * 3/5 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.open, .collapsed] // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        if distance < view.bounds.height {
            commentsVC?.commentBar.textView.resignFirstResponder()
        }
        
        
    }
    
    
    
}
