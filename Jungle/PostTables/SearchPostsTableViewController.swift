//
//  SearchPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-15.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class SearchPostsTableViewController: PostsTableViewController, PopularHeaderCellProtocol {
    
    var searchText:String?
    func setSearch(text:String?) {
        
        context?.cancelBatchFetching()
        state = .empty
        self.tableNode.reloadData()
        searchText = text
        
    }
    
    override func handleRefresh() {
        context?.cancelBatchFetching()
        
        state = .empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            if let searchText = self.searchText {
                SearchService.searchFor(text: searchText, limit: 15, offset: self.state.posts.count) { posts, endReached in
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
            }
        })
    }
    
    override func fetchData(state: PostsTableViewController.State, completion: @escaping ([Post], Bool) -> ()) {
        if let searchText = searchText {
            SearchService.searchFor(text: searchText, limit: 15, offset: state.posts.count) { posts, endReached in
                
                completion(posts, endReached)
            }
        } else {
            super.fetchData(state: state, completion: completion)
        }
    }
}
