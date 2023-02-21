//
//  GroupPoststableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class GroupPostsTableViewController: PostsTableViewController {
    
//    override func lightBoxVC() -> LightboxViewController {
//        let vc = UserPostsLightboxViewController()
//        vc.username = username
//        return vc
//    }
    
    var groupID:String
    
    init(groupID:String) {
        self.groupID = groupID
        super.init()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handleRefresh() {
//        context?.cancelBatchFetching()
//
//        state = .empty
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
//            SearchService.groupPosts(groupID: self.groupID, offset: self.state.posts.count) { posts in
//
//                let action = PostsStateController.Action.endBatchFetch(posts: posts)
//                let oldState = self.state
//                self.state = PostsStateController.handleAction(action, fromState: oldState)
//                self.tableNode.reloadData()
//                self.refreshControl.endRefreshing()
//            }
//        })
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.groupPosts(groupID: groupID, offset: state.posts.count) { posts in
            
            completion(posts)
            
        }
    }
}
