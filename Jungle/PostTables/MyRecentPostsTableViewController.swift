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
    
    override func lightBoxVC() -> LightboxViewController {
        return MyPostsLightboxViewController()
    }
    
    override func handleRefresh() {
        context?.cancelBatchFetching()
        
        state = .empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            SearchService.myPosts(offset: self.state.posts.count) { posts in

                let action = PostsStateController.Action.endBatchFetch(posts: posts)
                let oldState = self.state
                self.state = PostsStateController.handleAction(action, fromState: oldState)
                self.tableNode.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.myPosts(offset: state.posts.count) { posts in
            completion(posts)
        }
    }
}
