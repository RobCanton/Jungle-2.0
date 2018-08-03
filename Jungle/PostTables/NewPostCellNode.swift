//
//  NewPostCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase
import SwiftGifOrigin
import PINRemoteImage

var imageCache = NSCache<NSString, UIImage>()
class PreviewNode:ASDisplayNode {
    var imageNode = ASNetworkImageNode()
    var blurNode:BlurNode?
    var iconNode:ASImageNode?
    var shouldBlock = false
    required init(block:Bool?=nil) {
        super.init()
        shouldBlock = block ?? false
        if shouldBlock {
            blurNode = BlurNode(effect: UIBlurEffectStyle.extraLight)
            iconNode = ASImageNode()
            iconNode?.image = UIImage(named:"danger")
        }
        
    
        automaticallyManagesSubnodes = true
        //self.cornerRadius = 4.0
        self.clipsToBounds = true
        //self.imageNode.shouldCacheImage = true
        self.imageNode.backgroundColor = currentTheme.highlightedBackgroundColor
    }
    
    override func didLoad() {
        super.didLoad()
        self.imageNode.cornerRadius = 4.0
        self.imageNode.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        if blurNode != nil, iconNode != nil {
            let iconCenterXY = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: iconNode!)
            let iconOverlay = ASOverlayLayoutSpec(child: blurNode!, overlay: iconCenterXY)
            return ASOverlayLayoutSpec(child: imageNode, overlay: iconOverlay)
        } else {
            return ASInsetLayoutSpec(insets: .zero, child: imageNode)
        }
    }
    
}

class PostCellNode:ASCellNode {
    var contentNode:ASDisplayNode!
    var postNode:PostNode!
    
    required init(post:Post) {
        super.init()
        
        contentNode = ASDisplayNode()
        postNode = PostNode(post: post)
        automaticallyManagesSubnodes = true
        contentNode.automaticallyManagesSubnodes = true
        contentNode.layoutSpecBlock = { _,_ in
            return ASInsetLayoutSpec(insets: .zero, child: self.postNode)
        }
        
    }
    
    override func didLoad() {
        super.didLoad()
        postNode.layer.cornerRadius = 6.0
        postNode.clipsToBounds = true
        //postNode.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        //postNode.layer.borderWidth = 0.5
        contentNode.view.applyShadow(radius: 4.0, opacity: 0.125, offset: CGSize(width:0, height: 2), color: .black, shouldRasterize: false)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 10, 12, 10), child: contentNode)
    }

}

class PostNode:ASDisplayNode {
    
    var avatarNode = ASDisplayNode()
    var avatarImageNode = ASImageNode()
    var previewNode:PreviewNode!
    var titleNode = ASTextNode()
    var subnameNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var postTextNode = ActiveTextNode()
    var timeNode = ASTextNode()
    var moreButton = ASButtonNode()
    
    var likeButton = ASButtonNode()
    var commentButton = ASButtonNode()
    
    var post:Post?
    var shouldStopObserving = true
    
    weak var delegate:PostCellDelegate?
    
    required init(post:Post) {
        super.init()
        self.post = post
        self.backgroundColor = currentTheme.backgroundColor//hexColor(from: "#333742")
        automaticallyManagesSubnodes = true
        
        postTextNode.maximumNumberOfLines = 4
        postTextNode.tapHandler = { type, value in
            switch type {
            case .hashtag:
                self.delegate?.postOpen(tag: value)
                break
            case .mention:
                break
            case .link:
                break
            }
        }
        
        likeButton.setImage(UIImage(named:"like"), for: .normal)
        likeButton.laysOutHorizontally = true
        likeButton.contentSpacing = 1.0
        likeButton.contentHorizontalAlignment = .middle
        likeButton.contentEdgeInsets = .zero
        likeButton.imageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: currentTheme.secondaryTextColor)
        }
        
        let likeTitle = NSMutableAttributedString(string: numericShorthand(post.numLikes), attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
            ])
        likeButton.setAttributedTitle(likeTitle, for: .normal)
        
        commentButton.laysOutHorizontally = true
        commentButton.setImage(UIImage(named:"comment_small"), for: .normal)
        commentButton.contentSpacing = 1.0
        commentButton.contentHorizontalAlignment = .middle
        let commentTitle = NSMutableAttributedString(string: numericShorthand(post.numReplies), attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
            ])
        commentButton.setAttributedTitle(commentTitle, for: .normal)
        commentButton.imageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: currentTheme.secondaryTextColor)
        }
        
        moreButton.setImage(UIImage(named:"more"), for: .normal)
        moreButton.addTarget(self, action: #selector(handleMore), forControlEvents: .touchUpInside)
        moreButton.imageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: currentTheme.secondaryTextColor.withAlphaComponent(0.5))
        }
        //moreButton.isHidden = true
        avatarNode.backgroundColor = post.anon.color.withAlphaComponent(0.30)
        avatarImageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: post.anon.color) ?? image
        }
        avatarNode.style.height = ASDimension(unit: .points, value: 32)
        avatarNode.style.width = ASDimension(unit: .points, value: 32)
        
        titleNode.attributedText = NSAttributedString(string: post.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: post.anon.color
            ])
        
        var subnameStr = ""
        if post.isYou {
            subnameStr = "YOU"
            subnameNode.isHidden = false
        }else {
            subnameNode.isHidden = true
        }
        
        subnameNode.attributedText = NSAttributedString(string: subnameStr, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 9.0),
            NSAttributedStringKey.foregroundColor: currentTheme.backgroundColor
            ])
        subnameNode.textContainerInset = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 0, right: 4.0)
        subnameNode.backgroundColor = post.anon.color
        
        timeNode.attributedText = NSAttributedString(string: post.createdAt.timeSinceNow(), attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
            ])
        
        var locationStr = ""
        if let location = post.location {
            locationStr = " • \(location.locationShortStr)"
        }
        
        let subtitleStr = "\(post.createdAt.timeSinceNow())\(locationStr)"
        
        subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
            ])
        
        avatarImageNode.image = nil
        UserService.retrieveAnonImage(withName: post.anon.animal.lowercased()) { image, fromFile in
            self.avatarImageNode.image = image
        }
        
        if let blockedMessage = post.blockedMessage {
            previewNode = PreviewNode(block: true)
            postTextNode.attributedText = NSAttributedString(string: blockedMessage, attributes: [
                NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
                ])
            
        } else {
            previewNode = PreviewNode()
            postTextNode.setText(text: post.text, withSize: 14.0,
                                 normalColor: currentTheme.primaryTextColor, activeColor: currentTheme.secondaryAccentColor)
        }
        
        previewNode.style.height = ASDimension(unit: .points, value: 144)
        self.previewNode.imageNode.shouldCacheImage = true
        
        if post.attachments.isVideo {
            let thumbnailRef = storage.child("publicPosts/\(post.key)/thumbnail.gif")
            print("IS VIDEO MAN!")
            thumbnailRef.downloadURL { url, error in
                print("PREVIEW TINGS!")
                self.previewNode.imageNode.url = url
            }
        } else if post.attachments.isImage {
            print("IS IMAGE MAN!")
            let thumbnailRef = storage.child("publicPosts/\(post.key)/thumbnail.jpg")
            thumbnailRef.downloadURL { url, error in
                self.previewNode.imageNode.url = url
            }
        }
        
    }
    
    override func didLoad() {
        super.didLoad()
        avatarNode.layer.cornerRadius = 16
        avatarNode.clipsToBounds = true
        subnameNode.layer.cornerRadius = 2.0
        subnameNode.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let ss = ASStackLayoutSpec.horizontal()
        ss.children = [likeButton, commentButton]
        ss.spacing = 16.0
        
        let actionStack = ASStackLayoutSpec.horizontal()
        actionStack.children = [ss, moreButton]
        actionStack.spacing = 0.0
        actionStack.alignContent = .spaceBetween
        actionStack.justifyContent = .spaceBetween
        
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.children = [titleNode, subnameNode]
        titleStack.spacing = 4.0
        
        let headerStack = ASStackLayoutSpec.vertical()
        headerStack.children = [titleStack, subtitleNode]
        headerStack.spacing = 1.0
        
        postTextNode.style.flexGrow = 1.0
        let headerInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 40, 0, 0), child: headerStack)
        
        let avatarInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(5, 5, 5, 5), child: avatarImageNode)
        let avatarOverlay = ASOverlayLayoutSpec(child: avatarNode, overlay: avatarInset)
        let avatarAbsolute = ASAbsoluteLayoutSpec(children: [avatarOverlay])
        let headerOverlay = ASOverlayLayoutSpec(child: headerInset, overlay: avatarAbsolute)
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [headerOverlay, postTextNode, actionStack]
        contentStack.style.width = ASDimension(unit: .fraction, value: 1.0)
        contentStack.spacing = 6.0
        previewNode.style.width = ASDimension(unit: .fraction, value: 0.25)
        
        let stack = ASStackLayoutSpec.horizontal()
        let contentInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(2, 2, 2, 2), child: contentStack)
        stack.children = [contentInset]
        var leftInset:CGFloat = 8
        if let post = post {
            if post.attachments.isImage || post.attachments.isVideo {
                stack.children?.append(previewNode)
                contentStack.style.width = ASDimension(unit: .fraction, value: 0.70)
                leftInset = 4
            }
        }
        
        stack.spacing = 12
        let mainInsets = UIEdgeInsetsMake(8, 8, 8, leftInset)
        
        return ASInsetLayoutSpec(insets: mainInsets, child: stack)
    }
    
    func setHighlighted(_ highlighted:Bool) {
        backgroundColor = highlighted ? currentTheme.highlightedBackgroundColor : currentTheme.backgroundColor
    }
    
    var likesRef:DatabaseReference?
    var likesRefHandle:DatabaseHandle?
    var commentsRef:DatabaseReference?
    var commentsRefHandle:DatabaseHandle?
    
    func observePost() {
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        likesRef = database.child("posts/meta/\(post.key)/numLikes")
        likesRefHandle = likesRef?.observe(.value, with: { snapshot in
            post.numLikes = snapshot.value as? Int ?? 0
            let likeTitle = NSMutableAttributedString(string: numericShorthand(post.numLikes), attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
                ])
            self.likeButton.setAttributedTitle(likeTitle, for: .normal)
        })
        
        let likedRef = database.child("posts/likes/\(post.key)/\(uid)")
        likedRef.observe(.value, with: { snapshot in
            post.liked = snapshot.value as? Bool ?? false
        })
        
        commentsRef = database.child("posts/meta/\(post.key)/replies")
        commentsRefHandle = commentsRef?.observe(.value, with: { snapshot in
            post.numReplies = snapshot.value as? Int ?? 0
            let commentTitle = NSMutableAttributedString(string: numericShorthand(post.numReplies), attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
                ])
            self.commentButton.setAttributedTitle(commentTitle, for: .normal)
        })
    }
    
    func stopObservingPost() {
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        likesRef?.removeObserver(withHandle: likesRefHandle!)
        likesRef = nil
        likesRefHandle = nil
        
        commentsRef?.removeObserver(withHandle: commentsRefHandle!)
        commentsRef = nil
        commentsRefHandle = nil
        
        let likedRef = database.child("posts/likes/\(post.key)/\(uid)")
        likedRef.removeAllObservers()
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        observePost()
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        setHighlighted(false)
    }
    
    @objc func handleMore() {
        guard let post = self.post else { return }
        delegate?.postOptions(post)
    }
}


class NewPostCellNode:ASCellNode {
    
    var avatarNode = ASDisplayNode()
    var avatarImageNode = ASImageNode()
    var previewNode:PreviewNode!
    var titleNode = ASTextNode()
    var subnameNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var postTextNode = ActiveTextNode()
    var timeNode = ASTextNode()
    var moreButton = ASButtonNode()
    
    var likeButton = ASButtonNode()
    var commentButton = ASButtonNode()
    
    var post:Post?
    var shouldStopObserving = true
    
    weak var delegate:PostCellDelegate?
    
    required init(post:Post) {
        super.init()
        self.post = post
        self.backgroundColor = currentTheme.backgroundColor
        automaticallyManagesSubnodes = true
        
        postTextNode.maximumNumberOfLines = 4
        postTextNode.tapHandler = { type, value in
            switch type {
            case .hashtag:
                self.delegate?.postOpen(tag: value)
                break
            case .mention:
                break
            case .link:
                break
            }
        }
        
        likeButton.setImage(UIImage(named:"like"), for: .normal)
        likeButton.laysOutHorizontally = true
        likeButton.contentSpacing = 1.0
        likeButton.contentHorizontalAlignment = .middle
        likeButton.contentEdgeInsets = .zero
        likeButton.imageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: currentTheme.secondaryTextColor)
        }
        
        let likeTitle = NSMutableAttributedString(string: numericShorthand(post.numLikes), attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
            ])
        likeButton.setAttributedTitle(likeTitle, for: .normal)
        
        commentButton.laysOutHorizontally = true
        commentButton.setImage(UIImage(named:"comment_small"), for: .normal)
        commentButton.contentSpacing = 1.0
        commentButton.contentHorizontalAlignment = .middle
        let commentTitle = NSMutableAttributedString(string: numericShorthand(post.numReplies), attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
            ])
        commentButton.setAttributedTitle(commentTitle, for: .normal)
        commentButton.imageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: currentTheme.secondaryTextColor)
        }
        
        moreButton.setImage(UIImage(named:"more"), for: .normal)
        moreButton.addTarget(self, action: #selector(handleMore), forControlEvents: .touchUpInside)
        moreButton.imageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: currentTheme.secondaryTextColor.withAlphaComponent(0.5))
        }
        //moreButton.isHidden = true
        avatarNode.backgroundColor = post.anon.color.withAlphaComponent(0.30)
        avatarImageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: post.anon.color) ?? image
        }
        avatarNode.style.height = ASDimension(unit: .points, value: 32)
        avatarNode.style.width = ASDimension(unit: .points, value: 32)
        
        titleNode.attributedText = NSAttributedString(string: post.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: post.anon.color
            ])
        
        var subnameStr = ""
        if post.isYou {
            subnameStr = "YOU"
            subnameNode.isHidden = false
        }else {
            subnameNode.isHidden = true
        }
        
        subnameNode.attributedText = NSAttributedString(string: subnameStr, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 9.0),
            NSAttributedStringKey.foregroundColor: currentTheme.backgroundColor
            ])
        subnameNode.textContainerInset = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 0, right: 4.0)
        subnameNode.backgroundColor = post.anon.color
        
        timeNode.attributedText = NSAttributedString(string: post.createdAt.timeSinceNow(), attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
            ])
        
        var locationStr = ""
        if let location = post.location {
            locationStr = " • \(location.locationShortStr)"
        }
        
        let subtitleStr = "\(post.createdAt.timeSinceNow())\(locationStr)"
        
        subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
            ])
        
        avatarImageNode.image = nil
        UserService.retrieveAnonImage(withName: post.anon.animal.lowercased()) { image, fromFile in
            self.avatarImageNode.image = image
        }
        
        if let blockedMessage = post.blockedMessage {
            previewNode = PreviewNode(block: true)
            postTextNode.attributedText = NSAttributedString(string: blockedMessage, attributes: [
                NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
            ])
            
        } else {
            previewNode = PreviewNode()
            postTextNode.setText(text: post.text, withSize: 14.0,
                                 normalColor: currentTheme.primaryTextColor, activeColor: currentTheme.secondaryAccentColor)
        }
        
        previewNode.style.height = ASDimension(unit: .points, value: 144)
        self.previewNode.imageNode.shouldCacheImage = true
        
        if post.attachments.isVideo {
            let thumbnailRef = storage.child("publicPosts/\(post.key)/thumbnail.gif")
            print("IS VIDEO MAN!")
            thumbnailRef.downloadURL { url, error in
                print("PREVIEW TINGS!")
                self.previewNode.imageNode.url = url
            }
        } else if post.attachments.isImage {
            print("IS IMAGE MAN!")
            let thumbnailRef = storage.child("publicPosts/\(post.key)/thumbnail.jpg")
            thumbnailRef.downloadURL { url, error in
                self.previewNode.imageNode.url = url
            }
        }
        
    }
    
    override func didLoad() {
        super.didLoad()
        avatarNode.layer.cornerRadius = 16
        avatarNode.clipsToBounds = true
        subnameNode.layer.cornerRadius = 2.0
        subnameNode.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let ss = ASStackLayoutSpec.horizontal()
        ss.children = [likeButton, commentButton]
        ss.spacing = 16.0
        
        let actionStack = ASStackLayoutSpec.horizontal()
        actionStack.children = [ss, moreButton]
        actionStack.spacing = 0.0
        actionStack.alignContent = .spaceBetween
        actionStack.justifyContent = .spaceBetween
        
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.children = [titleNode, subnameNode]
        titleStack.spacing = 4.0
        
        let headerStack = ASStackLayoutSpec.vertical()
        headerStack.children = [titleStack, subtitleNode]
        headerStack.spacing = 1.0
        
        postTextNode.style.flexGrow = 1.0
        let headerInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 40, 0, 0), child: headerStack)
        
        let avatarInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(5, 5, 5, 5), child: avatarImageNode)
        let avatarOverlay = ASOverlayLayoutSpec(child: avatarNode, overlay: avatarInset)
        let avatarAbsolute = ASAbsoluteLayoutSpec(children: [avatarOverlay])
        let headerOverlay = ASOverlayLayoutSpec(child: headerInset, overlay: avatarAbsolute)
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [headerOverlay, postTextNode, actionStack]
        contentStack.style.width = ASDimension(unit: .fraction, value: 1.0)
        contentStack.spacing = 6.0
        previewNode.style.width = ASDimension(unit: .fraction, value: 0.25)
        
        let stack = ASStackLayoutSpec.horizontal()
        stack.children = [contentStack]
        if let post = post {
            if post.attachments.isImage || post.attachments.isVideo {
                stack.children?.append(previewNode)
                contentStack.style.width = ASDimension(unit: .fraction, value: 0.70)
            }
        }
        
        stack.spacing = 12
        let mainInsets = UIEdgeInsetsMake(16, 12, 16, 12)
        
        return ASInsetLayoutSpec(insets: mainInsets, child: stack)
    }
    
    func setHighlighted(_ highlighted:Bool) {
        backgroundColor = highlighted ? currentTheme.highlightedBackgroundColor : currentTheme.backgroundColor
    }
    
    var likesRef:DatabaseReference?
    var likesRefHandle:DatabaseHandle?
    var commentsRef:DatabaseReference?
    var commentsRefHandle:DatabaseHandle?
    
    func observePost() {
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        likesRef = database.child("posts/meta/\(post.key)/numLikes")
        likesRefHandle = likesRef?.observe(.value, with: { snapshot in
            post.numLikes = snapshot.value as? Int ?? 0
            let likeTitle = NSMutableAttributedString(string: numericShorthand(post.numLikes), attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
                ])
            self.likeButton.setAttributedTitle(likeTitle, for: .normal)
        })
        
        let likedRef = database.child("posts/likes/\(post.key)/\(uid)")
        likedRef.observe(.value, with: { snapshot in
            post.liked = snapshot.value as? Bool ?? false
        })
        
        commentsRef = database.child("posts/meta/\(post.key)/replies")
        commentsRefHandle = commentsRef?.observe(.value, with: { snapshot in
            post.numReplies = snapshot.value as? Int ?? 0
            let commentTitle = NSMutableAttributedString(string: numericShorthand(post.numReplies), attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
                ])
            self.commentButton.setAttributedTitle(commentTitle, for: .normal)
        })
    }
    
    func stopObservingPost() {
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        likesRef?.removeObserver(withHandle: likesRefHandle!)
        likesRef = nil
        likesRefHandle = nil
        
        commentsRef?.removeObserver(withHandle: commentsRefHandle!)
        commentsRef = nil
        commentsRefHandle = nil
        
        let likedRef = database.child("posts/likes/\(post.key)/\(uid)")
        likedRef.removeAllObservers()
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        observePost()
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        setHighlighted(false)
    }
    
    @objc func handleMore() {
        guard let post = self.post else { return }
        delegate?.postOptions(post)
    }
}
