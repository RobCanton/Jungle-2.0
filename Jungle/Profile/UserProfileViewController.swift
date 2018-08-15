//
//  UserProfileViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-08-12.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import MXParallaxHeader

class UserProfileViewController:UIViewController, ASPagerDelegate, ASPagerDataSource, MXScrollViewDelegate {
    
    var interactor:Interactor? = nil
    var profile:Profile?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        let percentThreshold:CGFloat = 0.3
        let verticalMovement = translation.x / view.bounds.width
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.shouldFinish = false
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
    
    lazy var scrollView = MXScrollView()
    var pagerNode = ASPagerNode()
    
    var headerView:UserProfileHeaderView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        headerView = UserProfileHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 210))
        scrollView.parallaxHeader.view = headerView
        scrollView.parallaxHeader.height = 210
        scrollView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        scrollView.parallaxHeader.minimumHeight = 70 + 32
        scrollView.delegate = self
        
        if scrollView.superview == nil {
            view.addSubview(scrollView)
        }

        pagerNode.view.frame = CGRect(x: 0, y: 0,
                                      width: view.bounds.width,
                                      height: view.bounds.height - (70 + 32))
        if pagerNode.view.superview == nil {
            scrollView.addSubview(pagerNode.view)
        }
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.reloadData()
        
        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan))
        edgeSwipe.edges = .left
        view.addGestureRecognizer(edgeSwipe)
        view.isUserInteractionEnabled = true
        
        headerView.titleView.leftButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        headerView.tabScrollView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let frame = view.frame
        scrollView.frame = frame
        scrollView.contentSize = frame.size
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        headerView.setProfile(profile)
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 2
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        
        let cellNode = ASCellNode()
        guard let profile = profile else { return cellNode}
        cellNode.frame = pagerNode.bounds
        cellNode.backgroundColor = index % 2 == 0 ? UIColor.blue : UIColor.yellow
        var controller:PostsTableViewController!
        switch index {
        case 0:
            controller = UserPostsTableViewController(username: profile.username)
            break
        case 1:
            controller = UserCommentsTableViewController(username: profile.username)
            break
        default:
            break
        }
        controller.willMove(toParentViewController: self)
        self.addChildViewController(controller)
        controller.view.frame = cellNode.bounds
        cellNode.addSubnode(controller.node)
        let layoutGuide = cellNode.view.safeAreaLayoutGuide
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        return cellNode
    }
    // MARK: - Table view data source
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            var progress = scrollView.parallaxHeader.progress
            
            if progress.isNaN {
                return
            }
    
            headerView.setProgress(progress)
        } else if scrollView == self.pagerNode.view {
            let offsetX = scrollView.contentOffset.x
            let viewWidth = view.bounds.width
            let progress = offsetX / viewWidth
            headerView.tabScrollView.setProgress(progress, index: 0)
            //headerView.updateTabScrollPosition(scrollView.contentOffset.x)
        }
    }

}

extension UserProfileViewController: TabScrollDelegate {
    func tabScrollTo(index: Int) {
        pagerNode.scrollToPage(at: index, animated: true)
    }
}
