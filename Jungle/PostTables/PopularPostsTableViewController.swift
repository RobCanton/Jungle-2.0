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
            let post = popularPosts[indexPath.row - 2]
            if let group = GroupsService.groupsDict[post.groupID] {
                let cell = PostCellNode(post: post,
                                        group: group)
                cell.postNode.delegate = self
                cell.selectionStyle = .none
                cell.dividerNode.isHidden = indexPath.row ==  1 + popularPosts.count
                return cell
            }
            return ASCellNode()
            
        } else {
            let cell = PostsTableTitleHeaderNode(title: "NEW POSTS")
            return cell
        }
    }
    
    override func headerCell(didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 1 && indexPath.row < numberOfHeaderCells() - 1 {
            let popularState = PostsStateController.handleAction(.endBatchFetch(posts: popularPosts), fromState: PostsStateController.State.empty)
            
            let controller = PopularLightboxViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.initialIndex = indexPath.row - 2
            controller.state = popularState
            let drawerVC = CommentsDrawerViewController()
            
            drawerVC.interactor = transitionManager.interactor
            let pulleyController = PulleyViewController(contentViewController: controller, drawerViewController: drawerVC)
            pulleyController.view.clipsToBounds = true
            pulleyController.drawerBackgroundVisualEffectView = nil
            pulleyController.backgroundDimmingOpacity = 0.35
            pulleyController.drawerTopInset = UIApplication.edgeToEdgeInsets.top > 0 ? 0 : 24
            pulleyController.hidesBottomBarWhenPushed = true
            pulleyController.transitioningDelegate = transitionManager
            
            if let parentVC = self.parent as? JViewController {
                parentVC.shouldHideStatusBar = true
            }
            self.present(pulleyController, animated: true, completion: nil)
            return
        }
        
        let cell = tableNode.nodeForRow(at: indexPath) as? PostCellNode
        cell?.setHighlighted(true)
    }
    
    override func headerCell(didDeselectRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath) as? PostCellNode
        cell?.setHighlighted(false)
    }
    
    override func headerCell(didHighlightRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath) as? PostCellNode
        cell?.setHighlighted(true)
    }
    
    override func headerCell(didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath) as? PostCellNode
        cell?.setHighlighted(false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableNode.contentInset = .zero
        PostsService.getPopularPosts { posts in
            
            if self.popularPosts.count == 0 {
                self.popularPosts = posts
                if posts.count > 0 {
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
    }
    override func handleRefresh() {
        context?.cancelBatchFetching()
        var firstTimestamp:Double?
        if state.posts.count > 0 {
            firstTimestamp = state.posts[0].createdAt.timeIntervalSince1970 * 1000
        }
        
        
        PostsService.refreshNewPosts(startAfter: firstTimestamp) { _posts in
            self.refreshControl.endRefreshing()
            
            let action = PostsStateController.Action.insertNewBatch(posts: _posts)
            let oldState = self.state
            self.state = PostsStateController.handleAction(action, fromState: oldState)
            
            self.tableNode.performBatch(animated: false, updates: {
                let indexPaths = (0..<_posts.count).map { index in
                    IndexPath(row: index, section: 1)
                }
                self.tableNode.insertRows(at: indexPaths, with: .none)
            }, completion: { _ in
                if self.state.posts.count > 0 {
                    self.tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
                
                SearchService.getTrendingHastags()
            })
        }

        return
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        PostsService.getRecentPosts(lastPost: state.posts.last, completion: completion)
    }
    
    func postOpenTrending(tag: TrendingHashtag) {
        let controller = GroupLightboxViewController()
        let _state = PostsStateController.handleAction(.endBatchFetch(posts: tag.posts), fromState: .empty)
        controller.hidesBottomBarWhenPushed = true
        controller.state = _state
        controller.initialIndex = 0
        controller.groupID = tag.hastag
        
        let drawerVC = CommentsDrawerViewController()
        
        drawerVC.interactor = transitionManager.interactor
        let pulleyController = PulleyViewController(contentViewController: controller, drawerViewController: drawerVC)
        pulleyController.view.clipsToBounds = true
        pulleyController.drawerBackgroundVisualEffectView = nil
        pulleyController.backgroundDimmingOpacity = 0.35
        pulleyController.drawerTopInset = UIApplication.edgeToEdgeInsets.top > 0 ? 0 : 24
        pulleyController.hidesBottomBarWhenPushed = true
        pulleyController.transitioningDelegate = transitionManager
        
        if let parentVC = self.parent as? JViewController {
            parentVC.shouldHideStatusBar = true
        }
        self.present(pulleyController, animated: true, completion: nil)
        return
    }
}
