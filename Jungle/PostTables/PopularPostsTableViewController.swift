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
    
    var popularPosts = [Post]()
    
    override func numberOfHeaderCells() -> Int {
        if popularPosts.count > 0 {
            return popularPosts.count + 2 + 1
        }
        return 2
    }
    
    override func headerCell(for indexPath: IndexPath) -> ASCellNode {
        if indexPath.row == 0 {
            let cell = PopularPostsHeaderCellNode()
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        } else if popularPosts.count > 0 {
            if indexPath.row == 1 {
                let cell = PostsTableTitleHeaderNode(title: "TRENDING POSTS")
                return cell
            }
            let cell = PostCellNode(post: popularPosts[indexPath.row - 2])
            cell.postNode.delegate = self
            cell.selectionStyle = .none
            cell.dividerNode.isHidden = indexPath.row ==  1 + popularPosts.count
            return cell
        } else {
            let cell = PostsTableTitleHeaderNode(title: "NEW POSTS")
            return cell
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableNode.contentInset = .zero
        PostsService.getPopularPosts(offset: 0) { posts in
            
            if self.popularPosts.count == 0 {
                self.popularPosts = posts
                
                var paths = [IndexPath]()
                for i in 0..<posts.count + 1 {
                    paths.append(IndexPath(row: i + 1, section: 0))
                }
                self.tableNode.performBatchUpdates({
                    self.tableNode.insertRows(at: paths, with: .automatic)
                }, completion: nil)
            }
        }
    }
    override func handleRefresh() {
        context?.cancelBatchFetching()

        state = .empty
        SearchService.getTrendingHastags()
//        PostsService.getPopularPosts(offset: state.posts.count) { posts in
//
//            let action = PostsStateController.Action.endBatchFetch(posts: posts)
//            let oldState = self.state
//            self.state = PostsStateController.handleAction(action, fromState: oldState)
//            self.tableNode.reloadData()
//            self.refreshControl.endRefreshing()
//        }

        return
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        PostsService.getRecentPosts(lastPost: state.posts.last, completion: completion)
    }
    
    func postOpenTrending(tag: TrendingHashtag) {
        let controller = SearchLightboxViewController()
        
        controller.hidesBottomBarWhenPushed = true
        controller.initialIndex = 0
        controller.initialSearch = "#\(tag.hastag)"
        controller.initialPosts = tag.posts
        
        let drawerVC = CommentsDrawerViewController()
        
        drawerVC.interactor = transitionManager.interactor
        let pulleyController = PulleyViewController(contentViewController: controller, drawerViewController: drawerVC)
        pulleyController.view.clipsToBounds = true
        pulleyController.drawerBackgroundVisualEffectView = nil
        pulleyController.backgroundDimmingOpacity = 0.35
        pulleyController.drawerTopInset = 24
        pulleyController.hidesBottomBarWhenPushed = true
        pulleyController.transitioningDelegate = transitionManager
        
        if let parentVC = self.parent as? JViewController {
            parentVC.shouldHideStatusBar = true
        }
        self.present(pulleyController, animated: true, completion: nil)
        return
    }
}
