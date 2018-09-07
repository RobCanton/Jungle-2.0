//
//  StickerDrawerViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-05.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Pulley

public extension UIViewController {
    
    /// If this viewController pertences to a PulleyViewController, return it.
    public var pulleyViewController: PulleyViewController? {
        var parentVC = parent
        while parentVC != nil {
            if let pulleyViewController = parentVC as? PulleyViewController {
                return pulleyViewController
            }
            parentVC = parentVC?.parent
        }
        return nil
    }
}



class StickersView:UIView, ASCollectionDelegate, ASCollectionDataSource {
    var collectionNode:ASCollectionNode!
    var addSticker: ((_ sticker:UIImage)->())?
    var stickers:[[String]]!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.preservesSuperviewLayoutMargins = false
        self.insetsLayoutMarginsFromSafeArea = false
        
        stickers = [[String]]()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: (bounds.width - 32)/7, height: (bounds.width - 32)/7)
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.backgroundColor = UIColor.clear
        let collectionView = collectionNode.view
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        layoutIfNeeded()
        
        collectionNode.contentInset = UIEdgeInsetsMake(0, 16, 0, 16)
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.reloadData()
    }
    
    func setupStickers() {
        if stickers.count == 0 {
            stickers = Emojis.catergorizedEmojis
            collectionNode.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return stickers.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return stickers[section].count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let sticker = stickers[indexPath.section][indexPath.row]
        let cell = StickerCellNode(sticker)
        cell.style.width = ASDimension(unit: .points, value: (collectionNode.bounds.width - 32) / 7)
        cell.style.height = ASDimension(unit: .points, value: (collectionNode.bounds.width - 32) / 7)
        return cell
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        let cell = node as? StickerCellNode
        cell?.willDisplay()
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let sticker = stickers[indexPath.section][indexPath.row]
        let image = sticker.image(size: 500)
        addSticker?(image)
    }
}

class StickerCellNode:ASCellNode {
    var titleNode = ASTextNode()
    var emoji:String!
    required init(_ emoji:String) {
        super.init()
        self.emoji = emoji
        automaticallyManagesSubnodes = true
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let centerTitle = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: titleNode)
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: centerTitle)
    }
    
    func willDisplay() {
        titleNode.attributedText = NSAttributedString(string: emoji, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 44)
            ])
    }
}

extension String {
    func image(size: CGFloat) -> UIImage {
        
        let outputImageSize = CGSize.init(width: size, height: size)
        let baseSize = self.boundingRect(with: CGSize(width: 2048, height: 2048),
                                         options: .usesLineFragmentOrigin,
                                         attributes: [.font: UIFont.systemFont(ofSize: size / 2)], context: nil).size
        let fontSize = outputImageSize.width / max(baseSize.width, baseSize.height) * (outputImageSize.width / 2)
        let font = UIFont.systemFont(ofSize: fontSize)
        let textSize = self.boundingRect(with: CGSize(width: outputImageSize.width, height: outputImageSize.height),
                                         options: .usesLineFragmentOrigin,
                                         attributes: [.font: font], context: nil).size
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        style.lineBreakMode = NSLineBreakMode.byClipping
        
        let attr : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : font,
                                                    NSAttributedStringKey.paragraphStyle: style,
                                                    NSAttributedStringKey.backgroundColor: UIColor.clear ]
        
        UIGraphicsBeginImageContextWithOptions(outputImageSize, false, 0)
        self.draw(in: CGRect(x: (size - textSize.width) / 2,
                             y: (size - textSize.height) / 2,
                             width: textSize.width,
                             height: textSize.height),
                  withAttributes: attr)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
