//
//  UserPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-08-14.
//  Copyright © 2018 Robert Canton. All rights reserved.
//


import Foundation
import UIKit

class UserPostsTableViewController: PostsTableViewController {
    
    override func lightBoxVC() -> LightboxViewController {
        let vc = UserPostsLightboxViewController()
        vc.username = username
        return vc
    }

    var username:String
    
    init(username:String) {
        self.username = username
        super.init()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handleRefresh() {
        context?.cancelBatchFetching()
        
        state = .empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            SearchService.userPosts(username: self.username, offset: self.state.posts.count) { posts in
                
                let action = PostsStateController.Action.endBatchFetch(posts: posts)
                let oldState = self.state
                self.state = PostsStateController.handleAction(action, fromState: oldState)
                self.tableNode.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.userPosts(username: username, offset: state.posts.count) { posts in
            completion(posts)
        }
    }
}
