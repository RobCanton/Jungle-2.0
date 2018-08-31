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
    var region:Region? {
        didSet {
            collectionNode.reloadData()
            if region != nil {
                collectionNode.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
                collectionNode(collectionNode, didSelectItemAt: IndexPath(item: 0, section: 0))
            }
        }
    }
    
    var includeRegion:Bool {
        guard let paths = collectionNode.indexPathsForSelectedItems else { return false }
        for path in paths {
            if path.section == 0, path.item == 0 {
                return true
            }
        }
        return false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        hashtags = SearchService.trendingHashtags
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 8)
        //layout.estimatedItemSize = CGSize(width: frame.height, height: frame.height)
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.backgroundColor = UIColor.clear
        addSubview(collectionNode.view)
        collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        collectionNode.view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionNode.view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionNode.view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        collectionNode.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionNode.contentInset = UIEdgeInsetsMake(0, 8, 0, 0)
        collectionNode.view.showsHorizontalScrollIndicator = false
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.allowsMultipleSelection = true
        collectionNode.reloadData()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 2
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
    
        return hashtags.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = LocationCellNode(region: region)
                cell.style.height = ASDimension(unit: .points, value: 36)
                return cell
            default:
                let cell = ASCellNode()
                cell.style.width = ASDimension(unit: .points, value: 2.0)
                cell.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                cell.layer.cornerRadius = 1.0
                cell.clipsToBounds = true
                return cell
            }
        }
        let cell = HashtagCellNode(tag: "#\(hashtags[indexPath.row].hastag)")
        cell.style.height = ASDimension(unit: .points, value: 36)
        return cell
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionNode.nodeForItem(at: indexPath)
        if let locationCellNode = cell as? LocationCellNode {
            if gpsService.isAuthorized() {
                locationCellNode.setHighlighted(true)
            } else {
                gpsService.requestAuthorization()
                collectionNode.deselectItem(at: indexPath, animated: true)
            }
            
        } else if let tagCell = cell as? HashtagCellNode {
            handleTag?("#\(hashtags[indexPath.item].hastag)")
            tagCell.setActivated()
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionNode.nodeForItem(at: indexPath)
        if let tagCell = cell as? HashtagCellNode {
            tagCell.backgroundColor = tagColor
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionNode.nodeForItem(at: indexPath)
        if let tagCell = cell as? HashtagCellNode {
            tagCell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionNode.nodeForItem(at: indexPath) as? LocationCellNode {
            cell.setHighlighted(false)
        }
    }
}

class LocationCellNode:ASCellNode {
    var buttonNode = ASButtonNode()
    
    var bgNode = ASDisplayNode()
    var insets:UIEdgeInsets!
    var highlightedColor:UIColor = tagColor
    required init(region:Region?) {
        super.init()
        
        let authorized = gpsService.isAuthorized()
        
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        insets = UIEdgeInsetsMake(0, 0, 0, 6)
        buttonNode.setImage(UIImage(named:"PinLarge"), for: .normal)
        buttonNode.contentSpacing = 0.0
        if authorized {
            if let locationStr = region?.locationShortStr {
                buttonNode.imageNode.alpha = 1.0
                buttonNode.setAttributedTitle(NSAttributedString(string: locationStr, attributes: [
                    NSAttributedStringKey.font: Fonts.semiBold(ofSize: 12.0),
                    NSAttributedStringKey.foregroundColor: UIColor.white
                    ]), for: .normal)
            } else {
                buttonNode.imageNode.alpha = 0.5
                buttonNode.setAttributedTitle(NSAttributedString(string: "Unknown", attributes: [
                    NSAttributedStringKey.font: Fonts.semiBold(ofSize: 12.0),
                    NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)
                    ]), for: .normal)
            }
        } else {
            backgroundColor = tagColor
            buttonNode.imageNode.alpha = 1.0
            buttonNode.setAttributedTitle(NSAttributedString(string: "Add Location", attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 12.0),
                NSAttributedStringKey.foregroundColor: UIColor.white
                ]), for: .normal)
        }
        
    }
    
    func setHighlighted(_ highlighted:Bool) {
        backgroundColor = highlighted ? highlightedColor : UIColor.black.withAlphaComponent(0.5)
    }
    
    override func didLoad() {
        super.didLoad()
        
        view.layer.cornerRadius = 6.0
        view.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let bgSpec = ASBackgroundLayoutSpec(child: buttonNode, background: bgNode)
        return ASInsetLayoutSpec(insets: insets, child: bgSpec)
    }
}



class HashtagCellNode:ASCellNode {
    var textNode = ASTextNode()
    
    var bgNode = ASDisplayNode()
    required init(tag:String) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        textNode.textContainerInset = UIEdgeInsetsMake(0, 8, 0, 8)
        textNode.attributedText = NSAttributedString(string: tag, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
    }
    
    override func didLoad() {
        super.didLoad()
        
        view.layer.cornerRadius = 6.0
        view.clipsToBounds = true
    }
    
    func setActivated() {
        backgroundColor = tagColor
        UIView.animate(withDuration: 0.35, delay: 0.15, options: .curveEaseOut, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }, completion: nil)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let centerText = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: textNode)
        let bgSpec = ASBackgroundLayoutSpec(child: centerText, background: bgNode)
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: bgSpec)
    }
}

