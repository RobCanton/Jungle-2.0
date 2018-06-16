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
            NSAttributedStringKey.foregroundColor: UIColor(white: 0.25, alpha: 1.0)
        ]
        
        let title = NSMutableAttributedString(string: numRepliesStr, attributes: attributes) //1
        titleNode.attributedText = title
    }
    
    func setFetchingMode() {
        titleNode.isHidden = true
        spinnerNode.startAnimating()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        
        let centerTitle = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleNode)
        
        let mainInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(4, 44, 12, 16), child: centerTitle)
        let centerSpinner = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: spinnerNode)
        let overlay = ASOverlayLayoutSpec(child: mainInset, overlay: centerSpinner)
        return overlay
    }
    
}


