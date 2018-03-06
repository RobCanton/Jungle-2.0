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

protocol CommentCellDelegate:class {
    func handleReply(_ reply:Reply)
}

class CommentCellNode:ASCellNode {
    
    let gradientColorTop = accentColor
    let gradientColorBot = hexColor(from: "#22D29F")
    
    var imageNode = ASNetworkImageNode()
    var titleNode = ASTextNode()
    var subnameNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var postTextNode = ActiveTextNode()
    var actionsNode = ASDisplayNode()
    var dividerNode = ASDisplayNode()
    var rankButton = ASButtonNode()
    
    let likeButton = ASButtonNode()
    let dislikeButton = ASButtonNode()
    let commentButton = ASButtonNode()
    let moreButtonNode = ASButtonNode()
    
    var replyImageNode = ASRoundShadowedImageNode(imageCornerRadius: 12.0, imageShadowRadius: 0.0)
    var replyTitleNode = ASTextNode()
    
    let groupNode = ASButtonNode()
    
    let countLabel = ASTextNode()
    var postImageNode = ASRoundShadowedImageNode(imageCornerRadius: 18.0, imageShadowRadius: 8.0)
    
    var transitionManager = LightboxViewerTransitionManager()
    weak var delegate:CommentCellDelegate?
    weak var reply:Reply?
    weak var post:Post?
    
    let gapNode = ASDisplayNode()
    
    var isReply = false
    
    static let mainInsets = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 0.0, right: 16.0)
    static let replyInsets = UIEdgeInsets(top: 4.0, left: 16.0, bottom: 0.0, right: 16.0)

    
    private(set) var bgColor = UIColor.white
    private(set) var textColor = UIColor.gray
    private(set) var buttonColor = grayColor
    private(set) var upvoteImage:UIImage!
    private(set) var upvotedImage:UIImage!
    private(set) var downvoteImage:UIImage!
    private(set) var downvotedImage:UIImage!
    private(set) var commentImage:UIImage!
    private(set) var moreImage:UIImage!
    

    
    required init(reply:Reply, toPost post:Post, isReply:Bool?=nil, hideDivider:Bool?=nil) {
        super.init()

        self.reply = reply
        self.post = post
        self.isReply = isReply != nil ? isReply! : false
        
        automaticallyManagesSubnodes = true
        
        upvoteImage = UIImage(named:"upvote")
        upvotedImage = UIImage(named:"upvoted")
        downvoteImage = UIImage(named:"downvote")
        downvotedImage = UIImage(named:"downvoted")
        commentImage = UIImage(named:"reply")
        moreImage = UIImage(named:"more")
        
    
        backgroundColor = bgColor
        
        imageNode.backgroundColor = reply.anon.color
        
        postImageNode.isUserInteractionEnabled = true
        
        titleNode.attributedText = NSAttributedString(string: reply.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: textColor
            ])
        
        subnameNode.attributedText = NSAttributedString(string: "YOU", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 10.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        subnameNode.textContainerInset = UIEdgeInsets(top: 1.0, left: 6.0, bottom: 0, right: 6.0)
        subnameNode.backgroundColor = reply.anon.color
        subnameNode.isHidden = true
        

        let subtitleStr = "\(reply.createdAt.timeSinceNow())"
        
        subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: textColor
            ])
        
        postTextNode.maximumNumberOfLines = 0
        postTextNode.truncationMode = .byWordWrapping
        
        postTextNode.setText(text: reply.text, withFont: Fonts.medium(ofSize: 15.0), normalColor: textColor, activeColor: accentColor)
        postTextNode.tapHandler = { type, textValue in
           
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "-", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: buttonColor,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
        
//
//        if let attachments = post.attachments {
//            if attachments.images.count > 0 {
//                let image = attachments.images[0]
//                let color =  hexColor(from: image.colorHex)
//                postImageNode.mainImageNode.backgroundColor = color
//                postImageNode.mainImageNode.url = image.url
//                postImageNode.style.height = ASDimension(unit: .points, value: 192)
//                postImageNode.applyShadow(withColor: color, opacity: 0.5)
//            }
//        } else {
//            postImageNode.style.height = ASDimension(unit: .points, value: 0.0)
//        }
        
        dividerNode.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        if let hideDivider = hideDivider {
            dividerNode.isHidden = hideDivider
        } else {
            dividerNode.isHidden = reply.numReplies > 0 || self.isReply
        }
        
        likeButton.setImage(upvoteImage, for: .normal)
        likeButton.laysOutHorizontally = true
        likeButton.contentSpacing = 6.0
        likeButton.contentHorizontalAlignment = .middle
        likeButton.contentEdgeInsets = .zero
        likeButton.tintColor = buttonColor
        likeButton.tintColorDidChange()
        likeButton.alpha = 0.75
        
        dislikeButton.setImage(downvoteImage, for: .normal)
        dislikeButton.laysOutHorizontally = true
        dislikeButton.contentSpacing = 6.0
        dislikeButton.contentHorizontalAlignment = .middle
        dislikeButton.contentEdgeInsets = .zero
        dislikeButton.tintColor = buttonColor
        dislikeButton.tintColorDidChange()
        dislikeButton.alpha = 0.75
        
        commentButton.setImage(commentImage, for: .normal)
        commentButton.laysOutHorizontally = true
        commentButton.contentSpacing = 8.0
        commentButton.contentHorizontalAlignment = .middle
        commentButton.alpha = 0.75
        countLabel.alpha = 0.75
       
        moreButtonNode.setImage(moreImage, for: .normal)
        moreButtonNode.contentHorizontalAlignment = .right
        
        commentButton.addTarget(self, action: #selector(handleReply), forControlEvents: .touchUpInside)
        
        replyImageNode.style.width = ASDimension(unit: .points, value: 24)
        replyImageNode.style.height = ASDimension(unit: .points, value: 24)
        
        titleNode.tintColor = UIColor.gray
        titleNode.tintColorDidChange()
        
        setTitle("SillyDeer Replied · \(reply.numReplies) Replies")
        
    }
    
    override func didLoad() {
        super.didLoad()
        subnameNode.layer.cornerRadius = 8
        subnameNode.clipsToBounds = true
        selectionStyle = .none
        
        imageNode.clipsToBounds = true
        
        if self.isReply {
            imageNode.layer.cornerRadius = 12.0
        } else {
            imageNode.layer.cornerRadius = 18.0
        }
        
    }
    
    func setTitle(_ text:String) {
        let attrTitle = NSAttributedString(string: text, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        replyTitleNode.attributedText = attrTitle
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        likeButton.style.height = ASDimension(unit: .points, value: 32.0)
        dislikeButton.style.height = ASDimension(unit: .points, value: 32.0)
        commentButton.style.height = ASDimension(unit: .points, value: 32.0)
        
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
    
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
        
        var leadingInset:CGFloat = 36 + 8
        var imageLeadingInset:CGFloat = 0
        var imageNodeSize:CGFloat = 36.0
        var mainInsets = CommentCellNode.mainInsets
        
        if isReply {
            leadingInset += 24 + 8
            imageLeadingInset += 42
            imageNodeSize = 24.0
            mainInsets = CommentCellNode.replyInsets
        }
        
        let centerTitle = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleNode)
        let centerSubtitle = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subtitleNode)

        var nameStack:ASStackLayoutSpec!
        if isReply {
            nameStack = ASStackLayoutSpec.horizontal()
            nameStack.spacing = 6.0
        } else {
            nameStack = ASStackLayoutSpec.vertical()
            nameStack.spacing = 2.0
        }
        nameStack.children = [centerTitle, centerSubtitle]
        
        let imageStack = ASStackLayoutSpec.horizontal()
        imageStack.children = [imageNode, nameStack]
        imageStack.spacing = 8.0
        
        let countCenterY = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: countLabel)
        let likeStack = ASStackLayoutSpec.horizontal()
        likeStack.children = [ likeButton, countCenterY, dislikeButton ]
        likeStack.spacing = 0.0
        
        countLabel.style.width = ASDimension(unit: .points, value: 28.0)
        countLabel.style.flexGrow = 1.0
        likeButton.style.flexShrink = 1.0
        dislikeButton.style.flexShrink = 1.0
        likeStack.style.width = ASDimension(unit: .fraction, value: 0.35)
        commentButton.style.width = ASDimension(unit: .fraction, value: 0.35)
        
        let actionsRow = ASStackLayoutSpec.horizontal()
        
        actionsRow.children = [ likeStack]
        actionsRow.spacing = 8.0
        
        if !self.isReply {
            actionsRow.children?.append(commentButton)
        }
        
        imageNode.style.width = ASDimension(unit: .points, value: imageNodeSize)
        imageNode.style.height = ASDimension(unit: .points, value: imageNodeSize)
        
        let imageInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, imageLeadingInset, 0, 0), child: imageStack)
        
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [imageInset]
        contentStack.spacing = 6.0
        
        let textInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, leadingInset, 0, 0.0), child: postTextNode)
        
        if let text = reply?.text, !text.isEmpty {
            contentStack.children?.append(textInset)
        }
        
        let actionsInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, leadingInset, 0, 16.0), child: actionsRow)
        contentStack.children?.append(actionsInset)
        
        let centerReplyImage = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: replyImageNode)
        let centerReplyTitle = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: replyTitleNode)
        let replyStack = ASStackLayoutSpec.horizontal()
        replyStack.children = [centerReplyImage, centerReplyTitle]
        replyStack.spacing = 8.0
//        let replyInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, leadingInset, 0, 0.0), child: replyStack)
//        if let reply = self.reply, reply.numReplies > 0 {
//            contentStack.children?.append(replyInset)
//        }
        
        let mainInset = ASInsetLayoutSpec(insets: mainInsets, child: contentStack)
        let mainVerticalStack = ASStackLayoutSpec.vertical()
        mainVerticalStack.children = [mainInset, dividerNode]
        mainVerticalStack.spacing = 4.0
        
        return mainVerticalStack
    }

    
    @objc func handleReply() {
        guard let reply = self.reply else { return }
        delegate?.handleReply(reply)
    }
    
    func setHighlighted(_ highlighted:Bool) {
        print("setHighlighted: \(highlighted)")
        backgroundColor = highlighted ? UIColor(white: 0.95, alpha: 1.0) : bgColor
    }
    
    func setSelected(_ selected:Bool) {
        print("setSelected: \(selected)")
        backgroundColor = selected ? UIColor(white: 0.95, alpha: 1.0) : bgColor
    }
    
}

