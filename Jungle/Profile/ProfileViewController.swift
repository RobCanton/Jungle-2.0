//
//  ProfileViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-10.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class ProfileViewController:UIViewController, ASPagerDelegate, ASPagerDataSource, UIGestureRecognizerDelegate, TabScrollDelegate {
    
    var titleView:JTitleView!
    var pagerNode:ASPagerNode!
    var tabScrollView:DualScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let layoutGuide = view.safeAreaLayoutGuide
        let topInset = UIApplication.deviceInsets.top
        let titleViewHeight = 50 + topInset
        
        titleView = JTitleView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: titleViewHeight), topInset: topInset)
        view.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: titleViewHeight).isActive = true
        titleView.rightButton.setImage(UIImage(named:"Settings"), for: .normal)
        titleView.rightButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        titleView.titleLabel.text = "MY ACCOUNT"
        titleView.backgroundImage.isHidden = true
        titleView.backgroundColor = UIColor.clear
        
        let scrollTabBar = UIView()
        view.addSubview(scrollTabBar)
        scrollTabBar.translatesAutoresizingMaskIntoConstraints = false
        scrollTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollTabBar.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 0).isActive = true
        scrollTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollTabBar.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        tabScrollView = DualScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 104, height: 44.0), title1: "POSTS", title2: "COMMENTS")
        scrollTabBar.addSubview(tabScrollView)
        tabScrollView.translatesAutoresizingMaskIntoConstraints = false
        tabScrollView.leadingAnchor.constraint(equalTo: scrollTabBar.leadingAnchor, constant: 52.0).isActive = true
        tabScrollView.trailingAnchor.constraint(equalTo: scrollTabBar.trailingAnchor, constant: -52.0).isActive = true
        tabScrollView.topAnchor.constraint(equalTo: scrollTabBar.topAnchor).isActive = true
        tabScrollView.bottomAnchor.constraint(equalTo: scrollTabBar.bottomAnchor).isActive = true
        tabScrollView.delegate = self
        
        let bgImageView = UIImageView(image: UIImage(named:"GreenBox"))
        view.insertSubview(bgImageView, belowSubview: titleView)
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bgImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bgImageView.heightAnchor.constraint(equalToConstant:  titleViewHeight + 32.0).isActive = true
        
        pagerNode = ASPagerNode()
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.backgroundColor = hexColor(from: "#eff0e9")
        view.addSubview(pagerNode.view)
        pagerNode.view.translatesAutoresizingMaskIntoConstraints = false
        pagerNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        pagerNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        pagerNode.view.topAnchor.constraint(equalTo: scrollTabBar.bottomAnchor).isActive = true
        pagerNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        pagerNode.view.delaysContentTouches = false
        //pagerNode.view.isScrollEnabled = false
        pagerNode.view.panGestureRecognizer.delaysTouchesBegan = false
        pagerNode.reloadData()
    }
    
    var pushTransition = PushTransitionManager()
    
    @objc func openSettings() {
        let controller = SettingsViewController()
        let navBarHeight = 50 + UIApplication.deviceInsets.top
        pushTransition.navBarHeight = navBarHeight
        controller.interactor = pushTransition.interactor
        controller.transitioningDelegate = pushTransition
        
        self.present(controller, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.frame = pagerNode.bounds
        cellNode.backgroundColor = index % 2 == 0 ? UIColor.blue : UIColor.yellow
        var controller:PostsTableViewController!
        switch index {
        case 0:
            controller = MyPostsTableViewController()
            break
        case 1:
            controller = MyCommentsTableViewController()
            break
        default:
            controller = LikedPostsTableViewController()
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
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 2
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == pagerNode.view else { return }
        let offsetX = scrollView.contentOffset.x
        let viewWidth = view.bounds.width
        let progress = offsetX / viewWidth
        tabScrollView.setProgress(progress, index: 0)
    }
    
    func tabScrollTo(index: Int) {
        pagerNode.scrollToPage(at: index, animated: true)
    }

}
