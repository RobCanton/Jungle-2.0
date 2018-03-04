//
//  CommentCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit
import Firebase

class CommentCellNode:ASCellNode {

    
    static let mainInsets = UIEdgeInsets(top: 0, left: 16.0, bottom: 10.0, right: 16.0)
    
    var imageNode = ASRoundShadowedImageNode(imageCornerRadius: 18, imageShadowRadius: 0.0)
    let subnameNode = ASTextNode()
    var commentBubbleNode = CommentBubbleNode()
    var isFirst = false
    
    let likeButton = ASButtonNode()
    let dislikeButton = ASButtonNode()
    let countLabel = ASTextNode()
    
    let replyButton = ASButtonNode()
    
    let gapNode = ASDisplayNode()

    private(set) var upvoteImage:UIImage!
    private(set) var upvotedImage:UIImage!
    private(set) var downvoteImage:UIImage!
    private(set) var downvotedImage:UIImage!
    private(set) var buttonColor = grayColor
    
    var lexiconRefListener:ListenerRegistration?
    
    weak var reply:Reply?
    weak var post:Post?
    
    required init(withReply reply:Reply, toPost post:Post, isFirst:Bool?=nil) {
        super.init()
        self.reply = reply
        self.post = post
        self.isFirst = isFirst ?? false
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        commentBubbleNode.set(reply: reply, toPost: post)
        imageNode.mainImageNode.backgroundColor = reply.anon.color
        
        upvoteImage = UIImage(named:"upvote")
        upvotedImage = UIImage(named:"upvoted")
        downvoteImage = UIImage(named:"downvote")
        downvotedImage = UIImage(named:"downvoted")
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "-", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: buttonColor,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
        
        likeButton.setImage(upvoteImage, for: .normal)
        likeButton.laysOutHorizontally = true
        likeButton.contentSpacing = 6.0
        likeButton.contentHorizontalAlignment = .middle
        likeButton.contentEdgeInsets = .zero
        likeButton.tintColor = buttonColor
        likeButton.tintColorDidChange()
        
        dislikeButton.setImage(downvoteImage, for: .normal)
        dislikeButton.laysOutHorizontally = true
        dislikeButton.contentSpacing = 6.0
        dislikeButton.contentHorizontalAlignment = .middle
        dislikeButton.contentEdgeInsets = .zero
        dislikeButton.tintColor = buttonColor
        dislikeButton.tintColorDidChange()
        
        replyButton.setImage(UIImage(named:"reply"), for: .normal)
        replyButton.tintColor = buttonColor
        replyButton.tintColorDidChange()
        
    
        
        subnameNode.textContainerInset = UIEdgeInsets(top: 1.0, left: 6.0, bottom: 0, right: 6.0)
        
        
       /// assignAnonymous(reply: reply, toPost: post)
        
    }
    
    
    override func didLoad() {
        super.didLoad()
        subnameNode.layer.cornerRadius = 8
        subnameNode.clipsToBounds = true
        selectionStyle = .none
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        imageNode.style.width = ASDimension(unit: .points, value: 36)
        imageNode.style.height = ASDimension(unit: .points, value: 36)
        //commentBubbleNode.style.height = ASDimension(unit: .points, value: 90.0)
        
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)

        likeButton.style.height = ASDimension(unit: .points, value: 32.0)
        dislikeButton.style.height = ASDimension(unit: .points, value: 32.0)
        replyButton.style.height = ASDimension(unit: .points, value: 32.0)
        
        let subnameCenterX = ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: .minimumX, child: subnameNode)
        let imageStack = ASStackLayoutSpec.vertical()
        imageStack.children = [imageNode, subnameCenterX]
        imageStack.spacing = 6.0
        imageStack.style.layoutPosition = CGPoint(x: 0, y: 0)
        
        let countCenterY = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: countLabel)
        let likeStack = ASStackLayoutSpec.horizontal()
        likeStack.children = [ likeButton, countCenterY, dislikeButton ]
        likeStack.spacing = 0.0
        
        countLabel.style.width = ASDimension(unit: .points, value: 28.0)
        countLabel.style.flexGrow = 1.0
        likeButton.style.flexShrink = 1.0
        dislikeButton.style.flexShrink = 1.0
        
        let actionsRow = ASStackLayoutSpec.horizontal()
        
        actionsRow.children = [ likeStack,  replyButton]
        actionsRow.spacing = 32.0
        
        let actionsInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 16.0), child: actionsRow)
        
        let mainVerticalStack = ASStackLayoutSpec.vertical()
        mainVerticalStack.children = [commentBubbleNode, actionsInset]
        mainVerticalStack.spacing = 0.0
        mainVerticalStack.style.layoutPosition = CGPoint(x: 44.0 + 10.0, y: 0)
        
        let abs = ASAbsoluteLayoutSpec(children: [imageStack, mainVerticalStack])
        
        return ASInsetLayoutSpec(insets: CommentCellNode.mainInsets, child: abs)
    }
    
    func setSubname(title:String, color:UIColor) {
        subnameNode.attributedText = NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 11.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        subnameNode.backgroundColor = color
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        if let reply = reply, let post = post {
            listenTo(reply: reply, toPost: post)
        }
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        stopListeningToPost()
    }
    
    func listenTo(reply:Reply, toPost post:Post) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let postRef = firestore.collection("posts").document(post.key)
        let lexiconRef = postRef.collection("lexicon").document(uid)
        
        lexiconRefListener = lexiconRef.addSnapshotListener { lexiconSnapshot, error in
            guard let document = lexiconSnapshot else { return }
            
            if let data = document.data(),
                let anon = Anon.parse(data) {
                self.assignAnonymous(replyAnon: reply.anon, postAnon: post.anon, myAnon: anon)
            } else {
                self.assignAnonymous(replyAnon: reply.anon, postAnon: post.anon, myAnon:nil)
            }
        }
    }
    
    func stopListeningToPost() {
        lexiconRefListener?.remove()
    }
    
    func assignAnonymous(replyAnon:Anon, postAnon:Anon, myAnon:Anon?) {
        if let myAnon = myAnon, myAnon.key == replyAnon.key {
                setSubname(title: "YOU", color: replyAnon.color)
                subnameNode.isHidden = false
        } else if replyAnon.key == postAnon.key {
            setSubname(title: "OP", color: replyAnon.color)
            subnameNode.isHidden = false
        } else {
            subnameNode.isHidden = true
        }
    }
}

class CommentBubbleNode:ASDisplayNode {
    
    var bubbleNode = ContentBubbleNode()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        bubbleNode.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        bubbleNode.layer.cornerRadius = 16.0
        self.clipsToBounds = false
    }
    
    func set(reply:Reply, toPost post:Post) {
        bubbleNode.set(reply: reply, toPost: post)
    }
    
    override func didLoad() {
        super.didLoad()
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        let color = UIColor(white: 0.0, alpha: 1.0)
        let offset = CGSize(width: 0, height: 8.0)
        //view.applyShadow(radius: 8.0, opacity: 0.06, offset: offset, color: color, shouldRasterize: false)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: bubbleNode)
    }
}

class ContentBubbleNode:ASDisplayNode {
    
    let titleNode = ASTextNode()
    let timeNode = ASTextNode()
    let postTextNode = ASTextNode()

    
    func set(reply:Reply, toPost post:Post) {
        titleNode.attributedText = NSAttributedString(string: reply.anon.displayName , attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        
    
        //subnameNode.isHidden = true
        
        postTextNode.attributedText = NSAttributedString(string: reply.text, attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        
        timeNode.attributedText = NSAttributedString(string: " · \(reply.createdAt.timeSinceNow())", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
    
    }
    
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        
        postTextNode.maximumNumberOfLines = 0
        postTextNode.truncationMode = .byWordWrapping
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let timeInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(1.5, 0, 0, 0), child: timeNode)
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.children = [titleNode, timeInset]
        
        let textStack = ASStackLayoutSpec.vertical()
        textStack.children = [ titleStack, postTextNode ]
        textStack.spacing = 2.0
        
        
        let insets = UIEdgeInsetsMake(8.0, 12.0, 8.0, 12.0)
        return ASInsetLayoutSpec(insets: insets, child: textStack)
    }
}
