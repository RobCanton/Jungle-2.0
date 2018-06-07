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
    
    var avatarNode = ASNetworkImageNode()
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
        self.backgroundColor = UIColor.white
        automaticallyManagesSubnodes = true
        videoNode.backgroundColor = UIColor.blue
        imageNode.backgroundColor = hexColor(from: "BEBEBE")
        previewBox.style.height = ASDimension(unit: .points, value: 100)
        if let images = post.attachments?.images, images.count > 0 {
            imageNode.url = images[0].url
            previewBox.style.height = ASDimension(unit: .points, value: 100)
        } else if let video = post.attachments?.video {
            imageNode.url = video.thumbnail_url
            previewBox.style.height = ASDimension(unit: .points, value: 130)
        }
        
        previewBox.backgroundColor = nil
        previewBox.automaticallyManagesSubnodes = true
        previewBox.layoutSpecBlock = { _, _ in
            let overlay = ASOverlayLayoutSpec(child: self.videoNode, overlay: self.imageNode)
            return ASInsetLayoutSpec(insets: .zero, child: overlay)
        }
        
        titleNode.attributedText = NSAttributedString(string: post.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.black
            ])
        
        timeNode.attributedText = NSAttributedString(string: post.createdAt.timeSinceNow(), attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: hexColor(from: "BEBEBE")
            ])
        
        subtitleNode.attributedText = NSAttributedString(string: "Music Discussion • \(post.createdAt.timeSinceNow())", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: hexColor(from: "BEBEBE")
            ])
        
        postTextNode.maximumNumberOfLines = 4
//        let path = UIBezierPath(rect: CGRect(x: 100, y: 0, width: 200, height: 200))
//        postTextNode.exclusionPaths = [ path ] 
        postTextNode.attributedText = NSAttributedString(string: post.textClean, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 16.0),
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
        
        avatarNode.backgroundColor = post.anon.color
        avatarNode.style.height = ASDimension(unit: .points, value: 32)
        avatarNode.style.width = ASDimension(unit: .points, value: 32)
    }
    
    override func didLoad() {
        super.didLoad()
        videoNode.layer.cornerRadius = 4.0
        videoNode.clipsToBounds = true
        imageNode.layer.cornerRadius = 4.0
        imageNode.clipsToBounds = true
        avatarNode.layer.cornerRadius = 16
        avatarNode.clipsToBounds = true
//        previewBox.clipsToBounds = false
//        previewBox.view.applyShadow(radius: 4.0, opacity: 0.20, offset: CGSize(width: 0, height: 4.0), color: .black, shouldRasterize: false)
//        self.clipsToBounds = false
        
    }
    
    var gapNode = ASDisplayNode()
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        gapNode.style.flexGrow = 1.0
//        let titleCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleNode)
//        let titleStack = ASStackLayoutSpec.vertical()
//        titleStack.children = [ titleCenter, subtitleNode ]
//        titleStack.spacing = 8.0
//
        let actionStack = ASStackLayoutSpec.horizontal()
        actionStack.children = [likeButton, commentButton, moreButton]
        actionStack.spacing = 0.0
        actionStack.alignContent = .spaceBetween
        actionStack.justifyContent = .spaceBetween
        
        let headerStack = ASStackLayoutSpec.vertical()
        headerStack.children = [titleNode, subtitleNode]
        headerStack.spacing = 1.0
        
        
        let headerInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 40, 0, 0), child: headerStack)
        let avatarAbsolute = ASAbsoluteLayoutSpec(children: [avatarNode])
        let headerOverlay = ASOverlayLayoutSpec(child: headerInset, overlay: avatarAbsolute)
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [headerOverlay, postTextNode]
        contentStack.style.width = ASDimension(unit: .fraction, value: 0.70)
        contentStack.spacing = 6.0
        previewBox.style.width = ASDimension(unit: .fraction, value: 0.3)
        
        let stack = ASStackLayoutSpec.horizontal()
        stack.children = [contentStack, previewBox]
        stack.spacing = 12
        let mainInsets = UIEdgeInsetsMake(12, 12, 12, 24)
    
        let mStack = ASStackLayoutSpec.vertical()
        mStack.children = [stack, actionStack]
        mStack.spacing = 8.0
        
        return ASInsetLayoutSpec(insets: mainInsets, child: mStack)
    }
    
    func setHighlighted(_ highlighted:Bool) {
        backgroundColor = highlighted ? UIColor(white: 0.92, alpha: 1.0) : UIColor.white
    }
}
