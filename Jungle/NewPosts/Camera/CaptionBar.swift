//
//  CaptionBar.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-09.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class CaptionBar:UIView, ASCollectionDelegate, ASCollectionDataSource {
    
    
    var collectionNode:ASCollectionNode!
    var hashtags = [TrendingHashtag]()
    var handleTag: ((_ tag:String)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.67)
        
        hashtags = SearchService.trendingHashtags
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8)
        //layout.estimatedItemSize = CGSize(width: frame.height, height: frame.height)
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.backgroundColor = UIColor.clear
        addSubview(collectionNode.view)
        collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        collectionNode.view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionNode.view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionNode.view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        collectionNode.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        collectionNode.view.showsHorizontalScrollIndicator = false
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return hashtags.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let cell = HashtagCellNode(tag: "#\(hashtags[indexPath.row].hastag)")
        cell.style.height = ASDimension(unit: .points, value: 36)
        return cell
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let tag = hashtags[indexPath.row]
        handleTag?("#\(tag.hastag)")
//        hashtags.remove(at: indexPath.row)
//        collectionNode.deleteItems(at: [indexPath])
    }
}

class HashtagCellNode:ASCellNode {
    var textNode = ASTextNode()
    
    var bgNode = ASDisplayNode()
    required init(tag:String) {
        super.init()
        automaticallyManagesSubnodes = true
        //backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        textNode.textContainerInset = UIEdgeInsetsMake(0, 8, 0, 8)
        textNode.attributedText = NSAttributedString(string: tag, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
    }
    
    override func didLoad() {
        super.didLoad()
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        bgNode.view.insertSubview(blurView, at: 0)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.leadingAnchor.constraint(equalTo: bgNode.view.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: bgNode.view.trailingAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: bgNode.view.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bgNode.view.bottomAnchor).isActive = true
        view.layer.cornerRadius = 6.0
        view.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let centerText = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: textNode)
        let bgSpec = ASBackgroundLayoutSpec(child: centerText, background: bgNode)
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: bgSpec)
    }
}

