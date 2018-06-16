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

class NewPostCellNode:ASCellNode {
    
    var avatarNode = ASDisplayNode()
    var avatarImageNode = ASImageNode()
    var videoNode = ASVideoNode()
    var imageNode = ASNetworkImageNode()
    var previewBox = ASDisplayNode()
    var titleNode = ASTextNode()
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
        self.backgroundColor = UIColor.white
        automaticallyManagesSubnodes = true
        imageNode.backgroundColor = hexColor(from: "BEBEBE")
        imageNode.shouldCacheImage = true
        
        previewBox.style.height = ASDimension(unit: .points, value: 100)
        if let images = post.attachments?.images, images.count > 0 {
            imageNode.url = images[0].url
            previewBox.style.height = ASDimension(unit: .points, value: 100)
        } else if let video = post.attachments?.video {
            imageNode.url = video.thumbnail_url
            previewBox.style.height = ASDimension(unit: .points, value: 132)
        }
        
        previewBox.backgroundColor = nil
        previewBox.automaticallyManagesSubnodes = true
        previewBox.layoutSpecBlock = { _, _ in
            let overlay = ASOverlayLayoutSpec(child: self.videoNode, overlay: self.imageNode)
            return ASInsetLayoutSpec(insets: .zero, child: overlay)
        }
        
        titleNode.attributedText = NSAttributedString(string: post.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: post.anon.color
            ])
        
        timeNode.attributedText = NSAttributedString(string: post.createdAt.timeSinceNow(), attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: hexColor(from: "BEBEBE")
            ])
        
        var locationStr = ""
        if let location = post.location {
            locationStr = " • \(location.locationStr)"
        }
        
        let subtitleStr = "\(post.createdAt.timeSinceNow())\(locationStr)"
        
        subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: grayColor
            ])
        
        postTextNode.maximumNumberOfLines = 3
        postTextNode.setText(text: post.textClean, withSize: 16.0, normalColor: .black, activeColor: tagColor)
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
        let likeTitle = NSMutableAttributedString(string: "\(post.numLikes)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: hexColor(from: "BEBEBE")
            ])
        likeButton.setAttributedTitle(likeTitle, for: .normal)
        
        commentButton.laysOutHorizontally = true
        commentButton.setImage(UIImage(named:"comment_small"), for: .normal)
        commentButton.contentSpacing = 1.0
        commentButton.contentHorizontalAlignment = .middle
        let commentTitle = NSMutableAttributedString(string: "\(post.numReplies)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: hexColor(from: "BEBEBE")
            ])
        commentButton.setAttributedTitle(commentTitle, for: .normal)
        
        
        moreButton.setImage(UIImage(named:"more"), for: .normal)
        
        avatarNode.backgroundColor = post.anon.color.withAlphaComponent(0.30)
        avatarImageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: post.anon.color) ?? image
        }
//        avatarNode.image = UIImage(named:"sparrow")
        avatarNode.style.height = ASDimension(unit: .points, value: 32)
        avatarNode.style.width = ASDimension(unit: .points, value: 32)
        avatarImageNode.image = nil
        UserService.retrieveAnonImage(withName: post.anon.animal.lowercased()) { image, fromFile in
            print("GOT ANON ICON FROMFILE: \(fromFile)")
            self.avatarImageNode.image = image
        }
    }
    
    override func didLoad() {
        super.didLoad()
        previewBox.layer.cornerRadius = 4.0
        previewBox.clipsToBounds = true
        avatarNode.layer.cornerRadius = 16
        avatarNode.clipsToBounds = true
        
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
        
        let headerStack = ASStackLayoutSpec.vertical()
        headerStack.children = [titleNode, subtitleNode]
        headerStack.spacing = 1.0
        
        postTextNode.style.flexGrow = 1.0
        let headerInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 40, 0, 0), child: headerStack)
        
        let avatarInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(5, 5, 5, 5), child: avatarImageNode)
        let avatarOverlay = ASOverlayLayoutSpec(child: avatarNode, overlay: avatarInset)
        let avatarAbsolute = ASAbsoluteLayoutSpec(children: [avatarOverlay])
        let headerOverlay = ASOverlayLayoutSpec(child: headerInset, overlay: avatarAbsolute)
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [headerOverlay, postTextNode, actionStack]
        contentStack.style.width = ASDimension(unit: .fraction, value: 0.70)
        contentStack.spacing = 6.0
        previewBox.style.width = ASDimension(unit: .fraction, value: 0.25)
        
        let stack = ASStackLayoutSpec.horizontal()
        stack.children = [previewBox, contentStack]
        stack.spacing = 12
        let mainInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        
        return ASInsetLayoutSpec(insets: mainInsets, child: stack)
    }
    
    func setHighlighted(_ highlighted:Bool) {
        backgroundColor = highlighted ? UIColor(white: 0.92, alpha: 1.0) : UIColor.white
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
            let likeTitle = NSMutableAttributedString(string: "\(post.numLikes)", attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: hexColor(from: "BEBEBE")
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
            let commentTitle = NSMutableAttributedString(string: "\(post.numReplies)", attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: hexColor(from: "BEBEBE")
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
        
        stopObservingPost()
    }
}
