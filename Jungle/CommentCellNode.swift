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

class CommentCellNode:ASCellNode {

    
    static let mainInsets = UIEdgeInsets(top: 0, left: 16.0, bottom: 10.0, right: 16.0)
    
    var imageNode = ASRoundShadowedImageNode(imageCornerRadius: 18, imageShadowRadius: 0.0)
    
    var commentBubbleNode = CommentBubbleNode()
    var isFirst = false
    
    let likeButtonNode = ASButtonNode()
    let shareButtonNode = ASButtonNode()
    let moreButtonNode = ASButtonNode()
    
    let timeNode = ASTextNode()
    
    required init(withReply reply:Reply, isFirst:Bool?=nil) {
        super.init()
        self.isFirst = isFirst ?? false
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        commentBubbleNode.set(reply: reply)
        imageNode.imageNode.backgroundColor = reply.anon.color
        
        likeButtonNode.setImage(UIImage(named:"heart"), for: .normal)
        shareButtonNode.setImage(UIImage(named:"reply"), for: .normal)
        moreButtonNode.setImage(UIImage(named:"more"), for: .normal)
    
        timeNode.attributedText = NSAttributedString(string: reply.createdAt.timeSinceNow(), attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
    }
    
    override func didLoad() {
        super.didLoad()
        
        selectionStyle = .none
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        imageNode.style.width = ASDimension(unit: .points, value: 36)
        imageNode.style.height = ASDimension(unit: .points, value: 36)
        imageNode.style.layoutPosition = CGPoint(x: 8.0, y: 0)
        //commentBubbleNode.style.height = ASDimension(unit: .points, value: 90.0)

        let centerTime = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: timeNode)
        let leftActions = ASStackLayoutSpec.horizontal()
        leftActions.children = [centerTime, likeButtonNode, shareButtonNode]
        leftActions.spacing = 10.0
        
        let insetActions = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 12.0, 0.0, 0.0), child: leftActions)
        
        let mainVerticalStack = ASStackLayoutSpec.vertical()
        mainVerticalStack.children = [commentBubbleNode, insetActions]
        mainVerticalStack.spacing = 0.0
        mainVerticalStack.style.layoutPosition = CGPoint(x: 44.0 + 12.0, y: 0)
        
        let abs = ASAbsoluteLayoutSpec(children: [imageNode, mainVerticalStack])
        
        return ASInsetLayoutSpec(insets: CommentCellNode.mainInsets, child: abs)
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
    
    func set(reply:Reply) {
        bubbleNode.set(reply: reply)
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

    
    func set(reply:Reply) {
        titleNode.attributedText = NSAttributedString(string: reply.anon.displayName , attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        
        postTextNode.attributedText = NSAttributedString(string: reply.text, attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        
        timeNode.attributedText = NSAttributedString(string: reply.createdAt.timeSinceNow(), attributes: [
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
        
        titleNode.style.flexGrow = 1.0

        let titleRow = ASStackLayoutSpec.horizontal()
        titleRow.children = [ titleNode]
        titleRow.spacing = 8.0
        
        let textStack = ASStackLayoutSpec.vertical()
        textStack.children = [ titleRow, postTextNode ]
        textStack.spacing = 2.0
//        let verticalStack = ASStackLayoutSpec.vertical()
//        verticalStack.children = [ insetText, actionsRow ]
//        verticalStack.spacing = 2.0
        
        
        let insets = UIEdgeInsetsMake(8.0, 12.0, 8.0, 12.0)
        return ASInsetLayoutSpec(insets: insets, child: textStack)
    }
}
