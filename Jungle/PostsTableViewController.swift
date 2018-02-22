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

enum PostsTableType {
    case newest, popular, nearby
}

class PostsTableViewController: ASViewController<ASDisplayNode>, NewPostsButtonDelegate {
    
    var posts = [Post]()
    var tableNode = ASTableNode()
    
    var type:PostsTableType!
    var refreshControl:UIRefreshControl!
    
    struct State {
        var posts: [Post]
        var postKeys:[String:Bool]
        var fetchingMore: Bool
        var lastPostTimestamp:Double?
        var endReached:Bool
        var isFirstLoad:Bool
        static let empty = State(posts: [], postKeys: [:], fetchingMore: false, lastPostTimestamp: nil, endReached: false, isFirstLoad: true)
    }
    
    var state = State.empty
    
    var newPostsListener:ListenerRegistration?
    
    enum Action {
        case beginBatchFetch
        case endBatchFetch(posts: [Post])
        case insertNewBatch(posts: [Post])
        case removePost(at:Int)
        case endReached()
        case firstLoadComplete()
    }
    
    init(type:PostsTableType) {
        super.init(node: ASDisplayNode())
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutGuide:UILayoutGuide!
        
        layoutGuide = view.safeAreaLayoutGuide
        
        tableNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        tableNode.view.contentInsetAdjustmentBehavior = .never
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.separatorStyle = .none
        //tableNode.allowsSelection = false
        tableNode.reloadData()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableNode.view.refreshControl = refreshControl
        
        let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 64.0))
        gradientView.backgroundColor = nil
        view.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        gradientView.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        gradientView.isUserInteractionEnabled = false
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [
            UIColor(white: 0.0, alpha: 0.015).cgColor,
            UIColor(white: 0.0, alpha: 0.0).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradientView.layer.insertSublayer(gradient, at: 0)
        
        let bottomGradientView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 64.0))
        bottomGradientView.backgroundColor = nil
        view.addSubview(bottomGradientView)
        bottomGradientView.translatesAutoresizingMaskIntoConstraints = false
        bottomGradientView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        bottomGradientView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        bottomGradientView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        bottomGradientView.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        
        let bottomGradient = CAGradientLayer()
        bottomGradient.frame = bottomGradientView.bounds
        bottomGradient.colors = [
            UIColor(white: 0.0, alpha: 0.0).cgColor,
            UIColor(white: 0.0, alpha: 0.015).cgColor
        ]
        bottomGradient.locations = [0.0, 1.0]
        bottomGradient.startPoint = CGPoint(x: 0, y: 0)
        bottomGradient.endPoint = CGPoint(x: 0, y: 1)
        bottomGradientView.layer.insertSublayer(bottomGradient, at: 0)
        
        let seeNewPosts = NewPostsView(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: 44.0))
        view.addSubview(seeNewPosts)
        
        seeNewPosts.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        seeNewPosts.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        seeNewPostsTopAnchor = seeNewPosts.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -44.0)
        seeNewPostsTopAnchor?.isActive = true
        seeNewPosts.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        seeNewPosts.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        newPostsListener?.remove()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !state.isFirstLoad {
            listenForNewPosts()
        }
    }
    
    var seeNewPostsTopAnchor:NSLayoutConstraint?
    
    func showSeeNewPosts(_ show:Bool) {
        
        UIView.animate(withDuration: 0.60, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.seeNewPostsTopAnchor?.constant = show ? 0.0 : -44.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    func listenForNewPosts() {
        if type == .popular {
            return
        }
        
        newPostsListener?.remove()
        let postsRef = firestore.collection("posts").whereField("status", isEqualTo: "active").order(by: "createdAt", descending: true).limit(to: 1)
        
        
        newPostsListener = postsRef.addSnapshotListener() { snapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if snapshot!.documents.count > 0 {
                    let firstDocument = snapshot!.documents[0]
                    let key = firstDocument.documentID
                    if self.state.postKeys[key] == nil {
                        if let pendingPostKey = UploadService.pendingPostKey, key == pendingPostKey {
                            UploadService.pendingPostKey = nil
                            self.handleRefresh()
                        } else {
                            self.showSeeNewPosts(true)
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func handleRefresh() {
        self.showSeeNewPosts(false)
        
        if type == .popular {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.refreshControl.endRefreshing()
            })
            return
        }
        let postsRef = firestore.collection("posts").whereField("status", isEqualTo: "active").order(by: "createdAt", descending: false)
        
        
        var queryRef:Query!
        if state.posts.count > 0 {
            let firstPost = state.posts[0]
            queryRef = postsRef.start(after: [firstPost.createdAt.timeIntervalSince1970 * 1000]).limit(to: 12)
        } else {
            queryRef = postsRef.limit(to: 12)
        }
        queryRef.getDocuments() { (querySnapshot, err) in
            var _posts = [Post]()
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let post = Post.parse(id: document.documentID, data) {
                        if self.state.postKeys[post.key] == nil {
                            _posts.insert(post, at: 0)
                        }
                    }
                }
            }
            
            self.refreshControl.endRefreshing()
            
            let action = Action.insertNewBatch(posts: _posts)
            let oldState = self.state
            self.state = PostsTableViewController.handleAction(action, fromState: oldState)
            
            self.tableNode.performBatchUpdates({
                let indexPaths = (0..<_posts.count).map { index in
                    IndexPath(row: index, section: 0)
                }
                self.tableNode.insertRows(at: indexPaths, with: .none)
            }, completion: { _ in
                if self.state.posts.count > 0 {
                    self.tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            })
            
        }
    }
    
    
    static func fetchData(state:State, type:PostsTableType, lastPostID: Double?, completion: @escaping (_ posts:[Post], _ endReached:Bool)->()) {
        
        let rootPostRef = firestore.collection("posts").whereField("status", isEqualTo: "active")
        var postsRef:Query!
        switch type {
        case .newest:
            postsRef = rootPostRef.order(by: "createdAt", descending: true)
            break
        case .popular:
            postsRef = rootPostRef.order(by: "likes", descending: true)
            break
        case .nearby:
            postsRef = rootPostRef.order(by: "createdAt", descending: true)
            break
        }
        
        var queryRef:Query!
        if let lastPostID = lastPostID {
            queryRef = postsRef.start(after: [lastPostID]).limit(to: 15)
        } else{
            queryRef = postsRef.limit(to: 15)
        }
        
        queryRef.getDocuments() { (querySnapshot, err) in
            var _posts = [Post]()
            var endReached = false
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                let documents = querySnapshot!.documents
                
                if documents.count == 0 {
                    endReached = true
                }
                
                for document in documents {
                    let data = document.data()
                    if let post = Post.parse(id: document.documentID, data) {
                        if state.postKeys[post.key] == nil {
                            _posts.append(post)
                        }
                    }
                }
            }
            
            completion(_posts, endReached)
        }
        
    }
    
}

extension PostsTableViewController: ASTableDelegate, ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        /// This call will come in on a background thread. Switch to main
        /// to add our spinner, then fire off our fetch.
        guard !state.endReached else { return }
        
        DispatchQueue.main.async {
            let oldState = self.state
            self.state = PostsTableViewController.handleAction(.beginBatchFetch, fromState: oldState)
            self.renderDiff(oldState)
        }
        
        PostsTableViewController.fetchData(state: state, type: type, lastPostID: state.lastPostTimestamp) { posts, endReached in
            
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
                    IndexPath(row: index, section: 0)
                }
                tableNode.insertRows(at: indexPaths, with: .none)
            } else if rowCountChange < 0 {
                assertionFailure("Deleting rows is not implemented. YAGNI.")
            }
            
            // Add or remove spinner.
            if state.fetchingMore != oldState.fetchingMore {
                if state.fetchingMore {
                    // Add spinner.
                    let spinnerIndexPath = IndexPath(row: state.posts.count, section: 0)
                    tableNode.insertRows(at: [ spinnerIndexPath ], with: .none)
                } else {
                    // Remove spinner.
                    let spinnerIndexPath = IndexPath(row: oldState.posts.count, section: 0)
                    tableNode.deleteRows(at: [ spinnerIndexPath ], with: .none)
                }
            }
        }, completion:nil)
    }
    
    fileprivate static func handleAction(_ action: Action, fromState state: State) -> State {
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
            } else {
                state.lastPostTimestamp = nil
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
            } else {
                state.lastPostTimestamp = nil
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
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        var count = state.posts.count
        if state.fetchingMore {
            count += 1
        }
        return count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let rowCount = self.tableNode(tableNode, numberOfRowsInSection: 0)
        
        if state.fetchingMore && indexPath.row == rowCount - 1 {
            let node = LoadingCellNode()
            node.style.height = ASDimensionMake(44.0)
            return node;
        }
        
        let cell = PostCellNode(withPost: state.posts[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let controller = SinglePostViewController()
        controller.hidesBottomBarWhenPushed = true
        controller.post = state.posts[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension PostsTableViewController: PostCellDelegate {
    func postOptions(_ post: Post) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if post.isYou {
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
                                        
                                        self.tableNode.performBatchUpdates({
                                            let indexPath = IndexPath(row: i, section: 0)
                                            self.tableNode.deleteRows(at: [indexPath], with: .automatic)
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

