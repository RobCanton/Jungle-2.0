//
//  LightboxCell.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-28.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class LightboxCell: UICollectionViewCell {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageHeightAnchor: NSLayoutConstraint!
    
    let imageNode = ASNetworkImageNode()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageContainerView.addSubview(imageNode.view)
        imageNode.imageModificationBlock = { image in
            print("IMAGE SIZE: \(image.size)")
            
            return image
        }
    }
    
    func setup(url:URL) {
        
    
        self.layoutIfNeeded()
        imageNode.view.frame = imageContainerView.bounds
        imageNode.url = url
        imageNode.contentMode = .scaleAspectFill
    }
    

}
