//
//  PostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-21.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase
import Pulley

enum PostsTableType {
    case newest, popular, nearby
}

class PostsTableViewController: ASViewController<ASDisplayNode> {
    
    var state = PostsStateController.State.empty
    
    var tableNode = ASTableNode()
    var refreshControl:UIRefreshControl!
    var context:ASBatchContext?
    var shouldBatchFetch = true
    
    var transitionManager = LightboxTransitionManager()
    var pushTransitionManager = PushTransitionManager()
    
    
    func numberOfHeaderCells() -> Int {
        return 1
    }
    
    func headerCell(for indexPath:IndexPath) -> ASCellNode {
        let cell = ASCellNode()
        cell.style.height = ASDimension(unit: .points, value: 0.0)
        cell.selectionStyle = .none
        return cell
    }
    
    func headerCell(didSelectRowAt indexPath:IndexPath) {}
    func headerCell(didDeselectRowAt indexPath:IndexPath) {}
    func headerCell(didHighlightRowAt indexPath:IndexPath) {}
    func headerCell(didUnhighlightRowAt indexPath:IndexPath) {}
    
    
    func lightBoxVC() -> LightboxViewController {
        return LightboxViewController()
    }
    
    func postCell(for indexPath:IndexPath) -> ASCellNode {
        let cell = PostCellNode(post: state.posts[indexPath.row])
        cell.postNode.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    init() {
        super.init(node: ASDisplayNode())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pushTransitionManager.navBarHeight = 50 + UIApplication.deviceInsets.top
        
        view.addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        tableNode.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        tableNode.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableNode.view.contentInsetAdjustmentBehavior = .never
        tableNode.delegate = self
        tableNode.dataSource = self
        
        tableNode.view.separatorStyle = .none
        tableNode.view.showsVerticalScrollIndicator = true
        tableNode.view.delaysContentTouches = false
        tableNode.view.backgroundColor = hexColor(from: "#EFEFEF")
        tableNode.view.tableFooterView = UIView()
        
        tableNode.reloadData()
        tableNode.clipsToBounds = false
        self.view.clipsToBounds = false
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableNode.view.refreshControl = refreshControl
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        if refreshControl.isRefreshing { return false }
        return shouldBatchFetch
    }
    

    
    
    @objc func handleRefresh() {}
    
    
    func fetchData(state:PostsStateController.State, completion: @escaping (_ posts:[Post])->()) {
        DispatchQueue.main.async {
            return completion([])
        }
    }
}

extension PostsTableViewController: ASTableDelegate, ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        /// This call will come in on a background thread. Switch to main
        /// to add our spinner, then fire off our fetch.
        guard !state.endReached else { return }
        self.context = context
        DispatchQueue.main.async {
            let oldState = self.state
            let action = PostsStateController.Action.beginBatchFetch
            self.state = PostsStateController.handleAction(action, fromState: oldState)
            self.renderDiff(oldState)
        }
        
        fetchData(state: state) { posts in
            
            let action = PostsStateController.Action.endBatchFetch(posts: posts)
            let oldState = self.state
            self.state = PostsStateController.handleAction(action, fromState: oldState)
            self.renderDiff(oldState)
            context.completeBatchFetching(true)
            if self.state.isFirstLoad {
                let oldState = self.state
                self.state = PostsStateController.handleAction(.firstLoadComplete(), fromState: oldState)
            }
        }
    }
    
    fileprivate func renderDiff(_ oldState: PostsStateController.State) {
        
        self.tableNode.performBatchUpdates({
            
            // Add or remove items
            let rowCountChange = state.posts.count - oldState.posts.count
            if rowCountChange > 0 {
                let indexPaths = (oldState.posts.count..<state.posts.count).map { index in
                    IndexPath(row: index, section: 1)
                }
                tableNode.insertRows(at: indexPaths, with: .none)
            } else if rowCountChange < 0 {
                assertionFailure("Deleting rows is not implemented. YAGNI.")
            }
            
            // Add or remove spinner.
            if state.fetchingMore != oldState.fetchingMore {
                if state.fetchingMore {
                    // Add spinner.
                    let spinnerIndexPath = IndexPath(row: state.posts.count, section: 1)
                    tableNode.insertRows(at: [ spinnerIndexPath ], with: .none)
                } else {
                    // Remove spinner.
                    let spinnerIndexPath = IndexPath(row: oldState.posts.count, section: 1)
                    tableNode.deleteRows(at: [ spinnerIndexPath ], with: .none)
                }
            }
        }, completion:nil)
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return numberOfHeaderCells()
        }
        var count = state.posts.count
        if state.fetchingMore {
            count += 1
        }
        return count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if indexPath.section == 0 {
            return headerCell(for: indexPath)
        }
        let rowCount = self.tableNode(tableNode, numberOfRowsInSection: 1)
        
        if state.fetchingMore && indexPath.row == rowCount - 1 {
            let node = LoadingCellNode()
            node.style.height = ASDimensionMake(44.0)
            return node;
        }
        
        return postCell(for:indexPath)
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            headerCell(didSelectRowAt: indexPath)
        } else {
            let node = tableNode.nodeForRow(at: indexPath) as? PostCellNode
            node?.setHighlighted(true)
            
            let post = state.posts[indexPath.row]
            openSinglePost(post, index: indexPath.row)
        }
    }
    
    
    func openSinglePost(_ post:Post, index:Int) {
        
        let controller = lightBoxVC()
        controller.hidesBottomBarWhenPushed = true
        controller.state = self.state
        controller.initialIndex = index
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
    
    func tableNode(_ tableNode: ASTableNode, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            headerCell(didDeselectRowAt: indexPath)
            return
        }
        let node = tableNode.nodeForRow(at: indexPath) as? PostCellNode
        node?.setHighlighted(false)
    }
    
    func tableNode(_ tableNode: ASTableNode, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            headerCell(didHighlightRowAt: indexPath)
            return
        }
        let node = tableNode.nodeForRow(at: indexPath) as? PostCellNode
        node?.setHighlighted(true)
    }
    
    func tableNode(_ tableNode: ASTableNode, didUnhighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            headerCell(didUnhighlightRowAt: indexPath)
            return
        }
        let node = tableNode.nodeForRow(at: indexPath) as? PostCellNode
        node?.setHighlighted(false)
    }
    
}

extension PostsTableViewController: PostCellDelegate {
    func postParentVC() -> UIViewController {
        return self
    }
    
    func postOpen(profile: Profile) {
        let controller = UserProfileViewController()
        controller.profile = profile
        pushTransitionManager.navBarHeight = nil
        controller.interactor = pushTransitionManager.interactor
        controller.transitioningDelegate = pushTransitionManager
        self.present(controller, animated: true, completion: nil)
    }
    
    func postOpen(tag: String) {
        let vc = SearchViewController()
        vc.initialSearch = tag
        
        var navBarHeight:CGFloat?
        if let _ = self.parent as? JViewController {
            navBarHeight = 50 + UIApplication.deviceInsets.top
        }
        pushTransitionManager.navBarHeight = navBarHeight
        vc.interactor = pushTransitionManager.interactor
        vc.transitioningDelegate = pushTransitionManager
        self.present(vc, animated: true, completion: nil)
    }
    
    func postOptions(_ post: Post) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if post.isYourPost {
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                UploadService.deletePost(post) { success in
                    if success {
                        for i in 0..<self.state.posts.count {
                            let arrayPost = self.state.posts[i]
                            if arrayPost.key == post.key {
                                let action = PostsStateController.Action.removePost(at: i)
                                self.state = PostsStateController.handleAction(action, fromState: self.state)
                                let indexPath = IndexPath(row: i, section: 1)
                                
                                self.tableNode.performBatchUpdates({
                                    self.tableNode.deleteRows(at: [indexPath], with: .top)
                                }, completion: { _ in
                                })
                                
                                break
                            }
                        }
                    }
                }
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
                let reportSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let inappropriate = UIAlertAction(title: "It's Inappropriate", style: .destructive, handler: { _ in
                    ReportService.reportPost(post, type: .inappropriate)
                })
                reportSheet.addAction(inappropriate)
                let spam = UIAlertAction(title: "It's Spam", style: .destructive, handler: { _ in
                    ReportService.reportPost(post, type: .spam)
                })
                reportSheet.addAction(spam)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
                reportSheet.addAction(cancel)
                self.present(reportSheet, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
