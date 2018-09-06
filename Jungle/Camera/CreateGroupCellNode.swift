//
//  CreateGroupCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

class CreateGroupCellNode:ASCellNode {
    var titleNode = ASTextNode()
    var contentNode = ASDisplayNode()
    var avatarNode = ASNetworkImageNode()
    
    var dividerNode = ASDisplayNode()
    
    var isTop = false
    var isBottom = false
    var isNewGroup = false
    required init(title:String, isTop:Bool, isBottom:Bool, isNewGroup:Bool?=nil) {
        self.isTop = isTop
        self.isBottom = isBottom
        self.isNewGroup = isNewGroup ?? false
        
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor.clear
        
        titleNode.attributedText = NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 18.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        
        if self.isNewGroup {
            avatarNode.backgroundColor = UIColor.clear
            avatarNode.url = nil
            avatarNode.image = UIImage(named:"Create44")
        } else {
            avatarNode.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            avatarNode.image = nil
            avatarNode.url = URL(string: "https://avatarfiles.alphacoders.com/861/86145.jpg")
        }
        
        avatarNode.cornerRadius = 22
        avatarNode.clipsToBounds = true
        
        dividerNode.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        dividerNode.isHidden = isBottom
        
        contentNode.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
        contentNode.automaticallyManagesSubnodes = true
        contentNode.layoutSpecBlock = { _, _ in
            
            let titleCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: self.titleNode)
            self.avatarNode.style.width = ASDimension(unit: .points, value: 44)
            self.avatarNode.style.height = ASDimension(unit: .points, value: 44)
            
            let stack = ASStackLayoutSpec.horizontal()
            stack.children = [self.avatarNode, titleCenter]
            stack.spacing = 12
            return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(12, 12, 12, 12), child: stack)
        }
        
    }
    
    override func didLoad() {
        super.didLoad()
        contentNode.clipsToBounds = true
        contentNode.layer.cornerRadius = 0.0
        var maskedCorners:CACornerMask = []
        if isTop {
            contentNode.layer.cornerRadius = 12
            maskedCorners.insert(.layerMaxXMinYCorner)
            maskedCorners.insert(.layerMinXMinYCorner)
        }
        
        if isBottom {
            contentNode.layer.cornerRadius = 12
            maskedCorners.insert(.layerMaxXMaxYCorner)
            maskedCorners.insert(.layerMinXMaxYCorner)
        }
        
        contentNode.layer.maskedCorners = maskedCorners
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var stack = ASStackLayoutSpec.vertical()
        stack.children = [contentNode, dividerNode]
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: stack)
    }
    
    func setHighlighted(_ highlighted:Bool) {
        if highlighted {
            contentNode.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        } else {
            contentNode.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
        }
    }
}
