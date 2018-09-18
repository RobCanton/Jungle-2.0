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

class SearchViewController:JViewController {
    
    var initialSearch:String?
    var pagerNode:ASPagerNode!
    
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
        
        let bgImageView = UIImageView(image: UIImage(named:"GreenBox"))
        view.insertSubview(bgImageView, belowSubview: searchBar)
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bgImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bgImageView.heightAnchor.constraint(equalToConstant:  titleViewHeight).isActive = true
        
        view.layoutIfNeeded()
        
        searchBar.setup(withDelegate: self)
        searchBar.leftButton.tintColor = UIColor.white
        searchBar.leftButton.setImage(UIImage(named:"back"), for: .normal)
        
        latestPostsVC = SearchPostsTableViewController()
        latestPostsVC.type = .recent
        latestPostsVC.view.backgroundColor = bgColor
        latestPostsVC.willMove(toParentViewController: self)
        self.addChildViewController(latestPostsVC)
        view.insertSubview(latestPostsVC.view, at: 0)
        
        latestPostsVC.view.translatesAutoresizingMaskIntoConstraints = false
        latestPostsVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        latestPostsVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        latestPostsVC.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        latestPostsVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

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
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
}


extension SearchViewController: RCSearchBarDelegate {
    func handleLeftButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchTextDidChange(_ text: String?) {
        
    }
    
    func searchDidCancel() {

    }
    
    func searchDidBegin() {
        
    }
    
    func searchDidEnd() {
        
    }
    
    func searchTapped(_ text: String) {
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
