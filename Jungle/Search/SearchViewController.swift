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

class SearchViewController:JViewController, ASPagerDelegate, ASPagerDataSource {
    
    var initialSearch:String?
    var pagerNode:ASPagerNode!
    var latestPostsVC:SearchPostsTableViewController!
    var searchBar:RCSearchBarView!
    
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
        latestPostsVC = SearchPostsTableViewController()
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
        latestPostsVC?.setSearch(text: text )
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
