//
//  RecentPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-20.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class RecentPostsTableViewController: PostsTableViewController {
    
    
    override func handleRefresh() {
        var firstTimestamp:Double?
        if state.posts.count > 0 {
            firstTimestamp = state.posts[0].createdAt.timeIntervalSince1970 * 1000
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
