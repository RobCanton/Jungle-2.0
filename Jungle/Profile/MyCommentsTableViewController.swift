//
//  MyCommentsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-07-23.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Pulley

class MyCommentsTableViewController: PostsTableViewController {
    
    override func postCell(_ post: Post) -> ASCellNode {
        let cell = PostCommentCellNode(post: post, parentPost: post.parentPost!)
        cell.subnameNode.isHidden = true
        cell.selectionStyle = .none
        cell.dividerNode.isHidden = true
        return cell
    }
    
    override func handleRefresh() {
        context?.cancelBatchFetching()
        
        state = .empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            SearchService.myComments(offset: self.state.posts.count) { posts, endReached in
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
        })
    }
    
    override func fetchData(state: PostsTableViewController.State, completion: @escaping ([Post], Bool) -> ()) {
        SearchService.myComments(offset: state.posts.count) { posts, endReached in
            completion(posts, endReached)
        }
    }
    
    override func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        let node = tableNode.nodeForRow(at: indexPath) as? PostCommentCellNode
        node?.setHighlighted(true)
        
        if let parentPost = state.posts[indexPath.row].parentPost {
            let controller = LightboxViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.posts = [parentPost]
            controller.initialIndex = 0
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
}
