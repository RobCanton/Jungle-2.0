//
//  TitleCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-21.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

class TitleCellNode: ASCellNode {
    var titleButtonNode = ASButtonNode()
    
    required init(title: String) {
        super.init()
        automaticallyManagesSubnodes = true
        titleButtonNode.tintColor = UIColor.gray
        titleButtonNode.tintColorDidChange()
        let attrTitle = NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        titleButtonNode.setAttributedTitle(attrTitle, for: .normal)
        titleButtonNode.setImage(UIImage(named: "sort"), for: .normal)
        titleButtonNode.contentHorizontalAlignment = .left
        
 
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(12, 44 + 12 + 16, 12, 0), child: titleButtonNode)
    }
}

