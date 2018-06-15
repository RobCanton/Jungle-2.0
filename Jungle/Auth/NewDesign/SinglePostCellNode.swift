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

class AvatarNode:ASDisplayNode {
    var backNode = ASDisplayNode()
    var imageNode = ASNetworkImageNode()
    var imageInset:CGFloat = 5.0
    
    required init(post:Post, cornerRadius: CGFloat, imageInset:CGFloat) {
        super.init()
        automaticallyManagesSubnodes = true
        self.imageInset = imageInset
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        
        backgroundColor = UIColor.white
        backNode.backgroundColor = post.anon.color.withAlphaComponent(0.30)
        imageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: post.anon.color) ?? image
        }
        
        UserService.retrieveAnonImage(withName: post.anon.animal.lowercased()) { image, fromFile in
            print("GOT ANON ICON FROMFILE: \(fromFile)")
            self.imageNode.image = image
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
    var timeNode = ASTextNode()
    
    var actionsRow:SinglePostActionsView!
    weak var delegate:PostActionsDelegate?
    weak var post:Post?
    required init(post:Post, delegate: PostActionsDelegate?) {
        super.init()
        self.post = post
        self.delegate = delegate
        automaticallyManagesSubnodes = true
        postTextNode.maximumNumberOfLines = 0
        postTextNode.setText(text: post.textClean, withSize: 15.0, normalColor: .white, activeColor: tagColor)
        
        usernameNode.attributedText = NSAttributedString(string: post.anon.displayName , attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: post.anon.color
            ])
        
        timeNode.attributedText = NSAttributedString(string: post.createdAt.fullTimeSinceNow() , attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        
        avatarNode = AvatarNode(post: post, cornerRadius: 16, imageInset: 5)
        avatarNode.style.height = ASDimension(unit: .points, value: 32)
        avatarNode.style.width = ASDimension(unit: .points, value: 32)
        
        
    }
    
    var locationButton:UIButton!
    override func didLoad() {
        super.didLoad()
        actionsRow = SinglePostActionsView(frame: .zero)
        actionsRow.delegate = delegate
        view.addSubview(actionsRow)
        usernameNode.view.applyShadow(radius: 4.0, opacity: 0.1, offset: .zero, color: UIColor.black, shouldRasterize: false)
        actionsRow.translatesAutoresizingMaskIntoConstraints = false
        actionsRow.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
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

        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let centerUsername = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: usernameNode)
        let centerTime = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: timeNode)
        
        let labelStack = ASStackLayoutSpec.vertical()
        labelStack.children = [usernameNode, timeNode]
        
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.children = [avatarNode, labelStack]
        titleStack.spacing = 8.0
        
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [titleStack, postTextNode]
        contentStack.spacing = 8.0
        
        let mainInsets = UIEdgeInsetsMake(12, 12, 64, 12)
        return ASInsetLayoutSpec(insets: mainInsets, child: contentStack)
    }
    
    func setNumLikes(_ likes:Int) {
        actionsRow.likeLabel.text = "\(likes)"
    }
    
    func setNumComments(_ comments:Int) {
        actionsRow.commentLabel.text = "\(comments)"
    }
}

protocol SinglePostDelegate:class {
    func openComments(_ post:Post,_ showKeyboard:Bool)
}

class SinglePostCellNode: ASCellNode, ASTableDelegate, ASTableDataSource, PostActionsDelegate {
    
    var contentNode:PostContentNode!
    var contentOverlay:ContentOverlayNode!
    weak var delegate:SinglePostDelegate?
    var post:Post?
    
    var commentNode:PostCommentCellNode!
    required init(post:Post) {
        super.init()
        self.post = post
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor.black
        contentNode = PostContentNode(post: post)
        contentOverlay = ContentOverlayNode(post: post, delegate: self)
        contentOverlay.addTarget(self, action: #selector(handleOverlayTap), forControlEvents: .touchUpInside)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let overlayStack = ASStackLayoutSpec.vertical()
        overlayStack.children = [contentOverlay]
        overlayStack.alignContent = .end
        overlayStack.justifyContent = .end
        
        let overlay = ASOverlayLayoutSpec(child: contentNode, overlay: overlayStack)
        return ASInsetLayoutSpec(insets: .zero, child: overlay)
    }
    
    @objc func handleOverlayTap() {
        guard let post = self.post else { return }
        delegate?.openComments(post, false)
    }
    
    func handleLikeButton() {
        print("liked!")
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = database.ref.child("posts/likes/\(post.key)/\(uid)")
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
        print("openComments!")
        guard let post = self.post else { return }
        delegate?.openComments(post, true)
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
        
        commentsRef = database.child("posts/meta/\(post.key)/replies")
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
    
}
