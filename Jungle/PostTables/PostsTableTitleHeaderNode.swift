//
//  PostsTableTitleHeaderNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-06.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class PostsTableTitleHeaderNode:ASCellNode {
    var titleNode = ASTextNode()
    var dividerNode = ASDisplayNode()
    required init(title:String) {
        super.init()
        backgroundColor = UIColor.white
        automaticallyManagesSubnodes = true
        
        titleNode = ASTextNode()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        titleNode.attributedText = NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor(white: 0.35, alpha: 1.0),
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])
        
        dividerNode = ASDisplayNode()
        dividerNode.style.height = ASDimension(unit: .points, value: 1.0)
        dividerNode.backgroundColor = UIColor(white: 0.35, alpha: 1.0)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let dividerInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 4, 0, 4), child: dividerNode)
        let stack = ASStackLayoutSpec.vertical()
        stack.spacing = 5
        stack.children = [titleNode, dividerInset]
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(10, 10, 0, 10), child: stack)
    }
}
