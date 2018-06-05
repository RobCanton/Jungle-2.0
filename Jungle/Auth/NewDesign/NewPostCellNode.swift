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

class NewPostCellNode:ASCellNode {
    
    var videoNode = ASVideoNode()
    var imageNode = ASNetworkImageNode()
    var previewBox = ASDisplayNode()
    var titleNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var postTextNode = ASTextNode()
    var timeNode = ASTextNode()
    var moreButton = ASButtonNode()
    
    var likeButton = ASButtonNode()
    var commentButton = ASButtonNode()
    var post:Post?
    
    required init(post:Post) {
        super.init()
        self.post = post
        self.style.height = ASDimension(unit: .points, value: 144)
        self.backgroundColor = UIColor.clear
        automaticallyManagesSubnodes = true
        videoNode.backgroundColor = UIColor.blue
        imageNode.backgroundColor = hexColor(from: "BEBEBE")
        imageNode.url = post.attachments?.video?.thumbnail_url
        previewBox.backgroundColor = nil
        previewBox.automaticallyManagesSubnodes = true
        previewBox.layoutSpecBlock = { _, _ in
            let overlay = ASOverlayLayoutSpec(child: self.videoNode, overlay: self.imageNode)
            return ASInsetLayoutSpec(insets: .zero, child: overlay)
        }
        
        titleNode.attributedText = NSAttributedString(string: post.anon.displayName.uppercased(), attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.black
            ])
        
        timeNode.attributedText = NSAttributedString(string: post.createdAt.timeSinceNow(), attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: hexColor(from: "BEBEBE")
            ])
        
        subtitleNode.attributedText = NSAttributedString(string: "Music Discussion", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        
        postTextNode.maximumNumberOfLines = 3
        postTextNode.attributedText = NSAttributedString(string: post.textClean, attributes: [
            NSAttributedStringKey.font: Fonts.light(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.black
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
        commentButton.setImage(UIImage(named:"comment_small"), for: .normal)
        commentButton.contentSpacing = 2.0
        commentButton.contentHorizontalAlignment = .middle
        let commentTitle = NSMutableAttributedString(string: "7", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: hexColor(from: "BEBEBE")
            ])
        commentButton.setAttributedTitle(commentTitle, for: .normal)
        
        
        moreButton.setImage(UIImage(named:"more"), for: .normal)
        
    }
    
    override func didLoad() {
        super.didLoad()
        videoNode.layer.cornerRadius = 4.0
        videoNode.clipsToBounds = true
        imageNode.layer.cornerRadius = 4.0
        imageNode.clipsToBounds = true
//        previewBox.clipsToBounds = false
//        previewBox.view.applyShadow(radius: 4.0, opacity: 0.20, offset: CGSize(width: 0, height: 4.0), color: .black, shouldRasterize: false)
//        self.clipsToBounds = false
        
    }
    
    var gapNode = ASDisplayNode()
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        gapNode.style.flexGrow = 1.0
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.children = [titleNode, timeNode ]
        titleStack.alignContent = .spaceBetween
        titleStack.justifyContent = .spaceBetween
        
        let actionStack = ASStackLayoutSpec.horizontal()
        actionStack.children = [likeButton, commentButton]
        actionStack.spacing = 18.0
        let actionRow = ASStackLayoutSpec.horizontal()
        actionRow.children = [actionStack]
        actionRow.alignContent = .spaceBetween
        actionRow.justifyContent = .spaceBetween
        
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [titleStack, subtitleNode, postTextNode, gapNode, actionRow]
        contentStack.style.width = ASDimension(unit: .fraction, value: 0.70)
        previewBox.style.width = ASDimension(unit: .fraction, value: 0.3)
        let stack = ASStackLayoutSpec.horizontal()
        stack.children = [previewBox, contentStack]
        stack.spacing = 12
        let mainInsets = UIEdgeInsetsMake(12, 12, 12, 24)
    
        return ASInsetLayoutSpec(insets: mainInsets, child: stack)
    }
}
