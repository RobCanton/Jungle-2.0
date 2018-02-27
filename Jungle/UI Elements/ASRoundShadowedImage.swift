//
//  ASRoundShadowedImage.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class ASRoundShadowedImageNode:ASDisplayNode {
    var imageNode = ASNetworkImageNode()
    var cellDidLoad = false
    
    var imageShadowRadius:CGFloat = 0
    var imageCornerRadius:CGFloat = 0
    
    required init(imageCornerRadius:CGFloat, imageShadowRadius:CGFloat) {
        super.init()
        self.imageCornerRadius = imageCornerRadius
        self.imageShadowRadius = imageShadowRadius
        automaticallyManagesSubnodes = true
        imageNode.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        imageNode.contentMode = .scaleAspectFill
        imageNode.isUserInteractionEnabled = false
        self.clipsToBounds = false
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: imageNode)
    }
    
    override func didLoad() {
        super.didLoad()
        imageNode.layer.cornerRadius = imageCornerRadius
        imageNode.clipsToBounds = true
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        applyShadow()
    }
    
    
    func applyShadow() {
        let color = UIColor(white: 0.0, alpha: 1.0)
        let offset = CGSize(width: 0, height: imageShadowRadius)
        view.applyShadow(radius: imageShadowRadius, opacity: 0.15, offset: offset, color: color, shouldRasterize: false)
    }
    
    func applyShadow(withColor color:UIColor, opacity:Float) {
        let offset = CGSize(width: 0, height: imageShadowRadius)
        view.applyShadow(radius: imageShadowRadius, opacity: opacity, offset: offset, color: color, shouldRasterize: false)
    }
}
