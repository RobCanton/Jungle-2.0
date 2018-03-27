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
    var titleNode = ASTextNode()
    var dividerNode = ASDisplayNode()
    var spinnerNode = SpinnerNode()
    var moreNode = ASDisplayNode()
    var dotNode1 = ASDisplayNode()
    var dotNode2 = ASDisplayNode()
    var dotNode3 = ASDisplayNode()
    
    
    let dotSize:CGFloat = 3.0
    required init(numReplies:Int) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        titleNode.tintColor = accentColor
        titleNode.tintColorDidChange()
        
        dividerNode.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        
        var numRepliesStr:String!
        if numReplies == 1 {
            numRepliesStr = "1 previous reply"
        } else {
            numRepliesStr = "\(numReplies) previous replies"
        }

        let attributes = [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: accentColor
        ]
        
        let title = NSMutableAttributedString(string: numRepliesStr, attributes: attributes) //1
        titleNode.attributedText = title
        
        dotNode1.backgroundColor = subtitleColor.withAlphaComponent(0.25)
        dotNode1.layer.cornerRadius = dotSize/2
        dotNode1.clipsToBounds = true
        dotNode2.backgroundColor = subtitleColor.withAlphaComponent(0.25)
        dotNode2.layer.cornerRadius = dotSize/2
        dotNode2.clipsToBounds = true
        dotNode3.backgroundColor = subtitleColor.withAlphaComponent(0.25)
        dotNode3.layer.cornerRadius = dotSize/2
        dotNode3.clipsToBounds = true
    }
    
    func setFetchingMode() {
        titleNode.isHidden = true
        spinnerNode.startAnimating()
        dotNode1.isHidden = true
        dotNode2.isHidden = true
        dotNode3.isHidden = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        
        dotNode1.style.width = ASDimension(unit: .points, value: dotSize)
        dotNode1.style.height = ASDimension(unit: .points, value: dotSize)
        
        dotNode2.style.width = ASDimension(unit: .points, value: dotSize)
        dotNode2.style.height = ASDimension(unit: .points, value: dotSize)
        
        dotNode3.style.width = ASDimension(unit: .points, value: dotSize)
        dotNode3.style.height = ASDimension(unit: .points, value: dotSize)
        
        let dotStack = ASStackLayoutSpec.vertical()
        dotStack.style.width = ASDimension(unit: .points, value: dotSize)
        dotStack.children = [dotNode1, dotNode2, dotNode3]
        dotStack.spacing = 2.0
        let centerDots = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: dotStack)
        
        let centerTitle = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleNode)
        let horizontalStack = ASStackLayoutSpec.horizontal()
        horizontalStack.children = [centerDots, centerTitle]
        horizontalStack.spacing = 36/2 + 8.0
        
        let mainInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(8, 16 + 36/2 - dotSize/2, 8, 16), child: horizontalStack)
        let centerSpinner = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: spinnerNode)
        let overlay = ASOverlayLayoutSpec(child: mainInset, overlay: centerSpinner)
        
        
        
        
        return overlay
    }
    
}


