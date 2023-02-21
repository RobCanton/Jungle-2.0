//
//  RecentPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-20.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import AsyncDisplayKit

class RecentPostsTableViewController: PostsTableViewController {
    
    var newPostsTopAnchor:NSLayoutConstraint!
    var newPostsListener:ListenerRegistration?
    
    var openDiscoverGroupsHandler:(()->())?
    
    override func headerCell(for indexPath: IndexPath) -> ASCellNode {
        let cell = NoticeCellNode(msg: "You aren't part of any groups!\nJoin a group to start seeing posts in your feed.",
                                  buttonTitle: "Discover Groups")
        cell.handleTap = openDiscoverGroups
        let height = UIScreen.main.bounds.height - 49 - 70
        cell.style.height = ASDimension(unit: .points, value: height)
        cell.selectionStyle = .none
        return cell
    }
    
    func openDiscoverGroups() {
        print("openDiscoverGroups")
        openDiscoverGroupsHandler?()
    }

    
    override func numberOfHeaderCells() -> Int {
        return GroupsService.myGroupKeys.count == 0 ? 1 : 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let newPostsButton = NewPostsButton(frame: .zero)
        view.addSubview(newPostsButton)
        newPostsTopAnchor = newPostsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: -44)
        newPostsTopAnchor.isActive = true
        newPostsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newPostsButton.button.addTarget(self, action: #selector(startRefreshing), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserService.shouldPoll {
            startPoll()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pollTimer?.invalidate()
        pollTimer = nil
    }
    
    override func lightBoxVC() -> LightboxViewController {
        return RecentLightboxViewController()
    }
    
    func toggleNewPosts(visible:Bool, animated:Bool) {
        if visible {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                self.newPostsTopAnchor.constant = 12
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.75, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                self.newPostsTopAnchor.constant = -44
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    
    
    @objc func startRefreshing() {
        
        refreshControl.beginRefreshing()
        tableNode.setContentOffset(CGPoint(x: 0, y: -56), animated: true)
        toggleNewPosts(visible: false, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.handleRefresh()
        })
        
    }
    
    override func handleRefresh() {
        if GroupsService.myGroupKeys.count == 0 { return }
        toggleNewPosts(visible: false, animated: true)
        var firstTimestamp:Double?
        if state.posts.count > 0 {
            firstTimestamp = state.posts[0].createdAt.timeIntervalSince1970 * 1000
        }
        pollTimer?.invalidate()
        pollTimer = nil
        PostsService.getMyFeedPosts(offset: state.posts.count, before: firstTimestamp) { _posts in
            self.refreshControl.endRefreshing()

            let action = PostsStateController.Action.insertNewBatch(posts: _posts)
            let oldState = self.state
            self.state = PostsStateController.handleAction(action, fromState: oldState)

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
    
    var pollTimer:Timer?
    var pollTicks = 0
    var pollInterval:Double = 1
    
    func startPoll() {
        pollInterval = 1
        UserService.shouldPoll = false
        
        pollTimer?.invalidate()
        pollTimer = nil
        
        pollTimer = Timer.scheduledTimer(timeInterval: pollInterval, target: self, selector: #selector(pollMyFeed), userInfo: nil, repeats: false)
        
    }
    
    @objc func pollMyFeed() {
        var before:Double?
        if let first = state.posts.first {
            before = first.createdAt.timeIntervalSince1970 * 1000
        }
        
        PostsService.pollMyFeedPosts(before: before) { posts in
            if posts.count > 0 {
                self.pollTicks = 0
                self.pollInterval = 1
                if !self.state.fetchingMore, !self.refreshControl.isRefreshing {
                    self.toggleNewPosts(visible: true, animated: true)
                }
            } else {
                self.pollNextTick()
            }
        }

    }
    
    func pollNextTick() {
        if pollTicks < 10 {
        pollTicks += 1
        pollInterval += 1
        pollTimer = Timer.scheduledTimer(timeInterval: pollInterval, target: self, selector: #selector(pollMyFeed), userInfo: nil, repeats: false)
        }
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        
        PostsService.getMyFeedPosts(offset: state.posts.count, before: nil, completion: completion)
    }
}
