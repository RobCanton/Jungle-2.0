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
    var moreButton:UIButton!
    var pagerNode:ASPagerNode!
    
    var posts = [Post]()
    
    var initialIndex:Int?
    
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
        closeButtonAnchor = closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        closeButtonAnchor?.isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 64.0).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        moreButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64.0, height: 64.0))
        moreButton.setImage(UIImage(named:"more_white"), for: .normal)
        moreButton.tintColor = UIColor.white
        view.addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        moreButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 64.0).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        //moreButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        
    }
    
    var closeButtonAnchor:NSLayoutConstraint?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let initialIndex = initialIndex {
            DispatchQueue.main.async {
                self.pagerNode.scrollToPage(at: initialIndex, animated: false)
                self.pagerNode.isHidden = false
                self.initialIndex = nil
            }
        }
        
        
        statusBarHidden = true
        UIView.animate(withDuration: 0.05, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let cells = pagerNode.visibleNodes as? [SinglePostCellNode] ?? []
        if cells.count > 0 {
            cells[0].stopObservingPost()
            cells[0].observePost()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func setCurrentCellVolume(_ volume:CGFloat) {
        let cellNodes = pagerNode.visibleNodes as? [SinglePostCellNode] ?? []
        if cellNodes.count > 0 {
            cellNodes[0].contentNode.videoNode.player?.volume = Float(volume)
        }
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
    func openComments(_ post:Post, _ showKeyboard:Bool) {
        let commentsVC = pulleyViewController?.drawerContentViewController as! CommentsDrawerViewController
        commentsVC.setup(withPost: post, showKeyboard: showKeyboard)
        self.pulleyViewController?.setDrawerPosition(position: .open, animated: true)
    }
}

extension LightboxViewController: PulleyPrimaryContentControllerDelegate {
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        let progress = min(max((distance) / (view.bounds.height / 2), 0), 1)
        //        //view.backgroundColor = UIColor(white: 0.0, alpha: 0.75 * progress)
        //        print("PROGRESS: \(progress)")
        //
        closeButton.alpha = 1 - progress
        let scale = 1 - 0.02 * progress
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8 * progress
        contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        print("PROGRESS: \(progress)")
        
        setCurrentCellVolume(1 - progress)
        //dimView.alpha = 0.25 * progress
        
    }
    
//    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
//        switch drawer.drawerPosition {
//        case PulleyPosition.closed:
//            let cells = pagerNode.visibleNodes as? [SinglePostCellNode] ?? []
//            if cells.count > 0 {
//                cells[0].stopObservingPost()
//                cells[0].observePost()
//            }
//            break
//        default:
//            break
//        }
//    }
}
