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
    
    override func lightBoxVC() -> LightboxViewController {
        return RecentLightboxViewController()
    }
    
    override func handleRefresh() {
        var firstTimestamp:Double?
        if state.posts.count > 0 {
            firstTimestamp = state.posts[0].createdAt.timeIntervalSince1970 * 1000
        }
        
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
            })
        }
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        PostsService.getRecentPosts(lastPost: state.posts.last , completion: completion)
    }
}
