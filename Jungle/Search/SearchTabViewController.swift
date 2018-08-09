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


class TrendingHashtag {
    var hastag:String
    var count:Int
    var posts:[Post]
    
    init(hashtag:String, count:Int,posts:[Post]) {
        self.hastag = hashtag
        self.count = count
        self.posts = posts
    }
}

extension TrendingHashtag:Comparable, Equatable {
    static func < (lhs: TrendingHashtag, rhs: TrendingHashtag) -> Bool {
        return lhs.count < rhs.count
    }
    
    
    static func == (lhs: TrendingHashtag, rhs: TrendingHashtag) -> Bool {
        return lhs.count == rhs.count
    }
}


class SearchTabViewController:JViewController, RCSearchBarDelegate {
    @IBOutlet weak var topContainerView:UIView!
    @IBOutlet weak var contentView: UIView!
    
    var pushTransitionManager = PushTransitionManager()
    var trendingHashtagsNode:TrendingHashtagsNode!
    var searchBar:RCSearchBarView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        
        
        let topInset = UIApplication.deviceInsets.top
        let titleViewHeight = 50 + topInset
        
        searchBar = RCSearchBarView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: titleViewHeight), topInset: topInset)
        view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        let layout = view.safeAreaLayoutGuide
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: titleViewHeight).isActive = true
        
        let bgImageView = UIImageView(image: UIImage(named:"GreenBox"))
        view.insertSubview(bgImageView, belowSubview: searchBar)
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bgImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bgImageView.heightAnchor.constraint(equalToConstant:  titleViewHeight).isActive = true
        
        view.layoutIfNeeded()
        
        trendingHashtagsNode = TrendingHashtagsNode()
        view.addSubview(trendingHashtagsNode.view)
        
        trendingHashtagsNode.view.translatesAutoresizingMaskIntoConstraints = false
        trendingHashtagsNode.view.leadingAnchor.constraint(equalTo: layout.leadingAnchor).isActive = true
        trendingHashtagsNode.view.trailingAnchor.constraint(equalTo: layout.trailingAnchor).isActive = true
        trendingHashtagsNode.view.topAnchor.constraint(equalTo: layout.topAnchor, constant: 50).isActive = true
        trendingHashtagsNode.view.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true
        trendingHashtagsNode.delegate = self
        view.layoutIfNeeded()
        
        searchBar.setup(withDelegate: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.addGradient()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        trendingHashtagsNode.clearSelection()
    }
    
    func handleLeftButton() {
        
    }
    
    func handleRightButton() {
        
    }
    
    func searchTextDidChange(_ text: String?) {
        
    }
    
    func searchDidBegin() {
        
    }
    
    func searchDidEnd() {
        
    }
    
    func searchTapped(_ text: String) {
        
    }
    
}

protocol TrendingHashtagsDelegate: class {
    func open(hashtag:String)
    func open(post:Post)
}


extension SearchTabViewController: TrendingHashtagsDelegate {
    func open(post: Post) {
//        let controller = SinglePostViewController()
//        controller.hidesBottomBarWhenPushed = true
//        controller.post = post
//

    }
    
    func open(hashtag: String) {
        print("YOOO!")
        let vc = SearchViewController()
        vc.initialSearch = hashtag
        var navBarHeight = 50 + UIApplication.deviceInsets.top
        pushTransitionManager.navBarHeight = navBarHeight
        vc.interactor = pushTransitionManager.interactor
        vc.transitioningDelegate = pushTransitionManager
        self.present(vc, animated: true, completion: nil)
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
    
    var refreshControl:UIRefreshControl!
    
    var selectedRow:IndexPath?
    weak var delegate:TrendingHashtagsDelegate?
    
    override init() {
        super.init()
        backgroundColor = UIColor.clear
        automaticallyManagesSubnodes = true
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.backgroundColor = UIColor.clear
        
        trendingHashtags = SearchService.trendingHashtags
    }
    
    override func didLoad() {
        super.didLoad()
        tableNode.view.separatorStyle = .none
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
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        if indexPath.section == 0 {
            let cell = ASTextCellNode()
            cell.text = "Trending"
            cell.textInsets = UIEdgeInsetsMake(16.0, 16.0, 12.0, 16.0)
            cell.selectionStyle = .none
            cell.textAttributes = [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 24.0),
                NSAttributedStringKey.foregroundColor: UIColor.black,
                NSAttributedStringKey.paragraphStyle: paragraphStyle
            ]
            return cell
        }
        
        let cell = ASTextCellNode()
        cell.text = "#\(trendingHashtags[indexPath.row].hastag)"
        cell.textInsets = UIEdgeInsetsMake(12.0, 16.0, 12.0, 16.0)
        cell.textAttributes = [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 18.0),
            NSAttributedStringKey.foregroundColor: tagColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
//        let node = tableNode.nodeForRow(at: indexPath) as! TrendingHastagCellNode
//        node.setSelected(true)
        selectedRow = indexPath
        delegate?.open(hashtag: "#\(trendingHashtags[indexPath.row].hastag)")
    }
    
    func tableNode(_ tableNode: ASTableNode, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
//        let node = tableNode.nodeForRow(at: indexPath) as! TrendingHastagCellNode
//        node.setSelected(false)
        selectedRow = nil
    }
    
    func tableNode(_ tableNode: ASTableNode, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
//        let node = tableNode.nodeForRow(at: indexPath) as! TrendingHastagCellNode
//        node.setSelected(true)
    }
    
    func tableNode(_ tableNode: ASTableNode, didUnhighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
//        let node = tableNode.nodeForRow(at: indexPath) as! TrendingHastagCellNode
//        node.setSelected(false)
    }

    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        NotificationCenter.default.addObserver(self, selector: #selector(trendingHashtagsUpdated), name: SearchService.trendingTagsNotification, object: nil)
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        NotificationCenter.default.removeObserver(self, name: SearchService.trendingTagsNotification, object: nil)
    }
    
    @objc func trendingHashtagsUpdated() {
        trendingHashtags = SearchService.trendingHashtags
        tableNode.reloadData()
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
        
//        subtitleNode.attributedText = NSAttributedString(string: "\(hashtag.todayCount) posts today. \(hashtag.totalCount) posts this week.", attributes: [
//            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
//            NSAttributedStringKey.foregroundColor: UIColor.gray
//        ])
        
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
        return 0//hashtag.posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        return ASCellNode()
//        let cell = MiniPostContainerNode(post: hashtag.posts[indexPath.row])
//        cell.selectionStyle = .none
//        return cell
    }
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let node = collectionNode.nodeForItem(at: indexPath) as! MiniPostContainerNode
        node.setSelected(true)
        selectedItem = indexPath
//        delegate?.open(post: hashtag.posts[indexPath.item])
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
        view.applyShadow(radius: 8.0, opacity: 0.15, offset: CGSize(width: 0.0,height: 4.0), color: UIColor.black, shouldRasterize: false)
        
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

        
        let metaStr = "\(post.votes) points · \(post.numReplies) replies"
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
        
//        if let attachments = post?.attachments,
////            attachments.images.count > 0 {
////                contentStack.children?.append(postImageNode)
////            postImageNode.style.flexGrow = 1.0
////            postTextNode.maximumNumberOfLines = 2
//        } else {
//            textInset.style.flexGrow = 1.0
//            postTextNode.maximumNumberOfLines = 6
//        }
        
        contentStack.children?.append(metaInset)
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(8.0, 0.0, 8.0, 0.0), child: contentStack)
    }
    
    
}
