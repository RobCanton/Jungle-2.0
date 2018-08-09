//
//  PopularPostsHeaderCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-14.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol PopularHeaderCellProtocol:class {
    func postOpenTrending(tag:TrendingHashtag)
}

class PopularPostsHeaderCellNode:ASCellNode, ASCollectionDelegate, ASCollectionDataSource {
    
    var collectionNode:ASCollectionNode!
    var hashtags = SearchService.trendingHashtags
    
    weak var delegate:PopularHeaderCellProtocol?
    
    var topTitle = ASTextNode()
    var midTitle = ASTextNode()
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor.clear
        
        style.height = ASDimension(unit: .points, value: 202)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .horizontal
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.contentInset = UIEdgeInsetsMake(8, 12, 8, 12)
        collectionNode.style.height = ASDimension(unit: .points, value: 190)
        collectionNode.reloadData()
        collectionNode.backgroundColor = UIColor.clear
        collectionNode.clipsToBounds = false
        NotificationCenter.default.addObserver(self, selector: #selector(handleTrendingTagsNotification), name: SearchService.trendingTagsNotification, object: nil)
    }
    
    @objc func handleTrendingTagsNotification() {
        print("TRENDING TAGS UPDATED YO!")
        hashtags = SearchService.trendingHashtags
        collectionNode.reloadData()
    }
    
    override func didLoad() {
        super.didLoad()
        collectionNode.view.showsHorizontalScrollIndicator = false
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(4, 0, 8, 0), child: collectionNode)
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return hashtags.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let cell = TrendingCellNode(tag:hashtags[indexPath.row])
        return cell
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        delegate?.postOpenTrending(tag: hashtags[indexPath.row])
        let node = collectionNode.nodeForItem(at: indexPath) as? TrendingCellNode
        node?.setHighlighted(true)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        let node = collectionNode.nodeForItem(at: indexPath) as? TrendingCellNode
        node?.setHighlighted(false)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didHighlightItemAt indexPath: IndexPath) {
        let node = collectionNode.nodeForItem(at: indexPath) as? TrendingCellNode
        node?.setHighlighted(true)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didUnhighlightItemAt indexPath: IndexPath) {
        let node = collectionNode.nodeForItem(at: indexPath) as? TrendingCellNode
        node?.setHighlighted(false)
    }
}

class BadgeNode:ASDisplayNode {
    var containerNode = ASDisplayNode()
    var textNode = ASTextNode()
    
    required init(title:String) {
        super.init()
        automaticallyManagesSubnodes = true
        automaticallyManagesSubnodes = true
        
        textNode.attributedText = NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
        ])
        
        let sizeWidth = UILabel.size(text: "\(title)", height: 26, font: Fonts.semiBold(ofSize: 14.0))
        let sizeHeight = UILabel.size(text: "\(title)", width: 100, font: Fonts.semiBold(ofSize: 14.0))
        
        badgeSize = CGSize(width: sizeWidth.width + 14, height: sizeHeight.height + 14)
        print("BADGE WIDTH: \(badgeSize)")
        containerNode.style.height = ASDimension(unit: .points, value: badgeSize.height)
        if badgeSize.width < badgeSize.height {
            containerNode.style.width = ASDimension(unit: .points, value: badgeSize.height)
        } else {
            containerNode.style.width = ASDimensionAuto
        }
        
        containerNode.backgroundColor = tagColor
        containerNode.automaticallyManagesSubnodes = true
        containerNode.layoutSpecBlock = { _, _ in
            let center = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: self.textNode)
            return center
        }
    }
    var badgeSize:CGSize = .zero
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: containerNode)
    }
    
    override func didLoad() {
        super.didLoad()
        containerNode.clipsToBounds = true
        view.applyShadow(radius: 3.0, opacity: 0.15, offset: .zero, color: UIColor.black, shouldRasterize: false)
    }
}

class TrendingCellNode:ASCellNode {
    
    var pastelNode:PastelNode!
    var imageNode = ASNetworkImageNode()
    var gradientNode = ASDisplayNode()
    var titleNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var textNode = ASTextNode()
    var dimNode = ASDisplayNode()
    
    required init(tag:TrendingHashtag) {
        super.init()
        automaticallyManagesSubnodes = true
        let post = tag.posts.first!
        pastelNode = PastelNode(gradient: post.gradient)
        imageNode.backgroundColor = UIColor.lightGray
        self.imageNode.shouldCacheImage = true
        
        if post.attachments.isVideo {
            let thumbnailRef = storage.child("publicPosts/\(post.key)/thumbnail.gif")
            thumbnailRef.downloadURL { url, error in
                self.imageNode.url = url
            }
        } else if post.attachments.isImage {
            let imageRef = storage.child("publicPosts/\(post.key)/image.jpg")
            imageRef.downloadURL { imageURL, error in
                self.imageNode.url = imageURL
            }
        } else {
            self.imageNode.backgroundColor = UIColor.clear
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            self.textNode.maximumNumberOfLines = 7
            self.textNode.textContainerInset = UIEdgeInsetsMake(2, 8, 26, 8)
            self.textNode.attributedText = NSAttributedString(string: post.text, attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.85),
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 12.0)
                ])
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        titleNode.maximumNumberOfLines = 1
        titleNode.attributedText = NSAttributedString(string: "#\(tag.hastag)", attributes: [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: Fonts.bold(ofSize: 14.0),
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])
        let subtitle = "\(tag.count) recent posts"
        subtitleNode.attributedText = NSAttributedString(string: subtitle, attributes: [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: Fonts.medium(ofSize: 11.5),
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])
        dimNode.backgroundColor = UIColor.black
        dimNode.alpha = 0.0
    }
    
    override func didLoad() {
        super.didLoad()
        imageNode.cornerRadius = 6.0
        imageNode.clipsToBounds = true
        pastelNode.cornerRadius = 6.0
        pastelNode.clipsToBounds = true
        pastelNode.staticGradient()
        dimNode.cornerRadius = 6.0
        dimNode.clipsToBounds = true
        self.view.applyShadow(radius: 6, opacity: 0.3, offset: CGSize(width:0, height: 3), color: .black, shouldRasterize: false)
        self.clipsToBounds = false
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.40).cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 0, y: 0.5)
        gradient.frame = view.bounds
        gradient.cornerRadius = 6.0
        gradient.masksToBounds = true
        gradientNode.layer.addSublayer(gradient)
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        pastelNode.style.width = ASDimension(unit: .points, value: 130)
        pastelNode.style.height = ASDimension(unit: .points, value: 190)
        let centerText = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: textNode)
        let imageOverlay = ASOverlayLayoutSpec(child: pastelNode, overlay: imageNode)
        let textOverlay = ASOverlayLayoutSpec(child: imageOverlay, overlay: centerText)
        
        let contentOverlay = ASOverlayLayoutSpec(child: textOverlay, overlay: gradientNode)
        let titleStack = ASStackLayoutSpec.vertical()
        titleStack.children = [titleNode, subtitleNode]
        titleStack.spacing = 2.0
        titleStack.justifyContent = .end
        let titleStackInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 4, 4, 4), child: titleStack)
        let overlay = ASOverlayLayoutSpec(child: contentOverlay, overlay: titleStackInset)
    
        return ASOverlayLayoutSpec(child: overlay, overlay: dimNode)
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
    }
    
    func setHighlighted(_ highlighted:Bool) {
        dimNode.alpha = highlighted ? 0.25 : 0.0
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        setHighlighted(false)
    }
}
