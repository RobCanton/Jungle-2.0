//
//  FullscreenImageViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-27.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import DeckTransition
import Pulley

class LightboxViewController:UIViewController, ASPagerDelegate, ASPagerDataSource {
    
    var closeButton:UIButton!
    var pagerNode:ASPagerNode!
    
    var posts = [Post]()
    
    var initialIndex = 0
    
    var dimView:UIView!
    var contentView:UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        contentView = UIView(frame: view.bounds)
        view.addSubview(contentView)
        
        pagerNode = ASPagerNode()
        pagerNode.backgroundColor = UIColor.black
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.isHidden = true
        let pagerView = pagerNode.view
        contentView.addSubview(pagerView)
        pagerView.translatesAutoresizingMaskIntoConstraints = false
        pagerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        pagerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        pagerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        pagerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        pagerNode.reloadData()
        
        let layoutGuide = contentView.safeAreaLayoutGuide
        
        dimView = UIView(frame:contentView.bounds)
        dimView.backgroundColor = UIColor.black
        contentView.addSubview(dimView)
        dimView.isUserInteractionEnabled = false
        dimView.alpha = 0.0
        
        closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64.0, height: 64.0))
        closeButton.setImage(UIImage(named:"close"), for: .normal)
        closeButton.tintColor = UIColor.white
        contentView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        closeButtonAnchor = closeButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 0)
        closeButtonAnchor?.isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 64.0).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
    }
    
    var closeButtonAnchor:NSLayoutConstraint?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.pagerNode.scrollToPage(at: self.initialIndex, animated: false)
            self.pagerNode.isHidden = false
        }
        
        statusBarHidden = true
        UIView.animate(withDuration: 0.05, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.pagerNode.setContentOffset(CGPoint(x:500,y:0), animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    var statusBarHidden = false
    override var prefersStatusBarHidden: Bool {
        get {
            return statusBarHidden
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    @objc func handleDismiss() {
//        let modal = CommentsViewController()
//        let transitionDelegate = DeckTransitioningDelegate()
//        modal.transitioningDelegate = transitionDelegate
//        modal.modalPresentationStyle = .custom
//        present(modal, animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return posts.count
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let cell = SinglePostCellNode(post: posts[index])
        cell.delegate = self
        return cell
    }
}

extension LightboxViewController : SinglePostDelegate {
    func openComments(_ post:Post) {
        self.pulleyViewController?.setDrawerPosition(position: .open, animated: true)
    }
}

extension LightboxViewController: PulleyPrimaryContentControllerDelegate {
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        let progress = (distance) / (view.bounds.height / 2)
        //        //view.backgroundColor = UIColor(white: 0.0, alpha: 0.75 * progress)
        //        print("PROGRESS: \(progress)")
        //
        closeButton.alpha = 1 - progress
        let scale = 1 - 0.02 * progress
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8 * progress
        contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        //dimView.alpha = 0.25 * progress
        
    }
}
