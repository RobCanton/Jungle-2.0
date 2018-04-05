//
//  PostTagsCollectionNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-04-04.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import AlignedCollectionViewFlowLayout

class PostTagsCollectionNode:ASDisplayNode, ASCollectionDelegate, ASCollectionDataSource {
    var collectionNode:ASCollectionNode!
    
    var tags = [String]() {
        didSet {
            collectionNode.reloadData()
            getNumLines()
        }
    }
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        alignedFlowLayout.minimumInteritemSpacing = 8.0
        alignedFlowLayout.minimumLineSpacing = 8.0
        collectionNode = ASCollectionNode(collectionViewLayout: alignedFlowLayout)
        collectionNode.backgroundColor = UIColor.clear
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.reloadData()
        
    }
    
    func getNumLines() -> Int{
        let maxWidth = UIScreen.main.bounds.width - 48.0
        var numLines:Int = tags.count > 0 ? 1 : 0
        var currentWidth:CGFloat = 0
        for tag in tags {

            let textWidth = UILabel.size(text: tag, height: 24.0, font: textFont).width + 12
            if currentWidth + textWidth < maxWidth {
                currentWidth += textWidth
            } else {
                numLines += 1
                currentWidth = 0
            }
        }
        return numLines
        print("NUMBER OF LINES: \(numLines)")
    }
    
    func getContentHeight() -> CGFloat {
        let numLines = getNumLines()
        var gaps:CGFloat = 0
        if numLines > 0 {
            gaps = CGFloat(numLines - 1) * 8.0
        }
        return gaps + CGFloat(numLines) + 24.0
    }
    
    override func didLoad() {
        super.didLoad()
        let rect = collectionNode.contentsRect
        print("ASD : \(rect)")
        
        collectionNode.view.isScrollEnabled = false
    }
    
    let textFont = Fonts.medium(ofSize: 12.0)
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 12.0, 0, 12.0), child: collectionNode)
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let cell = TagCellNode()
        cell.textNode.attributedText = NSAttributedString(string: tags[indexPath.row], attributes: [NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: textFont])
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        cell.style.height = ASDimension(unit: .points, value: 24.0)
        return cell
    }
    
//    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
//        return ASSizeRangeMake(CGSize(width: 100.0, height: 24.0))
//    }
    
}

class TagCellNode:ASCellNode {
    var textNode = ASTextNode()
    var insets = UIEdgeInsetsMake(0, 8.0, 0, 8.0)
    required init(insets:UIEdgeInsets?=nil) {
        super.init()
        if let _insets = insets {
            self.insets = _insets
        }
        automaticallyManagesSubnodes = true
        self.layer.cornerRadius = 12.0
        self.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textCenterY = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: textNode)
        let insetText = ASInsetLayoutSpec(insets: insets, child: textCenterY)
        return insetText
    }
}


