//
//  NotificationCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-17.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase

class IconNode:ASDisplayNode {
    var containerNode = ASDisplayNode()
    var imageNode = ASImageNode()
    
    required init(image:UIImage?,insets:UIEdgeInsets, color:UIColor) {
        super.init()
        automaticallyManagesSubnodes = true
        imageNode.image = image
        imageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: UIColor.white) ?? image
        }
        automaticallyManagesSubnodes = true
        containerNode.backgroundColor = color
        containerNode.automaticallyManagesSubnodes = true
        containerNode.layoutSpecBlock = { _, _ in
            return ASInsetLayoutSpec(insets: insets, child: self.imageNode)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: containerNode)
    }
    
    override func didLoad() {
        super.didLoad()
        containerNode.layer.cornerRadius = 12.0
        containerNode.clipsToBounds = true
        view.applyShadow(radius: 4.0, opacity: 0.15, offset: .zero, color: UIColor.black, shouldRasterize: false)
    }
}

class NotificationCellNode:ASCellNode {
    
    var imageNode = ASImageNode()
    var titleNode = ASTextNode()
    var bodyNode = ASTextNode()
    var timeNode = ASTextNode()
    
    var previewNode = ASNetworkImageNode()
    var previewImageNode:IconNode!
    weak var notification:JNotification?
    
    required init (notification:JNotification) {
        super.init()
        self.notification = notification
        backgroundColor = notification.seen ? UIColor.white: hexColor(from: "#dbfff9")
        automaticallyManagesSubnodes = true
        imageNode.layer.cornerRadius = 16.0
        imageNode.clipsToBounds = true
        previewNode.backgroundColor = tertiaryColor
        
        timeNode.attributedText = NSAttributedString(string: notification.timestamp.timeSinceNow(), attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: grayColor
            ])
        
        titleNode.attributedText = NSAttributedString(string: "-", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: UIColor.clear
            ])
        
        bodyNode.attributedText = NSAttributedString(string: "-", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: UIColor.clear
            ])
        
        if let likesNotification = notification as? PostVotesNotification {
            previewImageNode = IconNode(image: UIImage(named:"like"), insets: UIEdgeInsetsMake(1, 1, 1, 1), color: likeColor)
        } else if let replyNotification = notification as? PostReplyNotification {
            previewImageNode = IconNode(image: UIImage(named:"comment"), insets: UIEdgeInsetsMake(2, 1, 1, 1), color: tagColor)
        }
        
        self.notification?.fetchData {
            self.display()
        }
        
    }
    
    func display() {
        guard let notification = self.notification else { return }
        if let postVotesNotification = notification as? PostVotesNotification,
            let post = postVotesNotification.post {
            let name = postVotesNotification.anon.displayName
            let newVotes = postVotesNotification.newVotes - 1
            let others = newVotes > 1 ? "others" : "other"
            let midfix = newVotes > 0 ? " + \(newVotes) \(others)" : ""
            let postType = post.parent == nil ? "post" : "comment"
            let notificationStr = "\(name)\(midfix) liked your \(postType)"
            print("WE GOT ANON: \(postVotesNotification.anon.displayName)")
            let titleStr = NSMutableAttributedString(string: notificationStr)
            titleStr.addAttributes([
                NSAttributedStringKey.font: Fonts.medium(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.gray
                ], range: NSRange(location: 0, length: notificationStr.count))
            
            titleStr.addAttributes([
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: postVotesNotification.anon.color
                ], range: NSRange(location: 0, length: name.count))
            
            if midfix.count > 0 {
                titleStr.addAttributes([
                    NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
                    NSAttributedStringKey.foregroundColor: UIColor.darkGray
                    ], range: NSRange(location: name.count + 3, length: midfix.count - 3))
            }
            titleNode.attributedText = titleStr
            
            bodyNode.maximumNumberOfLines = 3
            
            bodyNode.attributedText = NSAttributedString(string: "\"\(post.text)\"", attributes: [
                NSAttributedStringKey.font: Fonts.regular(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.gray
                ])
            
            FileService.retrieveThumbnail(withKey: post.key) { image, _ in
                self.previewNode.image = image
            }
            
        } else if let replyNotification = notification as? PostReplyNotification,
            let reply = replyNotification.reply,
            let post = replyNotification.post {
            let name = reply.anon.displayName
            var notificationStr:String
            
            let replyToID = replyNotification.replyToID ?? post.key
            
            if replyNotification.mention {
                notificationStr = "\(name) mentioned you:"
            } else {
                notificationStr = "\(name) commented:"
            }
            
            let titleStr = NSMutableAttributedString(string: notificationStr)
            titleStr.addAttributes([
                NSAttributedStringKey.font: Fonts.medium(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.gray
                ], range: NSRange(location: 0, length: notificationStr.count))
            
            titleStr.addAttributes([
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: reply.anon.color
                ], range: NSRange(location: 0, length: name.count))
            titleNode.attributedText = titleStr
            
            bodyNode.maximumNumberOfLines = 2
            let text = reply.text
            bodyNode.attributedText = NSAttributedString(string: "\"\(text)\"", attributes: [
                NSAttributedStringKey.font: Fonts.regular(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.gray
                ])
            
            FileService.retrieveThumbnail(withKey: post.key) { image, _ in
                self.previewNode.image = image
            }
        }
        
    }
    
    override func didLoad() {
        super.didLoad()
        previewNode.view.layer.cornerRadius = 26
        previewNode.view.clipsToBounds = true
        
        //previewImageNode.containerNode.cornerRadius = 12
        //previewImageNode.containerNode.clipsToBounds = true
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        previewNode.style.width = ASDimension(unit: .points, value: 52)
        previewNode.style.height = ASDimension(unit: .points, value: 52)
        
        previewImageNode.style.width = ASDimension(unit: .points, value: 24)
        previewImageNode.style.height = ASDimension(unit: .points, value: 24)
        previewImageNode.style.layoutPosition = CGPoint(x: 52-20, y: 52-20)
        let abs = ASAbsoluteLayoutSpec(children: [previewNode, previewImageNode])
        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.children = [titleNode, bodyNode, timeNode]
        verticalStack.spacing = 4.0
        verticalStack.style.flexGrow = 1.0
        //verticalStack.style.height =  ASDimension(unit: .points, value: 74)
        let inset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 64, 0, 0), child: verticalStack)
        let overlay = ASOverlayLayoutSpec(child: inset, overlay: abs)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(12, 12, 12, 12), child: overlay)
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let notification = self.notification else { return }
        
        if !notification.seen {
            notification.seen = true
            UIView.animate(withDuration: 0.5, delay: 0.75, options: .curveEaseOut, animations: {
                self.backgroundColor = UIColor.white
            }, completion: nil)
            let ref = database.child("users/notifications/\(uid)/\(notification.id)")
            ref.updateChildValues(["seen": true])
        }
    }
    
    func setHighlighted(_ highlighted:Bool) {
        backgroundColor = highlighted ? UIColor(white: 0.92, alpha: 1.0) : UIColor.white
    }
    
}
