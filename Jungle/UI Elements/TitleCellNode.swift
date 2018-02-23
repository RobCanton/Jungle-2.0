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
    var liveDot = ASDisplayNode()
    
    var mode:SortMode = .top
    required init(mode: SortMode) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor.white
    
        titleButtonNode.tintColor = UIColor.gray
        titleButtonNode.tintColorDidChange()
        titleButtonNode.setImage(UIImage(named: "sort"), for: .normal)
        titleButtonNode.contentHorizontalAlignment = .left
        
        liveDot.backgroundColor = redColor
        liveDot.style.width = ASDimension(unit: .points, value: 12.0)
        liveDot.style.height = ASDimension(unit: .points, value: 12.0)
        liveDot.layer.cornerRadius = 6.0
        liveDot.clipsToBounds = true
        setSortTitle(mode)
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
    func setSortTitle(_ mode:SortMode) {
        self.mode = mode
        switch mode {
        case .top:
            setTitle("Top Comments")
            liveDot.isHidden = true
            stopAnimatingLiveDot()
            break
        case .live:
            setTitle("Live Comments")
            liveDot.isHidden = false
            animateLiveDot()
            break
        }
    }
    
    func setTitle(_ text:String) {
        let attrTitle = NSAttributedString(string: text, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        titleButtonNode.setAttributedTitle(attrTitle, for: .normal)
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleButtonNode.style.flexGrow = 1.0
        let centerDot = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: liveDot)
        let horizontalStack = ASStackLayoutSpec.horizontal()
        horizontalStack.children = [ titleButtonNode, centerDot ]
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(12, 44 + 12 + 16, 12, 16), child: horizontalStack)
    }
    
    func animateLiveDot() {
        self.liveDot.alpha = 1.0
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            
            self.liveDot.alpha = 0.0
            
        }, completion: nil)
    }
    
    func stopAnimatingLiveDot() {
        liveDot.layer.removeAllAnimations()
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        if mode == .live {
            animateLiveDot()
        }
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        stopAnimatingLiveDot()
    }
    
}

