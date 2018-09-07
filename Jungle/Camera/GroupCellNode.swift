//
//  GroupCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

class GlassCellNode:ASCellNode {
    var contentNode = ASDisplayNode()
    var isTop = false
    var isBottom = false
    var dividerNode = ASDisplayNode()
    
    var highlightColor = UIColor(white: 1.0, alpha: 0.25)
    
    required init(isTop:Bool, isBottom:Bool) {
        super.init()
        self.isTop = isTop
        self.isBottom = isBottom
        self.automaticallyManagesSubnodes = true
        backgroundColor = UIColor.clear
        
        dividerNode.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        dividerNode.isHidden = isBottom
        
        contentNode.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
        contentNode.automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        super.didLoad()
        contentNode.clipsToBounds = true
        contentNode.layer.cornerRadius = 0.0
        var maskedCorners:CACornerMask = []
        if isTop {
            contentNode.layer.cornerRadius = 8
            maskedCorners.insert(.layerMaxXMinYCorner)
            maskedCorners.insert(.layerMinXMinYCorner)
        }
        
        if isBottom {
            contentNode.layer.cornerRadius = 8
            maskedCorners.insert(.layerMaxXMaxYCorner)
            maskedCorners.insert(.layerMinXMaxYCorner)
        }
        
        contentNode.layer.maskedCorners = maskedCorners
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.vertical()
        stack.children = [contentNode, dividerNode]
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: stack)
    }
    
    func setHighlighted(_ highlighted:Bool) {
        if highlighted {
            contentNode.backgroundColor = highlightColor
        } else {
            contentNode.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
        }
    }
}

class GroupCellNode:GlassCellNode {
    var titleNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var avatarNode = ASNetworkImageNode()
    
    required init(isTop: Bool, isBottom: Bool) {
        super.init(isTop: isTop, isBottom: isBottom)
    }
    
    required init(isTop: Bool, isBottom: Bool, group:Group?) {
        super.init(isTop: isTop, isBottom: isBottom)

        titleNode.maximumNumberOfLines = 1
        if let group = group {
            highlightColor = accentColor
            avatarNode.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            avatarNode.image = nil
            avatarNode.url = group.avatar_low
            titleNode.truncationMode = .byTruncatingTail
            titleNode.attributedText = NSAttributedString(string: group.name, attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 18.0),
                NSAttributedStringKey.foregroundColor: UIColor.white
                ])
            
            var subtitleStr:String
            if group.numMembers == 1 {
                subtitleStr = "1 Member"
            } else {
                subtitleStr = "\(group.numMembers) Members"
            }
            subtitleNode.truncationMode = .byTruncatingTail
            subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
                NSAttributedStringKey.font: Fonts.light(ofSize: 12.0),
                NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.67)
                ])
        } else {
            avatarNode.backgroundColor = UIColor.clear
            avatarNode.url = nil
            avatarNode.image = UIImage(named:"Create44")
            titleNode.attributedText = NSAttributedString(string: "Create Group", attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 18.0),
                NSAttributedStringKey.foregroundColor: UIColor.white
                ])
        }
        
        avatarNode.cornerRadius = 4
        avatarNode.clipsToBounds = true
        
        contentNode.style.height = ASDimension(unit: .points, value: 44 + 16)
        contentNode.layoutSpecBlock = { _, _ in

            let titleStack = ASStackLayoutSpec.vertical()
            titleStack.children = [self.titleNode]
            if let _ = group {
                titleStack.children?.append(self.subtitleNode)
            }
            titleStack.spacing = 1.0
            
            self.avatarNode.style.width = ASDimension(unit: .points, value: 44)
            self.avatarNode.style.height = ASDimension(unit: .points, value: 44)
            self.avatarNode.style.layoutPosition = CGPoint(x: 0, y: 8)

            let centerTitleStack = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleStack)
            let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 8 + 44, 0, 0), child: centerTitleStack)
            
            let abs = ASAbsoluteLayoutSpec(children: [self.avatarNode])
            let overlay = ASOverlayLayoutSpec(child: titleInset, overlay: abs)
            return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 8, 0, 8), child: overlay)
        }
        
    }
    
    override func didLoad() {
        super.didLoad()
        self.layout()
    }
}
