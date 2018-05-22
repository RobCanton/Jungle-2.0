//
//  MyRecentPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-20.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit
import Foundation
import AsyncDisplayKit

class MyRecentPostsTableViewController: PostsTableViewController {
    
    
    var profileHeader:ProfileHeaderView!
    var headerTopAnchor:NSLayoutConstraint!
    var headerHeightAnchor:NSLayoutConstraint!
    
    private let headerHeight:CGFloat = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableGuide = tableNode.view.safeAreaLayoutGuide
        
        profileHeader = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight))
        tableNode.view.tableHeaderView = nil
        tableNode.view.addSubview(profileHeader)
        
        profileHeader.leadingAnchor.constraint(equalTo: tableGuide.leadingAnchor).isActive = true
        profileHeader.trailingAnchor.constraint(equalTo: tableGuide.trailingAnchor).isActive = true
        headerTopAnchor = profileHeader.topAnchor.constraint(equalTo: tableGuide.topAnchor, constant: -20.0)
        headerTopAnchor.isActive = true
        headerHeightAnchor = profileHeader.heightAnchor.constraint(equalToConstant: headerHeight)
        headerHeightAnchor.isActive = true
        
        tableNode.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0)
        tableNode.contentOffset = CGPoint(x: 0, y: -headerHeight)
        
        newPostsView.isHidden = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeader()
    }
    
    func updateHeader() {
        var progress:CGFloat = 1.0
        if tableNode.contentOffset.y < -headerHeight {

            headerHeightAnchor.constant = -tableNode.contentOffset.y
        } else {
            progress = (-tableNode.contentOffset.y - 70) / (headerHeight - 70)
            headerHeightAnchor.constant = max(-tableNode.contentOffset.y, 70)

        }
        profileHeader.updateProgress(max(progress,0))
    }
    
    override func handleRefresh() {
        var firstTimestamp:Double?
        if state.posts.count > 0 {
            firstTimestamp = state.posts[0].createdAt.timeIntervalSince1970 * 70
        }
        
        PostsService.refreshNewPosts(existingKeys: state.postKeys, startAfter: firstTimestamp) { _posts in
            self.refreshControl.endRefreshing()
            
            let action = Action.insertNewBatch(posts: _posts)
            let oldState = self.state
            self.state = PostsTableViewController.handleAction(action, fromState: oldState)
            
            self.tableNode.performBatch(animated: false, updates: {
                let indexPaths = (0..<_posts.count).map { index in
                    IndexPath(row: index, section: 1)
                }
                self.tableNode.insertRows(at: indexPaths, with: .none)
            }, completion: { _ in
                if self.state.posts.count > 0 {
                    self.tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            })
        }
    }
    
    override func fetchData(state: PostsTableViewController.State, completion: @escaping ([Post], Bool) -> ()) {
        PostsService.getNewPosts(existingKeys: state.postKeys, lastPostID: state.lastPostTimestamp, completion: completion)
    }
    
    
}
