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
    func postOpen(tag:String)
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
        backgroundColor = currentTheme.backgroundColor
        
        style.height = ASDimension(unit: .points, value: 230)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .horizontal
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.contentInset = UIEdgeInsetsMake(8, 12, 8, 12)
        collectionNode.style.height = ASDimension(unit: .points, value: 160)
        collectionNode.reloadData()
        collectionNode.backgroundColor = currentTheme.backgroundColor
        NotificationCenter.default.addObserver(self, selector: #selector(handleTrendingTagsNotification), name: SearchService.trendingTagsNotification, object: nil)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        topTitle.attributedText = NSAttributedString(string: "TRENDING TAGS", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
            ])
        
        midTitle.attributedText = NSAttributedString(string: "TOP POSTS", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor
            ])
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
        let centerTopTitle = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumXY, child: topTitle)
        centerTopTitle.style.height = ASDimension(unit: .points, value: 35)
        let centerMidTitle = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumXY, child: midTitle)
        centerMidTitle.style.height = ASDimension(unit: .points, value: 35)
        let stack = ASStackLayoutSpec.vertical()
        stack.children = [centerTopTitle, collectionNode, centerMidTitle]
        return ASInsetLayoutSpec(insets: .zero, child: stack)
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return hashtags.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let cell = TagCircleCellNode(tag:hashtags[indexPath.row])
        return cell
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        delegate?.postOpen(tag: "#\(hashtags[indexPath.row].hastag)")
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

class TagCircleCellNode:ASCellNode, ASNetworkImageNodeDelegate {
    
    var imageNode = ASNetworkImageNode()
    var titleNode = ASTextNode()
    var timeNode = ASTextNode()
    var post:Post?
    var previewImageNode:BadgeNode!
    var tag:TrendingHashtag?
    
    required init(tag:TrendingHashtag) {
        super.init()
        self.tag = tag
        automaticallyManagesSubnodes = true
//        if let video = post.attachments?.video {
//            imageNode.url = video.thumbnail_url
//        }
        //layer.cornerRadius = 8.0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        
        self.imageNode.shouldCacheImage = true
        let thumbnailRef = storage.child("publicPosts/\(tag.postID)/thumbnail.gif")
        thumbnailRef.downloadURL { url, error in
            self.imageNode.url = url
        }
        
        self.timeNode.attributedText = NSAttributedString(string: tag.lastPostedAt.timeSinceNowWithAgo(), attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryTextColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])
        
        imageNode.backgroundColor = currentTheme.highlightedBackgroundColor
        imageNode.style.width = ASDimension(unit: .points, value: 100)
        imageNode.style.height = ASDimension(unit: .points, value: 100)
        imageNode.layer.cornerRadius = 50
        imageNode.clipsToBounds = true
        
        titleNode.attributedText = NSAttributedString(string: "#\(tag.hastag)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: currentTheme.secondaryAccentColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])
        titleNode.maximumNumberOfLines = 1
        titleNode.truncationMode = .byTruncatingTail
        titleNode.textContainerInset = UIEdgeInsetsMake(0, 1, 2, 1)
        
    }
    
    override func didLoad() {
        super.didLoad()
        guard let tag = self.tag else { return }
        let button = UIButton(type: .custom)
        let title = numericShorthand(tag.count)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Fonts.semiBold(ofSize: 12.0)
        button.backgroundColor = tagColor
        
        view.addSubview(button)
        let textWidth = UILabel.size(text: title, height: 28, font: Fonts.semiBold(ofSize: 14.0)).width
        button.translatesAutoresizingMaskIntoConstraints = false
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -1).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: 100 - 28 - 1).isActive = true
        //button.widthAnchor.constraint(greaterThanOrEqualToConstant: 32.0).isActive = true
        if textWidth < 28 {
            button.widthAnchor.constraint(equalToConstant: 28).isActive = true
        } else {
            button.widthAnchor.constraint(equalToConstant: textWidth + 12).isActive = true
        }
        button.heightAnchor.constraint(equalToConstant: 28).isActive = true
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.sizeToFit()
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let textStack = ASStackLayoutSpec.vertical()
        //textStack.alignContent = .
        //textStack.justifyContent = .end
        textStack.spacing = 0.0
        textStack.children = [titleNode, timeNode]
        
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.spacing = 6.0
        contentStack.children = [imageNode, textStack]
        
        return ASInsetLayoutSpec(insets: .zero, child: contentStack)
    }
    
    func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
        guard let post = self.post else { return }
//        guard let image = previewNode.imageNode.animatedImage else { return }
//        thumbnailCache.add(key: post.key, item: image)
    }
}
