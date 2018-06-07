//
//  PostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-21.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase
import Alamofire
import Pulley

enum PostsTableType {
    case newest, popular, nearby
}

class PostsTableViewController: ASViewController<ASDisplayNode>, NewPostsButtonDelegate {
    
    var posts = [Post]()
    var tableNode = ASTableNode()
    
    var refreshControl:UIRefreshControl!
    
    var transitionManager = LightboxTransitionManager()
    
    var pushTransitionManager = PushTransitionManager()
    
    var newPostsView:NewPostsView!
    
    var headerCell:ASCellNode? {
        get {
            return nil
        }
    }
    
    struct State {
        var posts: [Post]
        var postKeys:[String:Bool]
        var fetchingMore: Bool
        var lastPostTimestamp:Double?
        var lastScore:Double?
        
        var endReached:Bool
        var isFirstLoad:Bool
        static let empty = State(posts: [], postKeys: [:], fetchingMore: false, lastPostTimestamp: nil, lastScore:nil, endReached: false, isFirstLoad: true)
    }
    
    var state = State.empty
    
    var newPostsListener:ListenerRegistration?
    
    var locationHeader:UIView?
    
    var shouldBatchFetch = true
    
    enum Action {
        case beginBatchFetch
        case endBatchFetch(posts: [Post])
        case insertNewBatch(posts: [Post])
        case removePost(at:Int)
        case endReached()
        case firstLoadComplete()
    }
    
    init() {
        super.init(node: ASDisplayNode())

//        if type == .nearby {
//            NotificationCenter.default.addObserver(self, selector: #selector(handleLocationUpdate), name: GPSService.locationUpdatedNotification, object: nil)
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        tableNode.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        var layoutGuide:UILayoutGuide!
        
        layoutGuide = view.safeAreaLayoutGuide
        
        tableNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        tableNode.view.contentInsetAdjustmentBehavior = .never
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.separatorColor = UIColor(white: 0.85, alpha: 1.0)
        tableNode.view.showsVerticalScrollIndicator = false
        tableNode.view.delaysContentTouches = false
        tableNode.view.backgroundColor = hexColor(from: "#eff0e9")
        
        //tableNode.allowsSelection = false
        tableNode.reloadData()
        tableNode.clipsToBounds = false
        self.view.clipsToBounds = false
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableNode.view.refreshControl = refreshControl
        
        newPostsView = NewPostsView(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: 44.0))
        view.addSubview(newPostsView)
        
        newPostsView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        newPostsView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        seeNewPostsTopAnchor = newPostsView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -44.0)
        seeNewPostsTopAnchor?.isActive = true
        newPostsView.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        newPostsView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        newPostsListener?.remove()
        
        if let postCellNodes = tableNode.visibleNodes as? [PostCellNode] {
            for node in postCellNodes {
                node.setSelected(false)
            }
        }
         
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !state.isFirstLoad {
            listenForNewPosts()
        }
    }
    
    @objc func handleLocationUpdate() {
       tableNode.reloadData()
    }
    
    var seeNewPostsTopAnchor:NSLayoutConstraint?
    
    func showSeeNewPosts(_ show:Bool) {
        
        UIView.animate(withDuration: 0.60, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.seeNewPostsTopAnchor?.constant = show ? 0.0 : -44.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        if refreshControl.isRefreshing { return false }
        return shouldBatchFetch
    }
    
    func listenForNewPosts() {
//        if type == .popular || type == .nearby {
//            return
//        }
//
//        newPostsListener?.remove()
//        let postsRef = firestore.collection("posts")
//            .whereField("status", isEqualTo: "active")
//            .whereField("parent", isEqualTo: "NONE")
//            .order(by: "createdAt", descending: true).limit(to: 1)
//
//
//        newPostsListener = postsRef.addSnapshotListener() { snapshot, err in
//            print("NEW POST TINGS!")
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                if snapshot!.documents.count > 0 {
//                    let firstDocument = snapshot!.documents[0]
//                    let key = firstDocument.documentID
//                    if self.state.postKeys[key] == nil {
//                        if let _ = Post.parse(id: key, firstDocument.data()) {
//                            if let pendingPostKey = UploadService.pendingPostKey, key == pendingPostKey {
//                                UploadService.pendingPostKey = nil
//                                self.handleRefresh()
//                            } else {
//                                self.showSeeNewPosts(true)
//                            }
//                        }
//                    }
//                }
//            }
//        }
        
    }
    
    @objc func handleRefresh() {
        self.showSeeNewPosts(false)
//
//        if type == .popular {
//
//            context?.cancelBatchFetching()
//
//            state = .empty
//            PostsService.getPopularPosts(existingKeys: state.postKeys, lastScore: state.lastScore) { posts, endReached in
//
//                if endReached {
//                    let oldState = self.state
//                    self.state = PostsTableViewController.handleAction(.endReached(), fromState: oldState)
//                }
//                let action = Action.endBatchFetch(posts: posts)
//                let oldState = self.state
//                self.state = PostsTableViewController.handleAction(action, fromState: oldState)
//                self.tableNode.reloadData()
//                self.refreshControl.endRefreshing()
//
//            }
////            tableNode.performBatch(animated: false, updates: {
////                tableNode.deleteRows(at: indexPaths, with: .none)
////            }, completion: { complete in
////                if complete {
////                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
////                        self.refreshControl.endRefreshing()
////                    })
////                }
////            })
//
//            return
//        }
//
//        var firstTimestamp:Double?
//        if state.posts.count > 0 {
//            firstTimestamp = state.posts[0].createdAt.timeIntervalSince1970 * 1000
//        }
//
//        if type == .nearby {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25, execute: {
//                self.refreshControl.endRefreshing()
//            })
////            PostsService.getNearbyPosts(existingKeys: state.postKeys, lastTimestamp: firstTimestamp, isRefresh: true) { _posts, _ in
////                self.refreshControl.endRefreshing()
////
////                let action = Action.insertNewBatch(posts: _posts)
////                let oldState = self.state
////                self.state = PostsTableViewController.handleAction(action, fromState: oldState)
////
////                self.tableNode.performBatch(animated: false, updates: {
////                    let indexPaths = (0..<_posts.count).map { index in
////                        IndexPath(row: index, section: 0)
////                    }
////                    self.tableNode.insertRows(at: indexPaths, with: .none)
////                }, completion: { _ in
////                    if self.state.posts.count > 0 {
////                        self.tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
////                    }
////                })
////            }
//        } else {
//            PostsService.refreshNewPosts(existingKeys: state.postKeys, startAfter: firstTimestamp) { _posts in
//                self.refreshControl.endRefreshing()
//
//                let action = Action.insertNewBatch(posts: _posts)
//                let oldState = self.state
//                self.state = PostsTableViewController.handleAction(action, fromState: oldState)
//
//                self.tableNode.performBatch(animated: false, updates: {
//                    let indexPaths = (0..<_posts.count).map { index in
//                        IndexPath(row: index, section: 1)
//                    }
//                    self.tableNode.insertRows(at: indexPaths, with: .none)
//                }, completion: { _ in
//                    if self.state.posts.count > 0 {
//                        self.tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//                    }
//                })
//            }
//        }
    }
    
    
    func fetchData(state:State, completion: @escaping (_ posts:[Post], _ endReached:Bool)->()) {
        return completion([],true)
    }
    
    var context:ASBatchContext?
}

extension PostsTableViewController: ASTableDelegate, ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        /// This call will come in on a background thread. Switch to main
        /// to add our spinner, then fire off our fetch.
        guard !state.endReached else { return }
        self.context = context
        DispatchQueue.main.async {
            let oldState = self.state
            self.state = PostsTableViewController.handleAction(.beginBatchFetch, fromState: oldState)
            self.renderDiff(oldState)
        }
        
        fetchData(state: state) { posts, endReached in
            
            if endReached {
                let oldState = self.state
                self.state = PostsTableViewController.handleAction(.endReached(), fromState: oldState)
            }
            let action = Action.endBatchFetch(posts: posts)
            let oldState = self.state
            self.state = PostsTableViewController.handleAction(action, fromState: oldState)
            self.renderDiff(oldState)
            context.completeBatchFetching(true)
            if self.state.isFirstLoad {
                let oldState = self.state
                self.state = PostsTableViewController.handleAction(.firstLoadComplete(), fromState: oldState)
                self.listenForNewPosts()
            }
        }
    }
    
    fileprivate func renderDiff(_ oldState: State) {
        
        self.tableNode.performBatchUpdates({
            
            // Add or remove items
            let rowCountChange = state.posts.count - oldState.posts.count
            if rowCountChange > 0 {
                let indexPaths = (oldState.posts.count..<state.posts.count).map { index in
                    IndexPath(row: index, section: 1)
                }
                tableNode.insertRows(at: indexPaths, with: .none)
            } else if rowCountChange < 0 {
                assertionFailure("Deleting rows is not implemented. YAGNI.")
            }
            
            // Add or remove spinner.
            if state.fetchingMore != oldState.fetchingMore {
                if state.fetchingMore {
                    // Add spinner.
                    let spinnerIndexPath = IndexPath(row: state.posts.count, section: 1)
                    tableNode.insertRows(at: [ spinnerIndexPath ], with: .none)
                } else {
                    // Remove spinner.
                    let spinnerIndexPath = IndexPath(row: oldState.posts.count, section: 1)
                    tableNode.deleteRows(at: [ spinnerIndexPath ], with: .none)
                }
            }
        }, completion:nil)
    }
    
    static func handleAction(_ action: Action, fromState state: State) -> State {
        var state = state
        switch action {
        case .beginBatchFetch:
            state.fetchingMore = true
            break
        case let .endBatchFetch(posts):
            
            state.posts.append(contentsOf: posts)
            
            if state.posts.count > 0 {
                let lastPost = state.posts[state.posts.count - 1]
                state.lastPostTimestamp = lastPost.createdAt.timeIntervalSince1970 * 1000
                state.lastScore = lastPost.score
            } else {
                state.lastPostTimestamp = nil
                state.lastScore = nil
            }
            
            state.postKeys = [:]
            for post in state.posts {
                state.postKeys[post.key] = true
            }
            
            state.fetchingMore = false
            break
        case let .insertNewBatch(posts):
            state.posts.insert(contentsOf: posts, at: 0)
            state.postKeys = [:]
            for post in state.posts {
                state.postKeys[post.key] = true
            }
            break
        case let .removePost(at):
            state.posts.remove(at: at)
            if state.posts.count > 0 {
                let lastPost = state.posts[state.posts.count - 1]
                state.lastPostTimestamp = lastPost.createdAt.timeIntervalSince1970 * 1000
                state.lastScore = lastPost.score
            } else {
                state.lastPostTimestamp = nil
                state.lastScore = nil
            }
            
            break
        case .endReached:
            state.endReached = true
            break
        case .firstLoadComplete:
            state.isFirstLoad = false
            break
        }
        return state
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return headerCell != nil ? 1 : 0
        }
        var count = state.posts.count
        if state.fetchingMore {
            count += 1
        }
        return count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if indexPath.section == 0 {
            return headerCell ?? ASCellNode()
        }
        let rowCount = self.tableNode(tableNode, numberOfRowsInSection: 1)
        
        if state.fetchingMore && indexPath.row == rowCount - 1 {
            let node = LoadingCellNode()
            node.style.height = ASDimensionMake(44.0)
            return node;
        }
        
        let cell = NewPostCellNode(post: state.posts[indexPath.row])
        cell.selectionStyle = .none
        return cell
//        let cell = PostCellNode(withPost: state.posts[indexPath.row])
//        cell.selectionStyle = .none
//        cell.postCellNode.delegate = self
//        return cell
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        let node = tableNode.nodeForRow(at: indexPath) as? NewPostCellNode
        node?.setHighlighted(true)
//        let node = tableNode.nodeForRow(at: indexPath) as! PostCellNode
//        node.setSelected(true)
        
        let post = state.posts[indexPath.row]
//        if post.isOffensive {
//            let alert = UIAlertController(title: "This post may contain offensive content.", message: "Contains muted word(s): \(post.offensesStr)", preferredStyle: .actionSheet)
//
//            alert.addAction(UIAlertAction(title: "Open Anyways", style: .destructive, handler: { _ in
//                self.openSinglePost(post)
//            }))
//
//            alert.addAction(UIAlertAction(title: "Change Content Settings", style: .default, handler: { _ in
//
//                let controller = ContentSettingsViewController()
//                let nav = UINavigationController(rootViewController: controller)
//                self.present(nav, animated: true, completion: nil)
//            }))
//
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
        
        openSinglePost(post, index: indexPath.row)
    }
    
    func openSinglePost(_ post:Post, index:Int) {
        
        if let _ = post.attachments?.video {
            let controller = LightboxViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.posts = self.state.posts
            controller.initialIndex = index
            let drawerVC = CommentsViewController()
            drawerVC.post = post
            let pulleyController = PulleyViewController(contentViewController: controller, drawerViewController: drawerVC)

            pulleyController.drawerBackgroundVisualEffectView = nil
            pulleyController.backgroundDimmingOpacity = 0.35
            pulleyController.topInset = 24
            pulleyController.hidesBottomBarWhenPushed = true

            pulleyController.transitioningDelegate = transitionManager
            self.present(pulleyController, animated: true, completion: nil)
            return
        }
        
        //controller.transitioningDelegate = transitionManager
        //self.present(controller, animated: true, completion: nil)
        let controller = SinglePostViewController()
        controller.hidesBottomBarWhenPushed = true
        controller.post = post
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableNode(_ tableNode: ASTableNode, didDeselectRowAt indexPath: IndexPath) {
        let node = tableNode.nodeForRow(at: indexPath) as? NewPostCellNode
        node?.setHighlighted(false)
    }
    
    func tableNode(_ tableNode: ASTableNode, didHighlightRowAt indexPath: IndexPath) {
        let node = tableNode.nodeForRow(at: indexPath) as? NewPostCellNode
        node?.setHighlighted(true)
    }
    
    func tableNode(_ tableNode: ASTableNode, didUnhighlightRowAt indexPath: IndexPath) {
        let node = tableNode.nodeForRow(at: indexPath) as? NewPostCellNode
        node?.setHighlighted(false)
    }
    
    
}

extension PostsTableViewController: PostCellDelegate {
    func postParentVC() -> UIViewController {
        return self
    }
    
    func postOpen(tag: String) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.initialSearch = tag
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func postOptions(_ post: Post) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if post.myAnonKey == post.anon.key {
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.newPostsListener?.remove()
                UploadService.userHTTPHeaders { _ , headers in
                    if let headers = headers {
                        UploadService.deletePost(headers, post: post) { success in
                            print("Post deleted: \(success)")
                            if success {
                                for i in 0..<self.state.posts.count {
                                    let arrayPost = self.state.posts[i]
                                    if arrayPost.key == post.key {
                                        self.state = PostsTableViewController.handleAction(.removePost(at: i), fromState: self.state)
                                        
                                        
                                        if !self.state.isFirstLoad {
                                            self.listenForNewPosts()
                                        }
                                        let indexPath = IndexPath(row: i, section: 1)
                                        let cell = self.tableNode.nodeForRow(at: indexPath) as? PostCellNode
                                        //cell?.stopListeningToPost()
                                        self.tableNode.performBatchUpdates({
                                            self.tableNode.deleteRows(at: [indexPath], with: .top)
                                        }, completion: { _ in
                                        })
                                        
                                        break
                                    }
                                }
                            }
                        }
                    } else {
                        
                    }
                }
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
                print("Report!")
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
