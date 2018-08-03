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
import Pulley

class PopularPostsTableViewController: PostsTableViewController, PopularHeaderCellProtocol {
 
    override func lightBoxVC() -> LightboxViewController {
        return PopularLightboxViewController()
    }
    
    override var headerCell: ASCellNode? {
        let cell = PopularPostsHeaderCellNode()
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.contentInset = .zero
    }
    override func handleRefresh() {
        context?.cancelBatchFetching()

        state = .empty
        PostsService.getPopularPosts(offset: state.posts.count) { posts in

            let action = PostsStateController.Action.endBatchFetch(posts: posts)
            let oldState = self.state
            self.state = PostsStateController.handleAction(action, fromState: oldState)
            self.tableNode.reloadData()
            self.refreshControl.endRefreshing()

        }

        return
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        PostsService.getPopularPosts(offset: state.posts.count, completion: completion)
    }
    
    func postOpenTrending(tag: TrendingHashtag) {
        let controller = SearchLightboxViewController()
        
        controller.hidesBottomBarWhenPushed = true
        controller.initialIndex = 0
        controller.initialSearch = "#\(tag.hastag)"
        controller.initialPost = tag.post
        
        let drawerVC = CommentsDrawerViewController()
        
        drawerVC.interactor = transitionManager.interactor
        let pulleyController = PulleyViewController(contentViewController: controller, drawerViewController: drawerVC)
        pulleyController.view.clipsToBounds = true
        pulleyController.drawerBackgroundVisualEffectView = nil
        pulleyController.backgroundDimmingOpacity = 0.35
        pulleyController.topInset = 24
        pulleyController.hidesBottomBarWhenPushed = true
        pulleyController.transitioningDelegate = transitionManager
        
        if let parentVC = self.parent as? JViewController {
            parentVC.shouldHideStatusBar = true
        }
        self.present(pulleyController, animated: true, completion: nil)
        return
    }
}
