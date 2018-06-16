//
//  NearbyPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-20.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class NearbyPostsTableViewController: PostsTableViewController {
    
    var proximity:UInt = 0
    
    override var headerCell: ASCellNode? {
        get {
            let cell = NearbyHeaderCellNode()
            cell.delegate = self
            return cell
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.contentInset = .zero
    }
    
    override func handleRefresh() {
        
    }
    
    override func fetchData(state: PostsTableViewController.State, completion: @escaping ([Post], Bool) -> ()) {
        SearchService.searchNearby(proximity: proximity, offset: state.posts.count, completion: completion)
    }
}

extension NearbyPostsTableViewController: DistanceSliderDelegate {
    func proximityChanged(_ proximity: UInt) {
        self.proximity = proximity
        context?.cancelBatchFetching()

        state = .empty
        shouldBatchFetch = false
        
        self.tableNode.performBatch(animated: false, updates: {
            self.tableNode.reloadSections(IndexSet([1]), with: .none)
        }, completion: { _ in
            self.shouldBatchFetch = true
//            SearchService.searchNearby(proximity: proximity, offset: self.state.posts.count) {
//                posts, endReached in
//                if endReached {
//                    let oldState = self.state
//                    self.state = PostsTableViewController.handleAction(.endReached(), fromState: oldState)
//                }
//                let action = Action.endBatchFetch(posts: posts)
//                let oldState = self.state
//                self.state = PostsTableViewController.handleAction(action, fromState: oldState)
//                self.tableNode.reloadSections(IndexSet([1]), with: .none)
//                self.shouldBatchFetch = true
//                self.refreshControl.endRefreshing()
//            }
        })
    }
}
