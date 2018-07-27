//
//  PopularPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-20.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class PopularPostsTableViewController: PostsTableViewController, PopularHeaderCellProtocol {
 
    override var headerCell: ASCellNode? {
        let cell = PopularPostsHeaderCellNode()
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    override func handleRefresh() {
        context?.cancelBatchFetching()

        state = .empty
        PostsService.getPopularPosts(existingKeys: state.postKeys, offset: state.posts.count) { posts, endReached in

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

        return
    }
    
    override func fetchData(state: PostsTableViewController.State, completion: @escaping ([Post], Bool) -> ()) {
        PostsService.getPopularPosts(existingKeys: state.postKeys, offset: state.posts.count, completion: completion)
    }
}
