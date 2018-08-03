//
//  LikedPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-07-24.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class LikedPostsTableViewController: PostsTableViewController {
    
    override func lightBoxVC() -> LightboxViewController {
        return MyLikesLightboxViewController()
    }
    
    override func handleRefresh() {
        context?.cancelBatchFetching()

        state = .empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            SearchService.likedPosts(offset: self.state.posts.count) { posts in
                let action = PostsStateController.Action.endBatchFetch(posts: posts)
                let oldState = self.state
                self.state = PostsStateController.handleAction(action, fromState: oldState)
                self.tableNode.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.likedPosts(offset: self.state.posts.count) { posts in
            completion(posts)
        }
    }
}
