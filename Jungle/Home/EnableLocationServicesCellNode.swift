//
//  EnableLocationServicesCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-07-23.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class EnableLocationServicesCellNode:ASCellNode {
    var titleNode = ASTextNode()
    var buttonNode = ASButtonNode()
    var buttonContainerNode = ASDisplayNode()
    var handleTap: (()->())?
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        let centerParagraph = NSMutableParagraphStyle()
        centerParagraph.alignment = .center
        titleNode.attributedText = NSAttributedString(string: "Enable location services to see posts near you",
                                                      attributes: [
                                                        NSAttributedStringKey.font: Fonts.regular(ofSize: 16.0),
                                                        NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                                                        NSAttributedStringKey.paragraphStyle: centerParagraph
                                                        ])
        titleNode.textContainerInset = UIEdgeInsetsMake(0, 44, 0, 44)
        
        let buttonTitle = NSAttributedString(string: "Authorize GPS",
                                            attributes: [
                                                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 18.0),
                                                NSAttributedStringKey.foregroundColor: UIColor.white,
                                                NSAttributedStringKey.paragraphStyle: centerParagraph
            ])
        buttonNode.setAttributedTitle(buttonTitle, for: .normal)
        buttonNode.setBackgroundImage(UIImage(named:"GreenBox"), for: .normal)
        buttonContainerNode.automaticallyManagesSubnodes = true
        buttonContainerNode.layoutSpecBlock = { _, _ in
            return ASInsetLayoutSpec(insets: .zero, child: self.buttonNode)
        }
        buttonNode.addTarget(self, action: #selector(handleButton), forControlEvents: .touchUpInside)
    }
    
    override func didLoad() {
        super.didLoad()
        buttonNode.layer.cornerRadius = 22
        buttonNode.clipsToBounds = true
        buttonContainerNode.view.applyShadow(radius: 12.0, opacity: 0.15, offset: CGSize(width: 0, height: 4), color: .black, shouldRasterize: false)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        buttonContainerNode.style.height = ASDimension(unit: .points, value: 44.0)
        buttonContainerNode.style.width = ASDimension(unit: .points, value: 200.0)
        
        let centerXButton = ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: .minimumX, child: buttonContainerNode)
        
        let vStack = ASStackLayoutSpec.vertical()
        vStack.children = [titleNode, centerXButton]
        vStack.spacing = 12.0
        
        let centerStack = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: vStack)
        return centerStack
    }
    
    @objc func handleButton() {
        handleTap?()
    }
}
