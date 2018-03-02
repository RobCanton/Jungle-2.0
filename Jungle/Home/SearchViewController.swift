//
//  SearchViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class SearchViewController:UIViewController, ASPagerDelegate, ASPagerDataSource {
    
    var initialSearch:String?
    var searchView:SearchTitleView!
    var pagerNode:ASPagerNode!
    
    var latestPostsVC:SearchPostsViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchView = UINib(nibName: "SearchTitleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SearchTitleView
        navigationItem.titleView = searchView
        searchView.setup()
        
        pagerNode = ASPagerNode()
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.backgroundColor = nil
        view.addSubview(pagerNode.view)
        
        let layoutGuide = view.safeAreaLayoutGuide
        pagerNode.view.translatesAutoresizingMaskIntoConstraints = false
        pagerNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        pagerNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        pagerNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        pagerNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        pagerNode.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let search = initialSearch {
            searchView.textField.text = search
            latestPostsVC?.setSearch(text: search)
            initialSearch = nil
        }
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.frame = pagerNode.bounds
        
        latestPostsVC = SearchPostsViewController()
        latestPostsVC.willMove(toParentViewController: self)
        self.addChildViewController(latestPostsVC)
        latestPostsVC.view.frame = cellNode.bounds
        cellNode.addSubnode(latestPostsVC.node)
        let layoutGuide = cellNode.view.safeAreaLayoutGuide
        latestPostsVC.view.translatesAutoresizingMaskIntoConstraints = false
        latestPostsVC.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        latestPostsVC.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        latestPostsVC.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        latestPostsVC.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        return cellNode
    }
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 1
    }
    
}
