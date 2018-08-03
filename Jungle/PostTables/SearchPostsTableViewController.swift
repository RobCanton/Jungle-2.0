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

class SearchPostsTableViewController: PostsTableViewController {
    
    var type:SearchType = .popular
    var searchText:String?
    
    override func lightBoxVC() -> LightboxViewController {
        let lightbox = SearchLightboxViewController()
        lightbox.type = type
        lightbox.searchText = searchText
        return lightbox
    }
    
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
                SearchService.searchFor(text: searchText, type: self.type, limit: 15, offset: self.state.posts.count) { posts in
                    
                    let action = PostsStateController.Action.endBatchFetch(posts: posts)
                    let oldState = self.state
                    self.state = PostsStateController.handleAction(action, fromState: oldState)
                    self.tableNode.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        })
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        if let searchText = searchText {
            SearchService.searchFor(text: searchText, type: type, limit: 15, offset: state.posts.count) { posts in
                
                completion(posts)
            }
        } else {
            super.fetchData(state: state, completion: completion)
        }
    }
}
