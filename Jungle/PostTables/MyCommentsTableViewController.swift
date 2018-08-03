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
    
    override func lightBoxVC() -> LightboxViewController {
        return MyCommentsLightboxViewController()
    }
    
    override func postCell(_ post: Post) -> ASCellNode {
        let cell = super.postCell(post) as! PostCellNode
        cell.postNode.commentButton.isHidden = true
        return cell
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let commentCellNodes = tableNode.visibleNodes as? [PostCommentCellNode] {
            for node in commentCellNodes {
                node.setHighlighted(false)
            }
        }
    }
    
    override func handleRefresh() {
        context?.cancelBatchFetching()
        
        state = .empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            SearchService.myComments(offset: self.state.posts.count) { posts in
                
                let action = PostsStateController.Action.endBatchFetch(posts: posts)
                let oldState = self.state
                self.state = PostsStateController.handleAction(action, fromState: oldState)
                self.tableNode.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.myComments(offset: state.posts.count) { posts in
            completion(posts)
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
            let state = PostsStateController.handleAction(.endBatchFetch(posts: [parentPost]), fromState: .empty)
            controller.state = state
            controller.initialIndex = 0
            let drawerVC = CommentsDrawerViewController()
            drawerVC.currentPost = parentPost
            drawerVC.showComments = true
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
