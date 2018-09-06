//
//  NotificationsViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-04-15.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase
import Pulley
import Differ

class NotificationsViewController:JViewController, ASTableDelegate, ASTableDataSource, NotificationObserverDelegate {
    
    var tableNode:ASTableNode!
    var newNotifications = [JNotification]()
    var notifications = [JNotification]()
    var titleView:JTitleView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return .lightContent }
    }
    
    var transitionManager = LightboxTransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topInset = UIApplication.deviceInsets.top
        let titleViewHeight = 50 + topInset
        
        titleView = JTitleView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: titleViewHeight), topInset: topInset)
        view.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: titleViewHeight).isActive = true
        
        titleView.titleLabel.text = "NOTIFICATIONS"
        
        tableNode = ASTableNode()
        view.addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutGuide = view.safeAreaLayoutGuide
        tableNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        tableNode.view.contentInsetAdjustmentBehavior = .never
        tableNode.view.tableHeaderView = UIView()
        tableNode.view.tableFooterView = UIView()
        tableNode.view.separatorColor = currentTheme.highlightedBackgroundColor
        tableNode.view.backgroundColor = hexColor(from: "#EFEFEF")
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.leadingScreensForBatching = 1.5
        tableNode.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        calculateAndRenderDiffs()
        nService.delegate = self
        
    }
    
    func calculateAndRenderDiffs() {
        var insertions = [IndexPath]()
        var deletions = [IndexPath]()
        
        let newDiff = newNotifications.diff(nService.state.newNotifications)
        
        let newElements = newDiff.elements
        
        for element in newElements {
            switch element {
            case let .insert(i):
                insertions.append(IndexPath(row: i, section:0))
                break
            case let .delete(i):
                deletions.append(IndexPath(row: i, section:0))
                break
            }
        }
        
        let diff = notifications.diff(nService.state.notifications)
        
        let elements = diff.elements
        
        for element in elements {
            switch element {
            case let .insert(i):
                insertions.append(IndexPath(row: i, section:1))
                break
            case let .delete(i):
                deletions.append(IndexPath(row: i, section:1))
                break
            }
        }
        
        newNotifications = nService.state.newNotifications
        notifications = nService.state.notifications
        
        tableNode.performBatchUpdates({
            self.tableNode.insertRows(at: insertions, with: .automatic)
            self.tableNode.deleteRows(at: deletions, with: .automatic)
        }, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        nService.delegate = nil
        if let notificationCellNodes = tableNode.visibleNodes as? [NotificationCellNode] {
            for node in notificationCellNodes {
                node.setHighlighted(false)
            }
        }
    }
    
    func newNotificationRecieved() {
        calculateAndRenderDiffs()
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        guard !nService.state.fetchingMore, !nService.state.endReached else { return }
        
        let oldState = nService.state
        nService.state = NotificationObserver.handleAction(.beginBatchFetch, fromState: oldState)
        
        nService.fetchData { notifications, endReached in
            
            let oldState = nService.state
            nService.state = NotificationObserver.handleAction(.appendBatch(notifications: notifications), fromState: oldState)
            self.notifications = nService.state.notifications
            self.renderDiff()
            context.completeBatchFetching(true)
        }
    }
    
    fileprivate func renderDiff() {
        tableNode.reloadData()
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return newNotifications.count
        }
        return notifications.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if indexPath.section == 0 {
             let cell = NotificationCellNode(notification: newNotifications[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = NotificationCellNode(notification: notifications[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath) as? NotificationCellNode
        cell?.setHighlighted(true)
        
        var post:Post?
        
        var notification:JNotification
        if indexPath.section == 0 {
            notification = newNotifications[indexPath.row]
        } else {
            notification = notifications[indexPath.row]
        }
        
        if let replyNotification = notification as? PostReplyNotification {
            post = replyNotification.post
        } else if let likeNotification = notification as? PostVotesNotification {
            post = likeNotification.post
        }
        if let post = post {
            let controller = LightboxViewController()
            controller.hidesBottomBarWhenPushed = true
            let state = PostsStateController.handleAction(.endBatchFetch(posts: [post]), fromState: .empty)
            controller.state = state
            controller.initialIndex = 0
            let drawerVC = CommentsDrawerViewController()
            drawerVC.currentPost = post
            drawerVC.showComments = true
            drawerVC.interactor = transitionManager.interactor
            let pulleyController = PulleyViewController(contentViewController: controller, drawerViewController: drawerVC)
            
            pulleyController.drawerBackgroundVisualEffectView = nil
            pulleyController.backgroundDimmingOpacity = 0.35
            pulleyController.drawerTopInset = 24
            pulleyController.hidesBottomBarWhenPushed = true
            
            pulleyController.transitioningDelegate = transitionManager
            self.shouldHideStatusBar = true
            self.present(pulleyController, animated: true, completion: nil)
            return
        }

    }
    
    func tableNode(_ tableNode: ASTableNode, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath) as? NotificationCellNode
        cell?.setHighlighted(false)
    }
    
    func tableNode(_ tableNode: ASTableNode, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath) as? NotificationCellNode
        cell?.setHighlighted(true)
    }
    
    func tableNode(_ tableNode: ASTableNode, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath) as? NotificationCellNode
        cell?.setHighlighted(false)
    }
}
