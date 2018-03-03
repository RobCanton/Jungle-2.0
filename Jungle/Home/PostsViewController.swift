//
//  PostsViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase
import Alamofire

class SearchPostsViewController: PostsViewController {
    
    var searchText:String?
    func setSearch(text:String?) {
        context?.cancelBatchFetching()
        let indexPaths = (0..<state.posts.count).map { index in
            IndexPath(row: index, section: 0)
        }
        state = .empty
        UIView.setAnimationsEnabled(false)
        tableNode.deleteRows(at: indexPaths, with: .none)
        UIView.setAnimationsEnabled(true)
        searchText = text
        self.tableNode.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    override func fetchData(_ state: PostsViewController.State, completion: @escaping ([Post], Bool) -> ()) {
        if let searchText = searchText {
            SearchService.searchFor(text: searchText, offset: state.posts.count) { documents in
                
                var posts = [Post]()
                var endReached = false
                
                if documents.count == 0 {
                    endReached = true
                    print("SEARCH: \(searchText) | END REACHED!")
                }
                
                for document in documents {
                    if let postID = document["objectID"] as? String,
                        let post = Post.parse(id: postID, document) {
                        if state.postKeys[post.key] == nil {
                            posts.append(post)
                        }
                    }
                }
                
                completion(posts, endReached)
            }
        } else {
            super.fetchData(state, completion: completion)
        }
    }
}

class PostsViewController: ASViewController<ASDisplayNode>, NewPostsButtonDelegate {
    
    
    var posts = [Post]()
    var tableNode = ASTableNode()
    
    var refreshControl:UIRefreshControl!
    var context:ASBatchContext?
    
    var transitionManager = LightboxViewerTransitionManager()
    
    struct State {
        var posts: [Post]
        var postKeys:[String:Bool]
        var fetchingMore: Bool
        var lastPostTimestamp:Double?
        var lastRank:Int?
        var endReached:Bool
        var isFirstLoad:Bool
        static let empty = State(posts: [], postKeys: [:], fetchingMore: false, lastPostTimestamp: nil, lastRank:nil, endReached: false, isFirstLoad: true)
    }
    
    var state = State.empty
    
    
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
        bottomGradientView.isUserInteractionEnabled = false
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func handleLocationUpdate() {
        tableNode.reloadData()
    }
    
    
    @objc func handleRefresh() {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    func fetchData(_ state:State, completion: @escaping (_ posts:[Post], _ endReached:Bool)->()) {
        DispatchQueue.main.async {
            completion([], true)
        }
    }
}

extension PostsViewController: ASTableDelegate, ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        /// This call will come in on a background thread. Switch to main
        /// to add our spinner, then fire off our fetch.
        guard !state.endReached else { return }
        self.context = context
        DispatchQueue.main.async {
            let oldState = self.state
            self.state = PostsViewController.handleAction(.beginBatchFetch, fromState: oldState)
            self.renderDiff(oldState)
        }
        
        fetchData(state) { posts, endReached in
            
            if endReached {
                let oldState = self.state
                self.state = PostsViewController.handleAction(.endReached(), fromState: oldState)
            }
            let action = Action.endBatchFetch(posts: posts)
            let oldState = self.state
            self.state = PostsViewController.handleAction(action, fromState: oldState)
            self.renderDiff(oldState)
            context.completeBatchFetching(true)
            if self.state.isFirstLoad {
                let oldState = self.state
                self.state = PostsViewController.handleAction(.firstLoadComplete(), fromState: oldState)
            }
        }
    }
    
    fileprivate func renderDiff(_ oldState: State) {
        
        self.tableNode.performBatch(animated: false, updates: {
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
        }, completion: nil)
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
                state.lastRank = lastPost.rank
            } else {
                state.lastPostTimestamp = nil
                state.lastRank = nil
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
                state.lastRank = lastPost.rank
            } else {
                state.lastPostTimestamp = nil
                state.lastRank = nil
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
        
        let cell = PostCellNode(withPost: state.posts[indexPath.row], type: .newest)
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

extension PostsViewController: PostCellDelegate {
    
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
        
        if post.isYou {
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                UploadService.userHTTPHeaders { _ , headers in
                    if let headers = headers {
                        UploadService.deletePost(headers, post: post) { success in
                            print("Post deleted: \(success)")
                            if success {
                                for i in 0..<self.state.posts.count {
                                    let arrayPost = self.state.posts[i]
                                    if arrayPost.key == post.key {
                                        self.state = PostsViewController.handleAction(.removePost(at: i), fromState: self.state)
     
                                        let indexPath = IndexPath(row: i, section: 0)
                                        let cell = self.tableNode.nodeForRow(at: indexPath) as? PostCellNode
                                        cell?.stopListeningToPost()
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


