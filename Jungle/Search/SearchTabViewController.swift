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


class SearchTabViewController:JViewController {
    @IBOutlet weak var topContainerView:UIView!
    @IBOutlet weak var contentView: UIView!
    
    var pushTransitionManager = PushTransitionManager()
    var trendingHashtagsNode:TrendingHashtagsNode!
    var searchBar:RCSearchBarView!
    var tabScrollView:DualScrollView!
    
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
        
        searchBar.setup()
        searchBar.textField.isUserInteractionEnabled = false
        
        for gesture in searchBar.textBubble.gestureRecognizers ?? [] {
            searchBar.textBubble.removeGestureRecognizer(gesture)
        }
        
        let bgImageView = UIImageView(image: UIImage(named:"GreenBox"))
        view.insertSubview(bgImageView, belowSubview: searchBar)
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bgImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bgImageView.heightAnchor.constraint(equalToConstant:  titleViewHeight + 32.0).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSearchView))
        searchBar.textBubble.addGestureRecognizer(tap)
        
        trendingHashtagsNode = TrendingHashtagsNode()
        view.addSubview(trendingHashtagsNode.view)
        
        trendingHashtagsNode.view.translatesAutoresizingMaskIntoConstraints = false
        trendingHashtagsNode.view.leadingAnchor.constraint(equalTo: layout.leadingAnchor).isActive = true
        trendingHashtagsNode.view.trailingAnchor.constraint(equalTo: layout.trailingAnchor).isActive = true
        trendingHashtagsNode.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        trendingHashtagsNode.view.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true
        trendingHashtagsNode.delegate = self
        trendingHashtagsNode.backgroundColor = bgColor
        
        view.layoutIfNeeded()
        
    }
    
    @objc func showSearchView() {
        print("SHOW DAT SEARCH!")
        
        let vc = SearchViewController()
        let navBarHeight = 50 + UIApplication.deviceInsets.top
        pushTransitionManager.navBarHeight = navBarHeight
        vc.interactor = pushTransitionManager.interactor
        vc.transitioningDelegate = pushTransitionManager
        vc.searchOnAppear = true
        self.present(vc, animated: false, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        selectedRow = indexPath
        delegate?.open(hashtag: "#\(trendingHashtags[indexPath.row].hastag)")
    }
    
    func tableNode(_ tableNode: ASTableNode, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        selectedRow = nil
    }
    
    func tableNode(_ tableNode: ASTableNode, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
    }
    
    func tableNode(_ tableNode: ASTableNode, didUnhighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
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
