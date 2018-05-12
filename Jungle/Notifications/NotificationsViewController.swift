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

class NotificationsViewController:UIViewController, ASTableDelegate, ASTableDataSource {
    
    var notifications = [JNotification]()
    var tableNode:ASTableNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44.0))
        label.font = Fonts.semiBold(ofSize: 16.0)
        label.text = "Notifications"
        label.textAlignment = .center
        navigationItem.titleView = label
        
        tableNode = ASTableNode()
        view.addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutGuide = view.safeAreaLayoutGuide
        tableNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        tableNode.view.contentInsetAdjustmentBehavior = .never
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.reloadData()
        getNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func getNotifications() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
       print("WTH IS THIS?")
        let ref = firestore.collection("notifications").whereField("uid", isEqualTo: uid)
        let query = ref.order(by: "timestamp", descending: true).limit(to: 12)
        query.getDocuments { snapshot, error in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            var _notifications = [JNotification]()
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    if let notification = JNotification.parse(document.data()) {
                        _notifications.insert(notification, at: 0)
                    }
                }
            }
            
            var count = 0
            for notification in _notifications {
                notification.fetchData {
                    count += 1
                    if count >= _notifications.count {
                        self.notifications = _notifications
                        self.tableNode.reloadData()
                    }
                }
            }
        }
    }
    
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = NotificationCellNode(notification: notifications[indexPath.row])
        return cell
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        if let postVotesNotification = notifications[indexPath.row] as? PostVotesNotification,
            let post = postVotesNotification.post {
            let controller = SinglePostViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.post = post
            self.navigationController?.pushViewController(controller, animated: true)
        } else if let postReplyNotification = notifications[indexPath.row] as? PostReplyNotification,
            let post = postReplyNotification.post {
            let controller = SinglePostViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.post = post
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
}


class NotificationCellNode:ASCellNode {
    
    var imageNode = ASImageNode()
    var titleNode = ASTextNode()
    var bodyNode = ASTextNode()
    var timeNode = ASTextNode()
    
    required init (notification:JNotification) {
        super.init()
        automaticallyManagesSubnodes = true
        imageNode.layer.cornerRadius = 16.0
        imageNode.clipsToBounds = true
        
        timeNode.attributedText = NSAttributedString(string: notification.timestamp.timeSinceNow(), attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: grayColor
            ])
        
        if let postVotesNotification = notification as? PostVotesNotification {
            var votesStr = ""
            if postVotesNotification.newVotes == 1 {
                votesStr = "1 new vote"
            } else {
                votesStr = "\(postVotesNotification.newVotes) new votes"
            }
            let votesStrLength = votesStr.utf16.count
            let prefix = "Your post has "
            let prefixLength = prefix.utf16.count
            let notificationStr = "\(prefix)\(votesStr)"
            let str = "\(notificationStr)"
            
            let titleAttr = NSMutableAttributedString(string: str)
            titleAttr.addAttributes([
                NSAttributedStringKey.font: Fonts.medium(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.black
                ], range: NSRange(location: 0, length: prefixLength))
            
            titleAttr.addAttributes([
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.black
                ], range: NSRange(location: prefixLength, length: votesStrLength))
            
            titleNode.attributedText = titleAttr
            
            
            var bodyStr = "[Error loading post]"
            if let post = postVotesNotification.post {
                bodyStr = "\"\(post.text)\""
                imageNode.backgroundColor = post.anon.color
            }
            bodyNode.maximumNumberOfLines = 3
            bodyNode.attributedText = NSAttributedString(string: bodyStr, attributes: [
                NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: grayColor
                ])
            
        } else if let postReplyNotification = notification as? PostReplyNotification,
            let reply = postReplyNotification.reply {
            let name = reply.anon.displayName
            let notificationStr = "\(name) replied to your post:"
            let notificationStrLength = notificationStr.utf16.count
            
            let nameLength = name.utf16.count
            
            let titleAttr = NSMutableAttributedString(string: notificationStr)
            titleAttr.addAttributes([
                NSAttributedStringKey.font: Fonts.medium(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.black
                ], range: NSRange(location: 0, length: notificationStrLength))
            
            titleAttr.addAttributes([
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.black
                ], range: NSRange(location: 0, length: nameLength))
            
            titleNode.attributedText = titleAttr
            
            let bodyStr = "\"\(reply.textClean)\""
            imageNode.backgroundColor = reply.anon.color
            
            bodyNode.maximumNumberOfLines = 3
            bodyNode.attributedText = NSAttributedString(string: bodyStr, attributes: [
                NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: grayColor
                ])
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.style.width = ASDimension(unit: .points, value: 32.0)
        imageNode.style.height = ASDimension(unit: .points, value: 32.0)
        
        imageNode.style.layoutPosition = CGPoint(x: 12.0, y: 12.0)
        
        let imageAbs = ASAbsoluteLayoutSpec(children: [imageNode])
        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.children = [titleNode, bodyNode, timeNode]
        verticalStack.spacing = 4.0
        let inset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(12.0, 56.0, 12.0, 12.0), child: verticalStack)
        
        return ASOverlayLayoutSpec(child: inset, overlay: imageAbs)
    }
    
    
}
