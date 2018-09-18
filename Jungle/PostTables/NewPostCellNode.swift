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
        self.layer.cornerRadius = 3.0
        self.clipsToBounds = true
        self.imageNode.backgroundColor = currentTheme.highlightedBackgroundColor
    }
    
    override func didLoad() {
        super.didLoad()
        //self.imageNode.cornerRadius = 4.0
        //self.imageNode.clipsToBounds = true
        //self.view.applyShadow(radius: 4.0, opacity: 0.15, offset: CGSize(width:0, height: 2.0), color: .black, shouldRasterize: false)
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
    var dividerNode:ASDisplayNode!
    
    required init(post:Post, group:Group, rank:Int?=nil) {
        super.init()
        backgroundColor = UIColor.white
        contentNode = ASDisplayNode()
        postNode = PostNode(post: post, group: group, rank: rank)
        automaticallyManagesSubnodes = true
        contentNode.automaticallyManagesSubnodes = true
        contentNode.layoutSpecBlock = { _,_ in
            return ASInsetLayoutSpec(insets: .zero, child: self.postNode)
        }
        
        dividerNode = ASDisplayNode()
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        dividerNode.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let dividerInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 4, 0, 4), child: dividerNode)
        let stack = ASStackLayoutSpec.vertical()
        stack.spacing = 10
        stack.children = [contentNode, dividerInset]
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(10, 10, 0, 10), child: stack)
    }

    func setHighlighted(_ highlighted:Bool) {
        backgroundColor = highlighted ? currentTheme.highlightedBackgroundColor : currentTheme.backgroundColor
        postNode.setHighlighted(highlighted)
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        setHighlighted(false)
    }
}

class PostNode:ASDisplayNode {
    
    var avatarNode = ASDisplayNode()
    var avatarImageNode = ASNetworkImageNode()
    var previewNode:PreviewNode!
    var titleNode = ASTextNode()
    var subnameNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var postTextNode = ActiveTextNode()
    var moreButton = ASButtonNode()
    
    var likeButton = ASButtonNode()
    var commentButton = ASButtonNode()
    
    var timeNode = ASTextNode()
    
    var post:Post?
    var shouldStopObserving = true
    
    var locationButton = ASButtonNode()
    
    weak var delegate:PostCellDelegate?
    
    var rank:Int?
    required init(post:Post, group:Group, rank:Int?=nil) {
        super.init()
        self.post = post
        self.rank = rank
        
        backgroundColor = currentTheme.backgroundColor//hexColor(from: "#333742")
        automaticallyManagesSubnodes = true
        postTextNode.maximumNumberOfLines = post.attachments.isImage
            || post.attachments.isVideo ? 3 : 6
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
        likeButton.contentSpacing = 0.0
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
        commentButton.contentSpacing = 0.0
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
            return image.maskWithColor(color: currentTheme.secondaryTextColor)
        }
        //moreButton.isHidden = true
        
        
        avatarNode.style.height = ASDimension(unit: .points, value: 32)
        avatarNode.style.width = ASDimension(unit: .points, value: 32)
        
        avatarImageNode.image = nil
        avatarImageNode.url = nil
        
        if let profile = post.profile {
            titleNode.attributedText = NSAttributedString(string: profile.username, attributes: [
                NSAttributedStringKey.font: Fonts.bold(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.black
                ])
            
            UserService.retrieveUserImage(uid: profile.uid, .low) { image, _ in
                self.avatarImageNode.image = image
            }
            
            avatarImageNode.imageModificationBlock = { image in
                return image
            }
            avatarNode.backgroundColor = tertiaryColor
            avatarImageNode.layer.cornerRadius = 16
            avatarImageNode.clipsToBounds = true
        } else {
            titleNode.attributedText = NSAttributedString(string: post.anon.displayName, attributes: [
                NSAttributedStringKey.font: Fonts.bold(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: post.anon.color
                ])
            UserService.retrieveAnonImage(withName: post.anon.animal.lowercased()) { image, fromFile in
                self.avatarImageNode.image = image
            }
            
            avatarImageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: UIColor.white.withAlphaComponent(0.75)) ?? image
            }
            avatarNode.backgroundColor = post.anon.color//.withAlphaComponent(0.30)
            avatarImageNode.layer.cornerRadius = 0
            avatarImageNode.clipsToBounds = false
        }
        
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
        subnameNode.textContainerInset = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)
        subnameNode.backgroundColor = post.anon.color
        
        var locationStr = ""
        if let location = post.location {
            locationStr = " • \(location.locationShortStr)"
        }
        
        let subtitleStr = group.name
        
        subtitleNode.maximumNumberOfLines = 1
        subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: tertiaryColor
            ])
        
        
        if let blockedMessage = post.blockedMessage {
            previewNode = PreviewNode(block: true)
            postTextNode.attributedText = NSAttributedString(string: blockedMessage, attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
                ])
            
        } else {
            previewNode = PreviewNode()
            
            postTextNode.setText(text: post.text, withFont: Fonts.light(ofSize: 16.0),
                                 normalColor: currentTheme.primaryTextColor, activeColor: currentTheme.secondaryAccentColor)
        }
        
        self.previewNode.imageNode.shouldCacheImage = true
        
        if post.attachments.isVideo {
            let thumbnailRef = storage.child("publicPosts/\(post.key)/thumbnail.gif")
            thumbnailRef.downloadURL { url, error in
                self.previewNode.imageNode.url = url
            }
        } else if post.attachments.isImage {
            let thumbnailRef = storage.child("publicPosts/\(post.key)/thumbnail.jpg")
            thumbnailRef.downloadURL { url, error in
                self.previewNode.imageNode.url = url
            }
        }
        
        if let rank = rank {
            if rank > 1 {
                timeNode.attributedText = NSAttributedString(string: "\(rank).", attributes: [
                    NSAttributedStringKey.font: Fonts.extraBold(ofSize: 16.0),
                    NSAttributedStringKey.foregroundColor: UIColor(white: 0.35, alpha: 1.0)
                    ])
            } else {
                timeNode.isHidden = true
            }
            
        } else {
            timeNode.attributedText = NSAttributedString(string: post.createdAt.timeSinceNow(), attributes: [
                NSAttributedStringKey.font: Fonts.regular(ofSize: 13.0),
                NSAttributedStringKey.foregroundColor: tertiaryColor
                ])
        }
        
        
        
        
        if let location = post.location {
            let str = NSAttributedString(string: location.locationShortStr, attributes: [
                                NSAttributedStringKey.font: Fonts.regular(ofSize: 13.0),
                                NSAttributedStringKey.foregroundColor: tertiaryColor
                                ])
            locationButton.setAttributedTitle(str, for: .normal)
            locationButton.isHidden = false
            locationButton.contentSpacing = -4
            locationButton.setImage(UIImage(named:"pinios"), for: .normal)
        } else {
            locationButton.isHidden = true
        }
        
        avatarImageNode.addTarget(self, action: #selector(handleAvatarTap), forControlEvents: .touchUpInside)
        avatarImageNode.isUserInteractionEnabled = true
    }
    
    @objc func handleAvatarTap() {
        guard let profile = post?.profile else { return }
        delegate?.postOpen(profile: profile)
    }
    
    override func didLoad() {
        super.didLoad()
        avatarNode.layer.cornerRadius = 16
        avatarNode.clipsToBounds = true
        
        subnameNode.layer.cornerRadius = 2.0
        subnameNode.clipsToBounds = true
        
        if let rank = rank, rank == 1 {
            let crown = UIImageView(image: UIImage(named: "Crowngray"))
            view.addSubview(crown)
            crown.translatesAutoresizingMaskIntoConstraints = false
            crown.topAnchor.constraint(equalTo: view.topAnchor, constant: -4).isActive = true
            crown.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4).isActive = true
        }
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let ss = ASStackLayoutSpec.horizontal()
        ss.children = [likeButton, commentButton]
        ss.spacing = 12.0
        
        let actionStack = ASStackLayoutSpec.horizontal()
        actionStack.children = [ss , locationButton]
        actionStack.spacing = 0.0
        actionStack.alignContent = .spaceBetween
        actionStack.justifyContent = .spaceBetween
        
        let subnameCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subnameNode)
        
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.children = [titleNode, subnameCenter]
        titleStack.spacing = 4.0
        
        let timeCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: timeNode)
        let headerRow = ASStackLayoutSpec.horizontal()
        headerRow.children = [titleStack ,timeCenter]
        headerRow.spacing = 0.0
        headerRow.alignContent = .spaceBetween
        headerRow.justifyContent = .spaceBetween
        
        let headerStack = ASStackLayoutSpec.vertical()
        headerStack.children = [headerRow, subtitleNode]
        headerStack.spacing = -1

        
        postTextNode.style.flexGrow = 1.0
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [postTextNode, actionStack]
        contentStack.style.width = ASDimension(unit: .fraction, value: 1.0)
        contentStack.spacing = 6.0
        
        previewNode.style.width = ASDimension(unit: .fraction, value: 0.26)
        previewNode.style.height = ASDimension(unit: .points, value: 144)
        
        let stack = ASStackLayoutSpec.horizontal()
        var contentInsets:UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 6)
        if let post = post {
            if post.attachments.isImage || post.attachments.isVideo {
                contentInsets = UIEdgeInsetsMake(0, 0, 0, 6 + 8)
            }
        }
        let contentInset = ASInsetLayoutSpec(insets: contentInsets, child: contentStack)
        stack.children = [contentInset]
        stack.spacing = 8
        
        var headerInsets = UIEdgeInsetsMake(0,40,0,0)
        avatarNode.isHidden = false
        avatarImageNode.isHidden = false
        if let post = post {
            if post.attachments.isImage || post.attachments.isVideo {
                avatarNode.isHidden = true
                avatarImageNode.isHidden = true
                headerInsets = UIEdgeInsetsMake(0,0,0,0)
                let previewNodeInsets = UIEdgeInsetsMake(2, 0, 0, 0)
                let insetPreviewNode = ASInsetLayoutSpec(insets: previewNodeInsets, child: previewNode)
                stack.children?.insert(insetPreviewNode, at: 0)
                contentStack.style.width = ASDimension(unit: .fraction, value: 0.74)
                
            }
        }
        let headerInset = ASInsetLayoutSpec(insets: headerInsets, child: headerStack)
        
        var avatarInsets:UIEdgeInsets
        if post?.profile != nil {
            avatarInsets = .zero
        } else {
            avatarInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        }
        let avatarInset = ASInsetLayoutSpec(insets: avatarInsets, child: avatarImageNode)
        let avatarOverlay = ASOverlayLayoutSpec(child: avatarNode, overlay: avatarInset)
        let avatarAbsolute = ASAbsoluteLayoutSpec(children: [avatarOverlay])
        let headerOverlay = ASOverlayLayoutSpec(child: headerInset, overlay: avatarAbsolute)
        
        contentStack.children?.insert(headerOverlay, at: 0)
        
        
        let bigStack = ASStackLayoutSpec.vertical()
        bigStack.children = [stack]
        //stack.spacing = 0
        let mainInsets = UIEdgeInsetsMake(6, 4, 8, 4)
        
        return ASInsetLayoutSpec(insets: mainInsets, child: bigStack)
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
        
        commentsRef = database.child("posts/meta/\(post.key)/numReplies")
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
    }
    
    @objc func handleMore() {
        guard let post = self.post else { return }
        delegate?.postOptions(post)
    }
}
