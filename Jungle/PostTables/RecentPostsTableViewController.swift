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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let newPostsButton = NewPostsButton(frame: .zero)
        view.addSubview(newPostsButton)
        newPostsTopAnchor = newPostsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: -44)
        newPostsTopAnchor.isActive = true
        newPostsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newPostsButton.button.addTarget(self, action: #selector(startRefreshing), for: .touchUpInside)
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
        toggleNewPosts(visible: false, animated: true)
        var firstTimestamp:Double?
        if state.posts.count > 0 {
            firstTimestamp = state.posts[0].createdAt.timeIntervalSince1970 * 1000
        }
        
        newPostsListener?.remove()
        PostsService.refreshNewPosts(startAfter: firstTimestamp) { _posts in
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
                self.listenForNewPosts()
            })
        }
    }
    
    func listenForNewPosts() {
        newPostsListener?.remove()
        
        let postsRef = firestore.collection("posts")
            .whereField("status", isEqualTo: "active")
            .whereField("parent", isEqualTo: "NONE")
        
        var query:Query
        if state.posts.count > 0 {
            query = postsRef.whereField("createdAt", isGreaterThan: state.posts[0].createdAt.timeIntervalSince1970 * 1000)
                .order(by: "createdAt", descending: true)
                .limit(to: 1)
        } else {
            query = postsRef.order(by: "createdAt", descending: true).limit(to: 1)
        }
        
        newPostsListener = query.addSnapshotListener() { snapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if snapshot!.documents.count > 0 {
                    let firstDoc = snapshot!.documents[0]
                    if let _ = Post.parse(id: firstDoc.documentID, firstDoc.data()) {
                        self.toggleNewPosts(visible: true, animated: true)
                    }
                }
            }
        }
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        
        PostsService.getMyFeedPosts(offset: state.posts.count, completion: completion)
//        PostsService.getRecentPosts(lastPost: state.posts.last) { posts in
//            let isFirstLoad = self.state.isFirstLoad
//            completion(posts)
//            if isFirstLoad {
//                self.listenForNewPosts()
//            }
//        }
    }
}
