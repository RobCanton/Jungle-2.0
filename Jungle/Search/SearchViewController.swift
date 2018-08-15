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

enum SearchType:String {
    case popular = "popular"
    case recent = "recent"
}

class SearchViewController:JViewController, ASPagerDelegate, ASPagerDataSource, TabScrollDelegate {
    
    var initialSearch:String?
    var pagerNode:ASPagerNode!
    var topPostsVC:SearchPostsTableViewController!
    var latestPostsVC:SearchPostsTableViewController!
    var searchBar:RCSearchBarView!
    var searchOnAppear = false
    
    var interactor:Interactor? = nil
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        let percentThreshold:CGFloat = 0.3
        let verticalMovement = translation.x / view.bounds.width
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.shouldFinish = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
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
        
        let scrollTabBar = UIView()
        view.addSubview(scrollTabBar)
        scrollTabBar.translatesAutoresizingMaskIntoConstraints = false
        scrollTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollTabBar.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0).isActive = true
        scrollTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollTabBar.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        tabScrollView = DualScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 104, height: 44.0), title1: "POPULAR", title2:"LATEST")
        scrollTabBar.addSubview(tabScrollView)
        tabScrollView.translatesAutoresizingMaskIntoConstraints = false
        tabScrollView.leadingAnchor.constraint(equalTo: scrollTabBar.leadingAnchor, constant: 52.0).isActive = true
         tabScrollView.trailingAnchor.constraint(equalTo: scrollTabBar.trailingAnchor, constant: -52.0).isActive = true
        tabScrollView.topAnchor.constraint(equalTo: scrollTabBar.topAnchor).isActive = true
        tabScrollView.bottomAnchor.constraint(equalTo: scrollTabBar.bottomAnchor).isActive = true
        tabScrollView.delegate = self
        
        let bgImageView = UIImageView(image: UIImage(named:"GreenBox"))
        view.insertSubview(bgImageView, belowSubview: searchBar)
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bgImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bgImageView.heightAnchor.constraint(equalToConstant:  titleViewHeight + 32.0).isActive = true
        
        view.layoutIfNeeded()
        
        
        
        pagerNode = ASPagerNode()
        pagerNode.backgroundColor = bgColor
        view.addSubview(pagerNode.view)
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.view.translatesAutoresizingMaskIntoConstraints = false
        pagerNode.view.leadingAnchor.constraint(equalTo: layout.leadingAnchor).isActive = true
        pagerNode.view.trailingAnchor.constraint(equalTo: layout.trailingAnchor).isActive = true
        pagerNode.view.topAnchor.constraint(equalTo: tabScrollView.bottomAnchor).isActive = true
        pagerNode.view.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true
        pagerNode.reloadData()
        
        searchBar.setup(withDelegate: self)
        searchBar.leftButton.tintColor = UIColor.white
        searchBar.leftButton.setImage(UIImage(named:"back"), for: .normal)
        
        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan))
        edgeSwipe.edges = .left
        view.addGestureRecognizer(edgeSwipe)
        view.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let search = initialSearch {
            searchBar.setText(search)
            topPostsVC?.setSearch(text: search)
            latestPostsVC?.setSearch(text: search)
            initialSearch = nil
        }
        
        if self.searchOnAppear {
            self.searchBar.leftButton.alpha = 0.0
        }
        DispatchQueue.main.async {
            if self.searchOnAppear {
                self.searchOnAppear = false
                self.searchBar.beginEditing()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.backgroundColor = bgColor
        var table:PostsTableViewController

        table = SearchPostsTableViewController()
        table.view.backgroundColor = bgColor
        table.willMove(toParentViewController: self)
        self.addChildViewController(table)
        cellNode.addSubnode(table.node)
        let layoutGuide = cellNode.view.safeAreaLayoutGuide
        table.view.translatesAutoresizingMaskIntoConstraints = false
        table.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        table.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        table.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        table.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 0.0).isActive = true
        if index == 0 {

            topPostsVC = table as! SearchPostsTableViewController
            topPostsVC.type = .popular
        } else {
            latestPostsVC = table as! SearchPostsTableViewController
            latestPostsVC.type = .recent
        }
        
        return cellNode
    }
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 2
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == pagerNode.view else { return }
        let offsetX = scrollView.contentOffset.x
        let viewWidth = view.bounds.width
        let progress = offsetX / viewWidth
        tabScrollView.setProgress(progress, index: 0)
    }
    
    func tabScrollTo(index: Int) {
        self.pagerNode.scrollToPage(at: index, animated: true)
    }
    
    
}


extension SearchViewController: RCSearchBarDelegate {
    func handleLeftButton() {
        print("DISMISS YO!")
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchTextDidChange(_ text: String?) {
        
    }
    
    func searchDidBegin() {
        
    }
    
    func searchDidEnd() {
        
    }
    
    func searchTapped(_ text: String) {
        topPostsVC?.setSearch(text: text)
        latestPostsVC?.setSearch(text: text)
    }
    
    
}

extension SearchViewController: PushTransitionDestinationDelegate {
    func staticTopView() -> UIImageView? {
        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: 70.0)
        let size = CGSize(width: view.bounds.width, height: 70.0)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(frame:rect)
        imageView.image = image
        return imageView
    }
}
