//
//  SinglePostCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-04.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase
import Pastel

class AvatarNode:ASDisplayNode {
    var backNode = ASDisplayNode()
    var imageNode = ASNetworkImageNode()
    var imageInset:CGFloat = 5.0
    
    
    required init(post:Post, cornerRadius: CGFloat, imageInset:CGFloat) {
        super.init()
        automaticallyManagesSubnodes = true
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        
        backgroundColor = UIColor.white
        backNode.backgroundColor = UIColor.white
        imageNode.shouldCacheImage = true
        imageNode.image = nil
        
        if let profile = post.profile {
            self.imageInset = 0.0
            
            UserService.retrieveUserImage(uid: profile.uid, .low) { image, _ in
                self.imageNode.image = image
            }
            imageNode.imageModificationBlock = nil
        } else {
            self.imageInset = imageInset
            backNode.backgroundColor = post.anon.color
            backgroundColor = post.anon.color
            layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            layer.borderWidth = 1.5
            UserService.retrieveAnonImage(withName: post.anon.animal.lowercased()) { image, fromFile in
                self.imageNode.image = image
            }
            
            imageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: UIColor.white.withAlphaComponent(0.75)) ?? image
            }
        }
        
        
        
       
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let inset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(imageInset, imageInset, imageInset, imageInset), child: imageNode)
        let overlay = ASOverlayLayoutSpec(child: backNode, overlay: inset)
        return overlay
    }
    
}

class ContentOverlayNode:ASControlNode {
    
    var postTextNode = ActiveTextNode()
    var avatarNode:AvatarNode!
    var usernameNode = ASTextNode()
    var subnameNode = ASTextNode()
    var timeNode = ASTextNode()
    
    
    var actionsRow:SinglePostActionsView!
    weak var delegate:PostActionsDelegate?
    weak var post:Post?
    var hasAttachments = false
    required init(post:Post, delegate: PostActionsDelegate?) {
        super.init()
        self.post = post
        self.delegate = delegate
        hasAttachments = post.attachments.isImage || post.attachments.isVideo
        automaticallyManagesSubnodes = true
        postTextNode.maximumNumberOfLines = 4
        
        avatarNode = AvatarNode(post: post, cornerRadius: 16, imageInset: 6)
        avatarNode.style.height = ASDimension(unit: .points, value: 32)
        avatarNode.style.width = ASDimension(unit: .points, value: 32)
        
        if post.attachments.isImage || post.attachments.isVideo {
            if let blockedMessage = post.blockedMessage {
                postTextNode.attributedText = NSAttributedString(string: blockedMessage, attributes: [
                    NSAttributedStringKey.font: Fonts.semiBold(ofSize: 16.0),
                    NSAttributedStringKey.foregroundColor: UIColor(white:0.67, alpha: 1.0)
                    ])
            } else {
                
                postTextNode.setText(text: post.text, withFont: Fonts.regular(ofSize: 18.0), normalColor: .white, activeColor: tagColor)
                postTextNode.tapHandler = { type, str in
                    switch type {
                    case .hashtag:
                        self.delegate?.openTag(str)
                        break
                    default:
                        break
                    }
                }
            }
        }
        
        subnameNode.isHidden = true
        
        if let profile = post.profile {
            usernameNode.attributedText = NSAttributedString(string: profile.username , attributes: [
                NSAttributedStringKey.font: Fonts.bold(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.white
                ])
        } else {
            usernameNode.attributedText = NSAttributedString(string: post.anon.displayName , attributes: [
                NSAttributedStringKey.font: Fonts.bold(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.white
                ])
            
            if post.isYou {

                subnameNode.isHidden = false
                subnameNode.attributedText = NSAttributedString(string: "YOU", attributes: [
                    NSAttributedStringKey.font: Fonts.semiBold(ofSize: 9.0),
                    NSAttributedStringKey.foregroundColor: post.anon.color
                    ])
                subnameNode.textContainerInset = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)
                subnameNode.backgroundColor = UIColor.white
            }
        }
        
        timeNode.attributedText = NSAttributedString(string: post.createdAt.fullTimeSinceNow() , attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        
        
        avatarNode.imageNode.addTarget(self, action: #selector(handleAvatarTap), forControlEvents: .touchUpInside)
    }
    
    var locationButton:UIButton!
    override func didLoad() {
        super.didLoad()
        
        subnameNode.layer.cornerRadius = 2.0
        subnameNode.clipsToBounds = true
        
        actionsRow = SinglePostActionsView(frame: .zero)
        actionsRow.delegate = delegate
        actionsRow.isUserInteractionEnabled = true
        view.addSubview(actionsRow)
        usernameNode.view.applyShadow(radius: 4.0, opacity: 0.1, offset: .zero, color: UIColor.black, shouldRasterize: false)
        actionsRow.translatesAutoresizingMaskIntoConstraints = false
        actionsRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        actionsRow.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        actionsRow.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        actionsRow.heightAnchor.constraint(equalToConstant: 64).isActive = true
        if let post = self.post {
            
            actionsRow.likeLabel.text = "\(post.numLikes)"
            actionsRow.commentLabel.text = "\(post.numReplies)"
            actionsRow.setLiked(post.liked, animated: false)
        
            if let location = post.location {
                actionsRow.locationButton.isHidden = false
                actionsRow.locationButton.setTitle(location.locationShortStr, for: .normal)
            } else {
                actionsRow.locationButton.isHidden = true
            }
            let isBlocked = post.blockedMessage != nil
            actionsRow.setBlocked(isBlocked)
            

        }
    
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let subnameCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subnameNode)
        
        let usernameStack = ASStackLayoutSpec.horizontal()
        usernameStack.children = [usernameNode, subnameCenter]
        usernameStack.spacing = 4.0
        
        let labelStack = ASStackLayoutSpec.vertical()
        labelStack.children = [usernameStack, timeNode]
        
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.children = [avatarNode, labelStack]
        titleStack.spacing = 8.0
        
        let contentStack = ASStackLayoutSpec.vertical()
        if hasAttachments {
            contentStack.children = [titleStack, postTextNode]
            contentStack.spacing = 8.0
        }
        
        
        
        let mainInsets = UIEdgeInsetsMake(12, 12, 64, 12)
        return ASInsetLayoutSpec(insets: mainInsets, child: contentStack)
    }
    
    func setNumLikes(_ likes:Int) {
        actionsRow.likeLabel.text = numericShorthand(likes)
    }
    
    func setNumComments(_ comments:Int) {
        actionsRow.commentLabel.text = numericShorthand(comments)
    }
    
    func temporaryUnblock() {
        guard let post = self.post else { return }
        postTextNode.setText(text: post.text, withFont: Fonts.regular(ofSize: 15.0), normalColor: .white, activeColor: tagColor)
        actionsRow.setBlocked(false)
    }
    
    @objc func handleAvatarTap() {
        guard let profile = self.post?.profile else { return }
        delegate?.postOpen(profile: profile)
    }
}

protocol SinglePostDelegate:class {
    func openComments(_ post:Post,_ showKeyboard:Bool)
    func searchLocation(_ locationStr:String)
    func openTag(_ tag:String)
    func postOpen(profile:Profile)
}

class SinglePostCellNode: ASCellNode, ASTableDelegate, ASTableDataSource, PostActionsDelegate {
    func openTag(_ tag: String) {
        delegate?.openTag(tag)
    }
    
    func postOpen(profile: Profile) {
        delegate?.postOpen(profile: profile)
    }
    
    func handleMoreButton() {
        
    }
    
    
    var contentNode:PostContentNode!
    var contentOverlay:ContentOverlayNode!
    weak var delegate:SinglePostDelegate?
    weak var post:Post?
    var temporaryUnblock = false
    var commentNode:PostCommentCellNode!
    var deviceInsets:UIEdgeInsets = .zero
    
    required init(post:Post, group:Group, deviceInsets:UIEdgeInsets?=nil) {
        super.init()
        self.post = post
        self.deviceInsets = deviceInsets ?? .zero
         automaticallyManagesSubnodes = true
        backgroundColor = UIColor.clear
        contentNode = PostContentNode(post: post, group: group)
        contentNode.textNode.tapHandler = { type, value in
            switch type {
            case .hashtag:
                self.delegate?.openTag(value)
                break
            case .mention:
                break
            case .link:
                break
            }
        }
        
        contentNode.avatarNode.imageNode.addTarget(self, action: #selector(handleAvatarTap), forControlEvents: .touchUpInside)
        contentNode.avatarNode.imageNode.isUserInteractionEnabled = true
        
        contentOverlay = ContentOverlayNode(post: post, delegate: self)
        
        contentOverlay.addTarget(self, action: #selector(handleOverlayTap), forControlEvents: .touchUpInside)
        
        contentNode.blockedButtonNode?.addTarget(self, action: #selector(handleUnblock), forControlEvents: .touchUpInside)
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let overlayStack = ASStackLayoutSpec.vertical()
        overlayStack.children = [contentOverlay]
        overlayStack.alignContent = .end
        overlayStack.justifyContent = .end
        let overlayInsets = UIEdgeInsetsMake(0, 0, deviceInsets.bottom, 0)
        let overlayInsetSpec = ASInsetLayoutSpec(insets: overlayInsets, child: overlayStack)
        
        let overlay = ASOverlayLayoutSpec(child: contentNode, overlay: overlayInsetSpec)
        return ASInsetLayoutSpec(insets: .zero, child: overlay)
    }
    
    @objc func handleOverlayTap() {
        guard let post = self.post else { return }
        if post.blockedMessage == nil || temporaryUnblock {
            delegate?.openComments(post, false)
        }
    }
    
    @objc func handleUnblock() {
        temporaryUnblock = true
        contentNode.temporaryUnblock()
        contentOverlay.temporaryUnblock()
    }
    
    func handleLikeButton() {
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = database.child("posts/likes/\(post.key)/\(uid)")
        post.liked = !post.liked
        contentOverlay.actionsRow.setLiked(post.liked, animated: true)
        
        if post.liked {
            post.numLikes += 1
            contentOverlay.setNumLikes(post.numLikes)
            ref.setValue(true)
        } else {
            post.numLikes -= 1
            contentOverlay.setNumLikes(post.numLikes)
            ref.setValue(false)
        }
    }
    
    func handleCommentButton() {
        guard let post = self.post else { return }
        delegate?.openComments(post, true)
    }
    
    func handleLocationButton() {
        guard let location = self.post?.location else { return }
        delegate?.searchLocation(location.locationStr)
    }
    
    var likesRef:DatabaseReference?
    var likesRefHandle:DatabaseHandle?
    var likedRef:DatabaseReference?
    var likedRefHandle:DatabaseHandle?
    var commentsRef:DatabaseReference?
    var commentsRefHandle:DatabaseHandle?
    func observePost() {
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        likesRef = database.child("posts/meta/\(post.key)/numLikes")
        likesRefHandle = likesRef?.observe(.value, with: { snapshot in
            post.numLikes = snapshot.value as? Int ?? 0
            self.contentOverlay.setNumLikes(post.numLikes)
        })
        
        likedRef = database.child("posts/likes/\(post.key)/\(uid)")
        likedRefHandle = likedRef?.observe(.value, with: { snapshot in
            post.liked = snapshot.value as? Bool ?? false
            self.contentOverlay.actionsRow.setLiked(post.liked, animated: false)
        })
        
        commentsRef = database.child("posts/meta/\(post.key)/numReplies")
        commentsRefHandle = commentsRef?.observe(.value, with: { snapshot in
            post.numReplies = snapshot.value as? Int ?? 0
            self.contentOverlay.setNumComments(post.numReplies)
        })
    }
    
    func stopObservingPost() {
        likesRef?.removeObserver(withHandle: likesRefHandle!)
        likesRef = nil
        likesRefHandle = nil
        
        commentsRef?.removeObserver(withHandle: commentsRefHandle!)
        commentsRef = nil
        commentsRefHandle = nil
        
        likedRef?.removeObserver(withHandle: likedRefHandle!)
        likedRef = nil
        likedRefHandle = nil
        
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        observePost()
        //contentNode.videoNode.play()
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        stopObservingPost()
        //contentNode.videoNode.pause()
    }
    
    func mutedVideo(_ muted:Bool) {
        contentNode.videoNode.muted = muted
    }
    
    @objc func handleAvatarTap() {
        guard let profile = post?.profile else { return }
        delegate?.postOpen(profile: profile)
    }
    
}
