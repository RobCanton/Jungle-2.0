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

class CommentActionsRow: UIView {
    var likeButton:WCLShineButton!
    var likeLabel:UILabel!
    
    var moreButton:UIButton!
    
    weak var delegate:PostActionsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = UIColor.blue.withAlphaComponent(0.0)
        
        var param1 = WCLShineParams()
        param1.allowRandomColor = true
        param1.animDuration = 1
        param1.enableFlashing = false
        param1.shineDistanceMultiple = 0.9
        param1.colorRandom =  [UIColor(rgb: (255, 204, 204)),
                               UIColor(rgb: (255, 102, 102)),
                               UIColor(rgb: (255, 102, 102))]
        param1.shineSize = 4
        
        likeButton = WCLShineButton(frame: .init(x: 0, y: 0, width: 32, height: 32), params: param1)
        likeButton.color = hexColor(from: "BEBEBE")
        likeButton.fillColor = UIColor(rgb: (255, 102, 102))
        likeButton.image = WCLShineImage.custom(UIImage(named:"like")!)
        addSubview(likeButton)
        //likeButton.addTarget(self, action: #selector(action), for: .valueChanged)
    
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        likeButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        likeButton.heightAnchor.constraint(equalTo: likeButton.widthAnchor, multiplier: 1.0).isActive = true
        likeButton.addTarget(self, action: #selector(handleLike), for: .valueChanged)
        likeLabel = UILabel(frame: .zero)
        likeLabel.text = "0"
        likeLabel.textColor = hexColor(from: "BEBEBE")
        likeLabel.font = Fonts.semiBold(ofSize: 14.0)
        addSubview(likeLabel)
        likeLabel.translatesAutoresizingMaskIntoConstraints = false
        likeLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 2.0).isActive = true
        likeLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor).isActive = true
        
        moreButton = UIButton(type: .custom)
        moreButton.setImage(UIImage(named:"more"), for: .normal)
        addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        moreButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        moreButton.heightAnchor.constraint(equalTo: moreButton.widthAnchor, multiplier: 1.0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleLike() {
        delegate?.handleLikeButton()
    }
    
    
    func setLiked(_ liked:Bool, animated:Bool) {
        if liked {
            likeButton.setClicked(true, animated: animated)
        } else {
            likeButton.setClicked(false, animated: animated)
        }
    }
    
    func setNumLikes(_ numLikes:Int) {
        likeLabel.text = "\(numLikes)"
    }
}

class PostCommentCellNode: ASCellNode {
    
    var postTextNode = ActiveTextNode()
    var avatarNode = ASDisplayNode()
    var avatarImageNode = ASNetworkImageNode()
    var usernameNode = ASTextNode()
    var dividerNode = ASDisplayNode()
    var timeNode = ASTextNode()
    
    var likeButton = ASButtonNode()
    var commentButton = ASButtonNode()
    var moreButton = ASButtonNode()
    
    var post:Post?
    var contentHeight:CGFloat = 0.0
    
    required init(post:Post, isCaption:Bool?=nil) {
        super.init()
        self.post = post
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor.white
        postTextNode.maximumNumberOfLines = 0
        postTextNode.setText(text: post.textClean, withSize: 15.0, normalColor: .black, activeColor: tagColor)
        
        usernameNode.attributedText = NSAttributedString(string: post.anon.displayName , attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: post.anon.color
            ])
        
        timeNode.attributedText = NSAttributedString(string: post.createdAt.timeSinceNow() , attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: UIColor.black.withAlphaComponent(0.5)
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
        
        avatarNode.backgroundColor = post.anon.color.withAlphaComponent(0.30)
        avatarImageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: post.anon.color) ?? image
        }
        //        avatarNode.image = UIImage(named:"sparrow")
        avatarNode.style.height = ASDimension(unit: .points, value: 24)
        avatarNode.style.width = ASDimension(unit: .points, value: 24)
        avatarNode.layer.cornerRadius = 12
        avatarImageNode.image = nil
        UserService.retrieveAnonImage(withName: post.anon.animal.lowercased()) { image, _ in
            self.avatarImageNode.image = image
        }
    }
    
    var actionsRow:CommentActionsRow!
    override func didLoad() {
        super.didLoad()
        actionsRow = CommentActionsRow(frame:.zero)
        actionsRow.delegate = self
        view.addSubview(actionsRow)
        actionsRow.translatesAutoresizingMaskIntoConstraints = false
        actionsRow.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        actionsRow.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        actionsRow.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        actionsRow.heightAnchor.constraint(equalToConstant: 40).isActive = true
        if let post = post {
            actionsRow.setLiked(post.liked, animated: false)
            actionsRow.setNumLikes(post.numLikes)
        }
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let avatarInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(3, 3, 3, 3), child: avatarImageNode)
        let avatarOverlay = ASOverlayLayoutSpec(child: avatarNode, overlay: avatarInset)
        
        let titleCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: usernameNode)
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.spacing = 8.0
        titleStack.children = [avatarOverlay, titleCenter]
        
        let actionStack = ASStackLayoutSpec.horizontal()
        actionStack.children = [commentButton, moreButton]
        actionStack.spacing = 24.0
        //actionStack.alignContent = .spaceBetween
        actionStack.justifyContent = .end
        let actionsInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: actionStack)
        
        let topStack = ASStackLayoutSpec.vertical()
        topStack.children = [titleStack, postTextNode]
        topStack.spacing = 4.0
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [topStack]
        contentStack.spacing = 2.0
        
        let contentInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: contentStack)
   
        let mainInsets = UIEdgeInsetsMake(12, 12, 44, 12)
        return ASInsetLayoutSpec(insets: mainInsets, child: contentInset)
    }
    
    var likesRef:DatabaseReference?
    var likesRefHandle:DatabaseHandle?
    var commentsRef:DatabaseReference?
    var commentsRefHandle:DatabaseHandle?
    
    var likedRef:DatabaseReference?
    var likedRefHandle:DatabaseHandle?
    
    func observePost() {
        guard let post = self.post else { return }
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
        
        commentsRef = database.child("posts/meta/\(post.key)/replies")
        commentsRefHandle = commentsRef?.observe(.value, with: { snapshot in
            post.numReplies = snapshot.value as? Int ?? 0
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
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        stopObservingPost()
    }
}

extension PostCommentCellNode: PostActionsDelegate {
    func handleLikeButton() {
        print("liked!")
        guard let post = self.post else { return }
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
        //
    }
    
    
}
