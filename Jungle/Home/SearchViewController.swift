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

class SearchViewController:UIViewController, ASPagerDelegate, ASPagerDataSource, UITextFieldDelegate {
    
    var initialSearch:String?
    var pagerNode:ASPagerNode!
    var latestPostsVC:SearchPostsViewController!
    var searchBar:RCSearchBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        
        searchBar = RCSearchBarView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 70.0))
        view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        let layout = view.safeAreaLayoutGuide
        searchBar.leadingAnchor.constraint(equalTo: layout.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: layout.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: layout.topAnchor, constant: -20).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        
        view.layoutIfNeeded()
        
        pagerNode = ASPagerNode()
        pagerNode.backgroundColor = bgColor
        view.addSubview(pagerNode.view)
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.view.translatesAutoresizingMaskIntoConstraints = false
        pagerNode.view.leadingAnchor.constraint(equalTo: layout.leadingAnchor).isActive = true
        pagerNode.view.trailingAnchor.constraint(equalTo: layout.trailingAnchor).isActive = true
        pagerNode.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        pagerNode.view.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true
        pagerNode.reloadData()
        
        searchBar.setup(withDelegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if let search = initialSearch {
            searchBar.textField.text = search
            latestPostsVC?.setSearch(text: search)
            initialSearch = nil
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.backgroundColor = bgColor
        latestPostsVC = SearchPostsViewController()
        latestPostsVC.view.backgroundColor = bgColor
        latestPostsVC.willMove(toParentViewController: self)
        self.addChildViewController(latestPostsVC)
        cellNode.addSubnode(latestPostsVC.node)
        let layoutGuide = cellNode.view.safeAreaLayoutGuide
        latestPostsVC.view.translatesAutoresizingMaskIntoConstraints = false
        latestPostsVC.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        latestPostsVC.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        latestPostsVC.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        latestPostsVC.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 0.0).isActive = true
        
        return cellNode
    }
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 1
    }
    @IBAction func handleDismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension SearchViewController: RCSearchBarDelegate {
    func handleLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchTextDidChange(_ text: String?) {
        
    }
    
    func searchDidBegin() {
        
    }
    
    func searchDidEnd() {
        
    }
    
    func searchTapped(_ text: String) {
        latestPostsVC.setSearch(text: text)
    }
    
    
}

extension SearchViewController: PushTransitionDestinationDelegate {
    func staticTopView() -> UIImageView? {
        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: 64.0)
        let size = CGSize(width: view.bounds.width, height: 64.0)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(frame:rect)
        imageView.image = image
        return imageView
    }
}
