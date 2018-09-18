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
    var searchBar:RCSearchBarView!
    var tabScrollView:DualScrollView!
    
    var anonSwitch:AnonSwitch!
    var searchResultsVC:SearchPostsTableViewController!
    
    var isSearching = false
    var isDisplayingSearchResults = false
    var dimView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        
        
        let topInset = UIApplication.deviceInsets.top
        let titleViewHeight = 50 + topInset
        
        searchBar = RCSearchBarView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: titleViewHeight), topInset: topInset)
        view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: titleViewHeight).isActive = true
        searchBar.leftButton.setImage(UIImage(named:"back"), for: .normal)
        searchBar.setup(withDelegate: self)
//        searchBar.textField.isUserInteractionEnabled = false
//
//        for gesture in searchBar.textBubble.gestureRecognizers ?? [] {
//            searchBar.textBubble.removeGestureRecognizer(gesture)
//        }
        
        let titleContentView = searchBar.contentView!
        
        anonSwitch = AnonSwitch(frame: .zero)
        titleContentView.addSubview(anonSwitch)
        anonSwitch.translatesAutoresizingMaskIntoConstraints = false
        anonSwitch.leadingAnchor.constraint(equalTo: titleContentView.leadingAnchor, constant: 16.0).isActive = true
        anonSwitch.centerYAnchor.constraint(equalTo: titleContentView.centerYAnchor).isActive = true
        anonSwitch.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        anonSwitch.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let bgImageView = UIImageView(image: UIImage(named:"GreenBox"))
        view.insertSubview(bgImageView, belowSubview: searchBar)
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bgImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bgImageView.heightAnchor.constraint(equalToConstant:  titleViewHeight + 32.0).isActive = true
        
        let postsTableVC = BestPostsTableViewController()
        postsTableVC.view.clipsToBounds = true
        postsTableVC.willMove(toParentViewController: self)
        self.addChildViewController(postsTableVC)
        view.addSubview(postsTableVC.view)
        postsTableVC.didMove(toParentViewController: self)
        postsTableVC.view.translatesAutoresizingMaskIntoConstraints = false
        postsTableVC.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        postsTableVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        postsTableVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        postsTableVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        dimView.alpha = 0.0
        
        searchResultsVC = SearchPostsTableViewController()
        searchResultsVC.view.clipsToBounds = true
        searchResultsVC.willMove(toParentViewController: self)
        self.addChildViewController(searchResultsVC)
        view.addSubview(searchResultsVC.view)
        searchResultsVC.didMove(toParentViewController: self)
        searchResultsVC.view.translatesAutoresizingMaskIntoConstraints = false
        searchResultsVC.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        searchResultsVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchResultsVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchResultsVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        searchResultsVC.view.alpha = 0.0
        
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
        
        anonSwitch.setProfileImage()
        anonSwitch.setAnonMode(to: UserService.anonMode)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension SearchTabViewController: RCSearchBarDelegate {
    func handleLeftButton() {
        isSearching = false
        searchDidEnd()
        self.searchBar.textField.resignFirstResponder()
        
    }
    
    func searchDidCancel() {
        if !isDisplayingSearchResults {
            handleLeftButton()
        }
    }
    
    func searchTextDidChange(_ text: String?) {
        
    }
    
    func searchDidBegin() {
        isSearching = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dimView.alpha = 1.0
            self.anonSwitch.alpha = 0.0
        })
    }
    
    func searchDidEnd() {
        if !isSearching {
            
            self.isDisplayingSearchResults = false
            self.searchBar.handleClearButton()
            UIView.animate(withDuration: 0.3, animations: {
                self.dimView.alpha = 0.0
                self.searchResultsVC.view.alpha = 0.0
                self.anonSwitch.alpha = 1.0
                self.searchBar.leftButton.alpha = 0.0
            })
        }
    }
    
    func searchTapped(_ text: String) {
        isDisplayingSearchResults = true
        UIView.animate(withDuration: 0.3, animations: {
            self.searchResultsVC.view.alpha = 1.0
            self.anonSwitch.alpha = 0.0
            self.searchBar.leftButton.alpha = 1.0
        })
        searchResultsVC?.setSearch(text: text)
    }
    
    
}
