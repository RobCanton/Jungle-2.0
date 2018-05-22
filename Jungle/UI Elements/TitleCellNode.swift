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
    var dividerNode = ASDisplayNode()
    var mode:SortMode = .top
    required init(mode: SortMode) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = hexColor(from: "#eff0e9")
    
        titleButtonNode.tintColor = tertiaryColor
        titleButtonNode.tintColorDidChange()
        titleButtonNode.setImage(UIImage(named: "DropDown"), for: .normal)
        titleButtonNode.contentHorizontalAlignment = .left
        titleButtonNode.contentSpacing = 0
        
        liveDot.backgroundColor = redColor
        liveDot.style.width = ASDimension(unit: .points, value: 12.0)
        liveDot.style.height = ASDimension(unit: .points, value: 12.0)
        liveDot.layer.cornerRadius = 6.0
        liveDot.clipsToBounds = true
        setSortTitle(mode)
        
        dividerNode.backgroundColor = subtitleColor.withAlphaComponent(0.25)
    }
    
    override func didLoad() {
        super.didLoad()
        self.selectionStyle = .none
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
            NSAttributedStringKey.font: Fonts.bold(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: tertiaryColor
            ])
        titleButtonNode.setAttributedTitle(attrTitle, for: .normal)
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        titleButtonNode.style.flexGrow = 1.0
        let centerDot = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: liveDot)
        let horizontalStack = ASStackLayoutSpec.horizontal()
        horizontalStack.children = [ titleButtonNode, centerDot ]
        
        let mainInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 8, 0, 10), child: horizontalStack)
        let mainVerticalStack = ASStackLayoutSpec.vertical()
        mainVerticalStack.children = [mainInset]
        return mainVerticalStack
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

