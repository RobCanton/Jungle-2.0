//
//  File.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-04.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import WCLShineButton
import Firebase

class PostCommentCellNode: ASCellNode {
    
    var postTextNode = ActiveTextNode()
    var avatarNode = ASDisplayNode()
    var avatarImageNode = ASNetworkImageNode()
    var usernameNode = ASTextNode()
    var subnameNode = ASTextNode()
    var dividerNode = ASDisplayNode()
    var timeNode = ASTextNode()
    
    var likeButton = ASButtonNode()
    var commentButton = ASButtonNode()
    var moreButton = ASButtonNode()
    
    var post:Post?
    var contentHeight:CGFloat = 0.0
    weak var delegate:CommentCellDelegate?
    var isSubReply = false
    var isCaption = false
    
    var deleted = false
    var isYou = false
    var isOP = false
    
    required init(post:Post, parentPost:Post, isCaption:Bool?=nil, isSubReply:Bool?=nil) {
        super.init()
        self.post = post
        deleted = post.deleted
        
        self.isCaption = isCaption ?? false
        self.isSubReply = isSubReply ?? false
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor.white
        postTextNode.maximumNumberOfLines = 0
        
        dividerNode.backgroundColor = UIColor(white: 0.80, alpha: 1.0)
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        
        if deleted {
            postTextNode.attributedText = NSAttributedString(string: "[deleted]", attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: tertiaryColor
                ])
            return
        }
        let titleSize:CGFloat = self.isSubReply ? 13 : 14
        let avatarSize:CGFloat = self.isSubReply ? 26 : 32
        
        avatarNode.style.height = ASDimension(unit: .points, value: avatarSize)
        avatarNode.style.width = ASDimension(unit: .points, value: avatarSize)
        
        avatarNode.layer.cornerRadius = avatarSize/2
        avatarNode.clipsToBounds = true
        
        avatarImageNode.image = nil
        
        subnameNode.isHidden = true
        
        if let profile = post.profile {
            avatarNode.backgroundColor = tertiaryColor
            avatarImageNode.url = profile.avatarThumbnailURL
            usernameNode.attributedText = NSAttributedString(string: profile.username , attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: titleSize),
                NSAttributedStringKey.foregroundColor: UIColor.black
                ])
            avatarImageNode.layer.cornerRadius = avatarSize/2
            avatarImageNode.clipsToBounds = true
        } else {
            avatarNode.backgroundColor = post.anon.color.withAlphaComponent(0.30)
            avatarImageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: post.anon.color) ?? image
            }
            UserService.retrieveAnonImage(withName: post.anon.animal.lowercased()) { image, _ in
                self.avatarImageNode.image = image
            }
            usernameNode.attributedText = NSAttributedString(string: post.anon.displayName , attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: titleSize),
                NSAttributedStringKey.foregroundColor: post.anon.color
                ])
            
            var subnameStr = ""
            if post.isYou {
                subnameStr = "YOU"
                subnameNode.isHidden = false
            } else if post.key != parentPost.key,
                parentPost.anon.key == post.anon.key {
                subnameStr = "OP"
                subnameNode.isHidden = false
            }
            
            subnameNode.attributedText = NSAttributedString(string: subnameStr, attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 9.0),
                NSAttributedStringKey.foregroundColor: UIColor.white
                ])
            subnameNode.textContainerInset = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)
            subnameNode.backgroundColor = post.anon.color
            
            avatarImageNode.layer.cornerRadius = 0
            avatarImageNode.clipsToBounds = false
        }
        
        timeNode.textContainerInset = UIEdgeInsetsMake(0,2,0,2)
        timeNode.attributedText = NSAttributedString(string: post.createdAt.timeSinceNow() , attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: titleSize),
            NSAttributedStringKey.foregroundColor: tertiaryColor
            ])
        
        likeButton.setImage(UIImage(named:"like"), for: .normal)
        likeButton.laysOutHorizontally = true
        likeButton.contentSpacing = 2.0
        likeButton.contentHorizontalAlignment = .middle
        likeButton.contentEdgeInsets = .zero
        let likeTitle = NSMutableAttributedString(string: "14", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: hexColor(from: "BEBEBE")
            ])
        likeButton.setAttributedTitle(likeTitle, for: .normal)
        
        commentButton.laysOutHorizontally = true
        commentButton.setImage(UIImage(named:"reply"), for: .normal)
        commentButton.contentSpacing = 2.0
        commentButton.contentHorizontalAlignment = .middle
        let commentTitle = NSMutableAttributedString(string: "Reply", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: hexColor(from: "BEBEBE")
            ])
        commentButton.setAttributedTitle(commentTitle, for: .normal)
        moreButton.setImage(UIImage(named:"more"), for: .normal)
        
        if let blockedMessage = post.blockedMessage {
            postTextNode.attributedText = NSAttributedString(string: blockedMessage, attributes: [
                NSAttributedStringKey.font: Fonts.medium(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: tertiaryColor
                ])
            
        } else {
            postTextNode.setText(text: post.text, withSize: 15.0, normalColor: .black, activeColor: tagColor)
            postTextNode.tapHandler = { type, str in
                switch type {
                case .hashtag:
                    self.delegate?.postOpen(tag: str)
                    break
                default:
                    break
                }
            }
        }
    }
    
    var actionsRow:CommentActionsRow!
    override func didLoad() {
        super.didLoad()
        actionsRow = CommentActionsRow(frame:.zero)
        if deleted {
            return
            
        }
        
        actionsRow.delegate = self
        view.addSubview(actionsRow)
        actionsRow.translatesAutoresizingMaskIntoConstraints = false
        var leading:CGFloat = 0
        if isSubReply {
            leading = 24
            actionsRow.replyButton.setTitle(nil, for: .normal)
        }
        actionsRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading).isActive = true
        actionsRow.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        actionsRow.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        actionsRow.heightAnchor.constraint(equalToConstant: 40).isActive = true
        if let post = post {
            actionsRow.setLiked(post.liked, animated: false)
            actionsRow.setNumLikes(post.numLikes)
        }
        
        if isCaption {
            actionsRow.replyButton.isHidden = true
        }
        
        subnameNode.layer.cornerRadius = 2.0
        subnameNode.clipsToBounds = true
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var mainInsets = UIEdgeInsetsMake(12, 12, 44, 12)
        if isSubReply {
            mainInsets = UIEdgeInsetsMake(8, 32, 44, 12)
        }
        
        if deleted {
            let insets = UIEdgeInsetsMake(mainInsets.top, mainInsets.left,
                                          12, mainInsets.right)
            let mainInsetSpec = ASInsetLayoutSpec(insets: insets, child: postTextNode)
            let dividerStack = ASStackLayoutSpec.vertical()
            dividerStack.children = [mainInsetSpec, dividerNode]
            return dividerStack
        }
        
        var avatarInsets:UIEdgeInsets
        if let _ = post?.profile {
            avatarInsets = .zero
        } else {
            avatarInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        }
        
        let avatarInset = ASInsetLayoutSpec(insets: avatarInsets, child: avatarImageNode)
        let avatarOverlay = ASOverlayLayoutSpec(child: avatarNode, overlay: avatarInset)
        
        let tStack = ASStackLayoutSpec.horizontal()
        tStack.spacing = 4.0
        
        tStack.children = [usernameNode, timeNode]
        
        if !subnameNode.isHidden {
            let subnameCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subnameNode)
            tStack.children?.insert(subnameCenter, at: 1)
        }
        
        let titleCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: tStack)
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.spacing = 8.0
        titleStack.children = [avatarOverlay, titleCenter]
        
        let topStack = ASStackLayoutSpec.vertical()
        topStack.children = [titleStack, postTextNode]
        topStack.spacing = 4.0
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [topStack]
        contentStack.spacing = 2.0
        
        let contentInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: contentStack)
   
        
        
        let mainInsetSpec = ASInsetLayoutSpec(insets: mainInsets, child: contentInset)
        let dividerStack = ASStackLayoutSpec.vertical()
        dividerStack.children = [mainInsetSpec, dividerNode]
        return dividerStack
    }
    
    var likesRef:DatabaseReference?
    var likesRefHandle:DatabaseHandle?
    var commentsRef:DatabaseReference?
    var commentsRefHandle:DatabaseHandle?
    
    var likedRef:DatabaseReference?
    var likedRefHandle:DatabaseHandle?
    
    func observePost() {
        guard let post = self.post, !post.deleted else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        likesRef = database.child("posts/meta/\(post.key)/numLikes")
        likesRefHandle = likesRef?.observe(.value, with: { snapshot in
            post.numLikes = snapshot.value as? Int ?? 0
            self.actionsRow.setNumLikes(post.numLikes)
        })
        
        likedRef = database.child("posts/likes/\(post.key)/\(uid)")
        likedRefHandle = likedRef?.observe(.value, with: { snapshot in
            post.liked = snapshot.value as? Bool ?? false
            self.actionsRow.setLiked(post.liked, animated: false)
        })
        
//        commentsRef = database.child("posts/meta/\(post.key)/numReplies")
//        commentsRefHandle = commentsRef?.observe(.value, with: { snapshot in
//            post.numReplies = snapshot.value as? Int ?? 0
//        })
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
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        stopObservingPost()
    }
}

extension PostCommentCellNode: PostActionsDelegate {
    func openTag(_ tag: String) {
        
    }
    
    func handleLocationButton() {
        
    }
    
    func handleMoreButton() {
        guard let post = self.post else { return }
        delegate?.handleMore(post)
    }
    
    func handleLikeButton() {
        print("liked!")
        guard let post = self.post, !post.deleted else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = database.ref.child("posts/likes/\(post.key)/\(uid)")
        post.liked = !post.liked
        if post.liked {
            post.numLikes += 1
            actionsRow.setNumLikes(post.numLikes)
            ref.setValue(true)
        } else {
            post.numLikes -= 1
            actionsRow.setNumLikes(post.numLikes)
            ref.setValue(false)
        }
    }
    
    func handleCommentButton() {
        guard let post = self.post, !post.deleted else { return }
        delegate?.handleReply(post)
    }
    
    func setHighlighted(_ highlighted:Bool) {
        backgroundColor = highlighted ? UIColor(white: 0.92, alpha: 1.0) : UIColor.white
    }
}
