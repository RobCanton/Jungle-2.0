//
//  BackgroundsCollectionNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-09.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

protocol GradientSelectorDelegate:class {
    func didSelect(gradient:[String]?)
}


class GradientSelectorNode:ASDisplayNode, ASCollectionDelegate, ASCollectionDataSource, MosaicCollectionViewLayoutDelegate {
    
    var collectionNode:ASCollectionNode!

    let _layoutInspector = MosaicCollectionViewLayoutInspector()
    
    var gradients = [[String]]()
    
    weak var delegate:GradientSelectorDelegate?
    
    override init() {
        super.init()
        
        gradients = GroupsService.gradients
        
        automaticallyManagesSubnodes = true
        let layout = MosaicCollectionViewLayout()
        layout.numberOfColumns = 3
        layout.scrollDirection = .vertical
        layout.delegate = self
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.delegate = self
        collectionNode.dataSource = self
        
        collectionNode.layoutInspector = _layoutInspector
        collectionNode.backgroundColor = UIColor.white
        collectionNode.contentInset = UIEdgeInsetsMake(0, 0, 44+12, 0)
        collectionNode.reloadData()

        
    }
    
    override func didLoad() {
        super.didLoad()
        collectionNode.view.showsVerticalScrollIndicator = false

    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: collectionNode)
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return gradients.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        
        let cell = GradientCellNode(gradient: gradients[indexPath.row])
        return cell
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionNode.nodeForItem(at: indexPath) as? GradientCellNode
        cell?.setSelected(true)
    }

    func collectionNode(_ collectionNode: ASCollectionNode, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionNode.nodeForItem(at: indexPath) as? GradientCellNode
        cell?.setSelected(false)
    }

    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionNode.nodeForItem(at: indexPath) as? GradientCellNode
        cell?.setSelected(true)
        delegate?.didSelect(gradient: gradients[indexPath.row])
        
    }

    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionNode.nodeForItem(at: indexPath) as? GradientCellNode
        cell?.setSelected(false)
        delegate?.didSelect(gradient: nil)
    }
    
    
    
    internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 50, height:80)
    }
    
}

class GradientCellNode:ASCellNode {
    var pastelNode:PastelNode!
    var overlayNode = ASImageNode()
    
    required init(gradient:[String]) {
        super.init()
        automaticallyManagesSubnodes = true
        pastelNode = PastelNode(gradient: gradient)
        self.clipsToBounds = true
        overlayNode.image = UIImage(named:"JoinPlain")
        overlayNode.alpha = 0.0
    }
    
    override func didLoad() {
        super.didLoad()
        pastelNode.staticGradient()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        overlayNode.style.width = ASDimension(unit: .points, value: 32.0)
        overlayNode.style.height = ASDimension(unit: .points, value: 32.0)
        
        let centerOverlay = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: overlayNode)
        let overlay = ASOverlayLayoutSpec(child: pastelNode, overlay: centerOverlay)
        return ASInsetLayoutSpec(insets: .zero, child: overlay)
    }
    
    func setSelected(_ selected:Bool) {
        
        if selected {
            UIView.animate(withDuration: 0.25, animations: {
                self.layer.cornerRadius = 12.0
                self.alpha = 0.67
                self.overlayNode.alpha = 1.0
                self.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.layer.cornerRadius = 0.0
                self.alpha = 1.0
                self.overlayNode.alpha = 0.0
                self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        }
    }
}
