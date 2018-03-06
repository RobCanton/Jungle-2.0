//
//  ViewRepliesCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-05.
//  Copyright © 2018 Robert Canton. All rights reserved.
//


import Foundation
import AsyncDisplayKit
import UIKit

class ViewRepliesCellNode: ASCellNode {
    var imageNode = ASRoundShadowedImageNode(imageCornerRadius: 12.0, imageShadowRadius: 0.0)
    var titleNode = ASTextNode()
    var dividerNode = ASDisplayNode()
    
    required init(reply: Reply) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        imageNode.style.width = ASDimension(unit: .points, value: 24)
        imageNode.style.height = ASDimension(unit: .points, value: 24)
        
        titleNode.tintColor = UIColor.gray
        titleNode.tintColorDidChange()
        
        setTitle("SillyDeer Replied · \(reply.numReplies) Replies")
        
        dividerNode.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
    }
    
    func setTitle(_ text:String) {
        let attrTitle = NSAttributedString(string: text, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        titleNode.attributedText = attrTitle
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        
        let centerImage = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: imageNode)
        let centerTitle = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleNode)
        let horizontalStack = ASStackLayoutSpec.horizontal()
        horizontalStack.children = [centerImage, centerTitle]
        horizontalStack.spacing = 8.0
        
        let mainInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(4, 16 + 36 + 8, 4, 16), child: horizontalStack)
        let mainVerticalStack = ASStackLayoutSpec.vertical()
        mainVerticalStack.children = [mainInset, dividerNode]
        mainVerticalStack.spacing = 4.0
        return mainVerticalStack
    }
    
}


