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
        backgroundColor = UIColor.white
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleTrendingTagsNotification), name: SearchService.trendingTagsNotification, object: nil)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        topTitle.attributedText = NSAttributedString(string: "TRENDING TAGS", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.foregroundColor: UIColor.black
            ])
        
        midTitle.attributedText = NSAttributedString(string: "TOP POSTS", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 13.0),
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.foregroundColor: UIColor.black
            ])
    }
    
    @objc func handleTrendingTagsNotification() {
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

class TagCircleCellNode:ASCellNode {
    
    var imageNode = ASNetworkImageNode()
    var titleNode = ASTextNode()
    var timeNode = ASTextNode()
    
    required init(tag:TrendingHashtag) {
        super.init()
        automaticallyManagesSubnodes = true
//        if let video = post.attachments?.video {
//            imageNode.url = video.thumbnail_url
//        }
        //layer.cornerRadius = 8.0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        SearchService.searchFor(text: "#\(tag.hastag)", limit: 1, offset: 0) { posts, _ in
            if posts.count > 0 {
                let post = posts[0]
                self.imageNode.url = post.attachments?.video?.thumbnail_url
                self.timeNode.attributedText = NSAttributedString(string: post.createdAt.timeSinceNowWithAgo(), attributes: [
                    NSAttributedStringKey.font: Fonts.medium(ofSize: 12.0),
                    NSAttributedStringKey.foregroundColor: grayColor,
                    NSAttributedStringKey.paragraphStyle: paragraphStyle
                    ])
            }
        }
        
        imageNode.backgroundColor = grayColor
        imageNode.style.width = ASDimension(unit: .points, value: 100)
        imageNode.style.height = ASDimension(unit: .points, value: 100)
        imageNode.layer.cornerRadius = 50
        imageNode.clipsToBounds = true
        
        titleNode.attributedText = NSAttributedString(string: "#\(tag.hastag)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: tagColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])
        titleNode.maximumNumberOfLines = 1
        titleNode.truncationMode = .byTruncatingTail
        titleNode.textContainerInset = UIEdgeInsetsMake(0, 1, 2, 1)
        
        timeNode.attributedText = NSAttributedString(string: "2h ago", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: grayColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])
        
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

        //let overlay = ASOverlayLayoutSpec(child: imageNode, overlay: textStack)
        return ASInsetLayoutSpec(insets: .zero, child: contentStack)
    }
}