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

class ProfileViewController:UIViewController, ASTableDelegate, ASTableDataSource {

    var postsVC:MyRecentPostsTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        postsVC = MyRecentPostsTableViewController()
        
        postsVC.willMove(toParentViewController: self)
        view.addSubview(postsVC.view)
        addChildViewController(postsVC)
        postsVC.didMove(toParentViewController: self)
        
        let layoutGuide = view.safeAreaLayoutGuide
        postsVC.view.translatesAutoresizingMaskIntoConstraints = false
        postsVC.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        postsVC.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -20).isActive = true
        postsVC.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        postsVC.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
//        let layoutGuide = view.safeAreaLayoutGuide
//        view.addSubview(tableNode.view)
//        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
//        tableNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
//        tableNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
//        tableNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -20.0).isActive = true
//        tableNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
//        tableNode.view.showsVerticalScrollIndicator = false
//        tableNode.delegate = self
//        tableNode.dataSource = self
////        tableNode.view.delaysContentTouches = false
////        tableNode.view.panGestureRecognizer.delaysTouchesBegan = false
//        tableNode.view.contentInsetAdjustmentBehavior = .never
//
//        tableNode.reloadData()
//
//        tableNode.view.separatorStyle = .none
//        //tableNode.view.bounces = false
//        updateHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //profileHeader.setLevelProgress(0.67)
        
        SearchService.searchMyPosts(offset: 0) { posts, endReached in
            for post in posts {
                print("TEXT: \(post.text)")
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = ASTextCellNode()
        cell.text = "Row #\(indexPath.row)"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeader()
    }
    
    func updateHeader() {
//        var progress:CGFloat = 1.0
//        if tableNode.contentOffset.y < -headerHeight {
//
//            headerHeightAnchor.constant = -tableNode.contentOffset.y
//        } else {
//            //print("Offset: \(-tableNode.contentOffset.y)")
//            progress = (-tableNode.contentOffset.y - 108) / (headerHeight - 108)
//            headerHeightAnchor.constant = max(-tableNode.contentOffset.y, 108)
//
//        }
//        profileHeader.updateProgress(max(progress,0))
//        //let progress =
    }
}
