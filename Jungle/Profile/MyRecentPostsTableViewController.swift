//
//  MyPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-20.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class MyPostsTableViewController: PostsTableViewController {
    
    override func handleRefresh() {
        context?.cancelBatchFetching()
        
        state = .empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            SearchService.myPosts(offset: self.state.posts.count) { posts, endReached in
                if endReached {
                    let oldState = self.state
                    self.state = PostsTableViewController.handleAction(.endReached(), fromState: oldState)
                }
                let action = Action.endBatchFetch(posts: posts)
                let oldState = self.state
                self.state = PostsTableViewController.handleAction(action, fromState: oldState)
                self.tableNode.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    override func fetchData(state: PostsTableViewController.State, completion: @escaping ([Post], Bool) -> ()) {
        SearchService.myPosts(offset: state.posts.count) { posts, endReached in
            completion(posts, endReached)
        }
    }
}
