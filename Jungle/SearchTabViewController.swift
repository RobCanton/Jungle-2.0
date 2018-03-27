//
//  SearchTabViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-25.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit


struct TrendingHashtag {
    var hastag:String
    var totalCount:Int
    var todayCount:Int
    var score:Double
    var posts:[Post]
}

class SearchTabViewController:UIViewController {
    
    
    @IBOutlet weak var topContainerView:UIView!
    @IBOutlet weak var contentView: UIView!
    
    var trendingHashtagsNode = TrendingHashtagsNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let searchBar = UINib(nibName: "SearchBarView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SearchBarView
        searchBar.frame = topContainerView.bounds
        topContainerView.addSubview(searchBar)
        searchBar.setup()
        contentView.backgroundColor = UIColor.clear
        trendingHashtagsNode.view.frame = contentView.bounds
        contentView.addSubview(trendingHashtagsNode.view)
        
        let contentLayoutGuide = contentView.safeAreaLayoutGuide
        trendingHashtagsNode.view.translatesAutoresizingMaskIntoConstraints = false
        trendingHashtagsNode.view.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor).isActive = true
        trendingHashtagsNode.view.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor).isActive = true
        trendingHashtagsNode.view.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor).isActive = true
        trendingHashtagsNode.view.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor).isActive = true
        trendingHashtagsNode.getTrendingHastags()
        trendingHashtagsNode.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        trendingHashtagsNode.clearSelection()
    }
    
    
}

protocol TrendingHashtagsDelegate: class {
    func open(hashtag:String)
    func open(post:Post)
}


extension SearchTabViewController: TrendingHashtagsDelegate {
    func open(post: Post) {
        let controller = SinglePostViewController()
        controller.hidesBottomBarWhenPushed = true
        controller.post = post
        self.navigationController?.pushViewController(controller, animated: true)

    }
    
    func open(hashtag: String) {
        print("OPEN TAG")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.initialSearch = hashtag
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



class TrendingHashtagsNode:ASDisplayNode, ASTableDelegate, ASTableDataSource {
    var tableNode = ASTableNode()
    var trendingHashtags = [TrendingHashtag]() {
        didSet {
            print("GOT EM!: \(trendingHashtags)")
            tableNode.reloadData()
        }
    }
    
    var selectedRow:IndexPath?
    weak var delegate:TrendingHashtagsDelegate?
    
    override init() {
        super.init()
        backgroundColor = UIColor.clear
        automaticallyManagesSubnodes = true
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.backgroundColor = UIColor.clear
    }
    
    override func didLoad() {
        super.didLoad()
        //tableNode.view.separatorColor = subtitleColor.withAlphaComponent(0.25)
        tableNode.view.separatorStyle = .none
        //tableNode.view.delaysContentTouches = false
    }
    
    
    func clearSelection() {
        if let row = selectedRow {
            tableNode(tableNode, didDeselectRowAt: row)
        }
        for node in tableNode.visibleNodes {
            if let cell = node as? TrendingHastagCellNode {
                cell.clearSelection()
            }
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: tableNode)
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return trendingHashtags.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if indexPath.section == 0 {
            let cell = ASTextCellNode()
            cell.text = "Trending"
            cell.textInsets = UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0)
            cell.textAttributes = [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 24.0),
                NSAttributedStringKey.foregroundColor: UIColor.black
            ]
            return cell
        }
        let cell = TrendingHastagCellNode(hashtag: trendingHashtags[indexPath.row])
        cell.delegate = delegate
        cell.selectionStyle = .none
        return cell
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        let node = tableNode.nodeForRow(at: indexPath) as! TrendingHastagCellNode
        node.setSelected(true)
        selectedRow = indexPath
        delegate?.open(hashtag: "#\(trendingHashtags[indexPath.row].hastag)")
    }
    
    func tableNode(_ tableNode: ASTableNode, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        let node = tableNode.nodeForRow(at: indexPath) as! TrendingHastagCellNode
        node.setSelected(false)
        selectedRow = nil
    }
    
    func tableNode(_ tableNode: ASTableNode, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        let node = tableNode.nodeForRow(at: indexPath) as! TrendingHastagCellNode
        node.setSelected(true)
    }
    
    func tableNode(_ tableNode: ASTableNode, didUnhighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        let node = tableNode.nodeForRow(at: indexPath) as! TrendingHastagCellNode
        node.setSelected(false)
    }
    
    func getTrendingHastags() {
        let trendingRef = database.child("hashtags/trending")
        trendingRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let dict = snapshot.value as? [String:[String:Int]] else { return }
            var _trendingHashtags = [TrendingHashtag]()
            var count = 0
            for (hashtag, metadata) in dict {
                SearchService.searchFor(text: "#\(hashtag)", limit: 5, offset: 0) { documents in
                    
                    let totalCount = metadata["total"] ?? 0
                    let todayCount = metadata["today"] ?? 0
                    
                    var posts = [Post]()
                    
                    for document in documents {
                        if let postID = document["objectID"] as? String,
                            let post = Post.parse(id: postID, document) {
                            posts.append(post)
                        }
                    }
                    
                    let score = Double(totalCount) + Double(todayCount) * 1.5
                    
                    let trendingHashtag = TrendingHashtag(hastag: hashtag, totalCount: totalCount, todayCount: todayCount, score: score, posts: posts)
                    _trendingHashtags.append(trendingHashtag)
                    
                    count += 1
                    
                    if count >= dict.count {
                        self.trendingHashtags = _trendingHashtags.sorted(by: { $0.score > $1.score })
                        self.tableNode.reloadData()
                        print("DICT!: \(self.trendingHashtags)")
                    }
                }
            }
            
        })
    }
}

class TrendingHastagCellNode:ASCellNode, ASCollectionDelegate, ASCollectionDataSource {
    
    var titleNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var collectionNode:ASCollectionNode!
    var hashtag:TrendingHashtag!
    
    var selectedItem:IndexPath?
    
    weak var delegate:TrendingHashtagsDelegate?
    
    required init(hashtag:TrendingHashtag) {
        super.init()
        self.hashtag = hashtag
        backgroundColor = UIColor.clear
        automaticallyManagesSubnodes = true
        titleNode.attributedText = NSAttributedString(string: "#\(hashtag.hastag)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 20.0),
            NSAttributedStringKey.foregroundColor: UIColor.black
        ])
        
        subtitleNode.attributedText = NSAttributedString(string: "\(hashtag.todayCount) posts today. \(hashtag.totalCount) posts this week.", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
        ])
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12.0
        layout.minimumInteritemSpacing = 12.0
        layout.sectionInset = UIEdgeInsetsMake(0, 16.0, 0.0, 16.0)
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.backgroundColor = UIColor.clear
        collectionNode.delegate = self
        collectionNode.dataSource = self
        
        collectionNode.reloadData()
        collectionNode.layer.masksToBounds = false
        collectionNode.clipsToBounds = false
        self.clipsToBounds = false
        self.layer.masksToBounds = false
    }
    
    override func didLoad() {
        super.didLoad()
        collectionNode.view.showsHorizontalScrollIndicator = false
        collectionNode.view.clipsToBounds = false
        collectionNode.view.layer.masksToBounds = false
        collectionNode.view.delaysContentTouches = false
        self.clipsToBounds = false
        self.layer.masksToBounds = false
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        collectionNode.style.height = ASDimension(unit: .points, value: 172)
        let titleStack = ASStackLayoutSpec.vertical()
        titleStack.children = [titleNode]
        titleStack.spacing = 2.0
        
        let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0.0, 16.0, 2.0, 16.0), child: titleStack)
        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.children = [titleInset, collectionNode]
        verticalStack.spacing = 4.0
        
        let inset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(8.0, 0, 12.0, 0), child: verticalStack)
        return inset
    }
    
    func clearSelection() {
        if let item = selectedItem {
            collectionNode(collectionNode, didDeselectItemAt: item)
        }
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return hashtag.posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let cell = MiniPostContainerNode(post: hashtag.posts[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let node = collectionNode.nodeForItem(at: indexPath) as! MiniPostContainerNode
        node.setSelected(true)
        selectedItem = indexPath
        delegate?.open(post: hashtag.posts[indexPath.item])
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        let node = collectionNode.nodeForItem(at: indexPath) as! MiniPostContainerNode
        node.setSelected(false)
        selectedItem = nil
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didHighlightItemAt indexPath: IndexPath) {
        let node = collectionNode.nodeForItem(at: indexPath) as! MiniPostContainerNode
        node.setSelected(true)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didUnhighlightItemAt indexPath: IndexPath) {
        let node = collectionNode.nodeForItem(at: indexPath) as! MiniPostContainerNode
        node.setSelected(false)
    }
    
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize(width: UIScreen.main.bounds.width * 0.60, height: collectionNode.bounds.height))
    }
    
    func setSelected(_ selected:Bool) {
        backgroundColor = selected ? UIColor(white: 0.0, alpha: 0.1) : UIColor.clear
    }
}

class MiniPostContainerNode:ASCellNode {
    var miniPostNode:MiniPostNode!
    var post:Post!
    required init(post: Post) {
        super.init()
        self.post = post
        miniPostNode = MiniPostNode(post: post)
        automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        super.didLoad()
        view.clipsToBounds = false
        view.applyShadow(radius: 8.0, opacity: 0.1, offset: CGSize(width: 0.0,height: 4.0), color: UIColor.black, shouldRasterize: false)
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: miniPostNode)
    }
    
    func setSelected(_ selected:Bool) {
        print("setSelected: \(selected)")
        miniPostNode.backgroundColor = selected ? post.anon.color.withAlphaComponent(0.75) : post.anon.color
    }
}

class MiniPostNode:ASDisplayNode {
    var avatarNode = ASImageNode()
    var titleNode = ASTextNode()
    var subnameNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var postTextNode = ASTextNode()
    var postImageNode = ASNetworkImageNode()
    var metaTextNode = ASTextNode()
    
    let avatarSize:CGFloat = 24.0
    
    var post:Post!
    
    private(set) var textColor = hexColor(from: "708078")
    
    required init(post: Post) {
        super.init()
        backgroundColor = post.anon.color
        automaticallyManagesSubnodes = true
        self.post = post
        avatarNode.backgroundColor = post.anon.color
        avatarNode.style.width = ASDimension(unit: .points, value: avatarSize)
        avatarNode.style.height = ASDimension(unit: .points, value: avatarSize)
        
        titleNode.attributedText = NSAttributedString(string: post.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: post.anon.color
        ])
        
        var locationStr = ""
        if let location = post.location {
            locationStr = " · \(location.locationStr)"
        }
        
        let subtitleStr = "\(post.createdAt.timeSinceNow())\(locationStr)"
        
        subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: textColor
            ])
        
        if let attachments = post.attachments {
            if attachments.images.count > 0 {
                let image = attachments.images[0]
                let color =  hexColor(from: image.colorHex)
                postImageNode.backgroundColor = color

                postImageNode.url = image.url
                
            }
        }
        
        let metaStr = "\(post.votes) points · \(post.comments) replies"
        metaTextNode.attributedText = NSAttributedString(string: metaStr, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        
        
        postTextNode.truncationMode = .byWordWrapping
        
        let postFont = post.attachments != nil ? Fonts.medium(ofSize: 15.0) : Fonts.medium(ofSize: 18.0) 
        
        postTextNode.attributedText = NSAttributedString(string: post.text, attributes: [
            NSAttributedStringKey.font: postFont,
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
    }
    
    override func didLoad() {
        super.didLoad()
//        self.layer.borderWidth = 0.5
//        self.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
        self.layer.cornerRadius = 16.0
        self.clipsToBounds = true
        
        avatarNode.layer.cornerRadius = avatarSize / 2
        avatarNode.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
        
        let subnameCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subnameNode)
        
        let hTitleStack = ASStackLayoutSpec.horizontal()
        hTitleStack.children = [titleNode]
        hTitleStack.spacing = 4.0
        
        if !subnameNode.isHidden {
            hTitleStack.children?.append(subnameCenterY)
        }
        
        let nameStack = ASStackLayoutSpec.vertical()
        nameStack.spacing = 1.0
        nameStack.children = [hTitleStack, subtitleNode]
        
        let imageStack = ASStackLayoutSpec.horizontal()
        imageStack.children = [nameStack]
        imageStack.spacing = 4.0
        
        let textInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0.0, 12.0, 8.0, 12.0), child: postTextNode)
        let metaInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(6.0, 12.0, 0.0, 12.0), child: metaTextNode)
        
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = []
        contentStack.spacing = 0.0
        
        
        if let text = post?.text, !text.isEmpty {
            contentStack.children?.append(textInset)
        }
        
        if let attachments = post?.attachments,
            attachments.images.count > 0 {
                contentStack.children?.append(postImageNode)
            postImageNode.style.flexGrow = 1.0
            postTextNode.maximumNumberOfLines = 2
        } else {
            textInset.style.flexGrow = 1.0
            postTextNode.maximumNumberOfLines = 6
        }
        
        contentStack.children?.append(metaInset)
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(8.0, 0.0, 8.0, 0.0), child: contentStack)
    }
    
    
}