//
//  CommentsViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-04.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import DeckTransition
import Firebase

class CommentsViewController:UIViewController, ASTableDelegate, ASTableDataSource {
    
    var post:Post!
    var closeButton:UIButton!
    var titleNode:UIButton!
    var dividerNode:UIView!
    
    var tableNode = ASTableNode()
    var topState = State.empty
    var currentContext:ASBatchContext?
    struct State {
        var replies: [Post]
        var fetchingMore: Bool
        var lastPostTimestamp:Double?
        var endReached:Bool
        var isFirstLoad:Bool
        static let empty = State(replies: [], fetchingMore: false, lastPostTimestamp: nil, endReached: false, isFirstLoad:true)
    }
    
    enum Action {
        case beginBatchFetch
        case endBatchFetch(replies: [Post])
        case endReached()
        case insert(reply:Post)
        case append(reply:Post)
        case firstLoadComplete()
    }
    
    var commentBar:GlassCommentBar!
    
    var commentBarBottomAnchor:NSLayoutConstraint?
    var commentBarHeightAnchor:NSLayoutConstraint?
    var tableBottomAnchor:NSLayoutConstraint?
    
    var focusedReply:Post?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let t = transitioningDelegate as! DeckTransitioningDelegate
        view.backgroundColor = UIColor.clear
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        v.frame = view.bounds
        view.addSubview(v)
        
        let layoutGuide = view.safeAreaLayoutGuide
        
        closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64.0, height: 64.0))
        closeButton.setImage(UIImage(named:"close"), for: .normal)
        closeButton.tintColor = UIColor.white
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        closeButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 64.0).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        titleNode = UIButton(type: .custom)
        titleNode.setTitle("Comments", for: .normal)
        titleNode.titleLabel?.font = Fonts.semiBold(ofSize: 15.0)
        titleNode.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(titleNode)
        titleNode.translatesAutoresizingMaskIntoConstraints = false
        titleNode.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleNode.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        titleNode.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        dividerNode = UIView()
        dividerNode.backgroundColor = UIColor.white
        view.addSubview(dividerNode)
        dividerNode.translatesAutoresizingMaskIntoConstraints = false
        dividerNode.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        dividerNode.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        dividerNode.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0).isActive = true
        dividerNode.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.0).isActive = true
        
        let tableView = tableNode.view
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: dividerNode.bottomAnchor).isActive = true
        
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.clear
        ///tableView.separatorStyle = .none
        tableNode.performBatch(animated: false, updates: {
            self.tableNode.reloadData()
        }, completion: { _ in })
        
        commentBar = GlassCommentBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        
        view.addSubview(commentBar)
        commentBar.translatesAutoresizingMaskIntoConstraints = false
        commentBar.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        commentBar.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        commentBarBottomAnchor  = commentBar.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 0)
        commentBarBottomAnchor?.isActive = true
        //commentBar.activeColor = //post.anon.color
        //commentBar.delegate = self
        commentBar.prepareTextView()
        commentBar.delegate = self
        //tableBottomAnchor?.constant = -commentBar.minimumHeight
        
        //commentBar.setComposeMode(false)
        tableView.keyboardDismissMode = .onDrag
        tableView.bottomAnchor.constraint(equalTo: commentBar.topAnchor).isActive = true
        self.view.layoutIfNeeded()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        var sections = 0
        sections += topState.replies.count
        if topState.fetchingMore {
            sections += 1
        }
        return sections
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if topState.fetchingMore, section == topState.replies.count {
            return 1
        }
        let reply = topState.replies[section]
        let loadMore = reply.numReplies > reply.replies.count ? 1 : 0
        return  1 + reply.replies.count + loadMore
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        
        let rowCount = topState.replies.count
        let section = indexPath.section
        if topState.fetchingMore && section == rowCount {
            let node = LoadingCellNode()
            node.style.height = ASDimensionMake(44.0)
            return node;
        }
        
        
        let reply = topState.replies[section]
        if indexPath.row == 0 {
            let replyLine = reply.numReplies == 0 && reply.replies.count == 0
            let cell = PostCommentCellNode(post: reply)
            cell.selectionStyle = .none
            return cell
        } else {
            var subReplyIndex = indexPath.row - 1
            if reply.numReplies > reply.replies.count {
                subReplyIndex -= 1
            }
            if reply.numReplies > reply.replies.count, indexPath.row == 1 {
                let cell = ViewRepliesCellNode(numReplies: reply.numReplies - reply.replies.count)
                cell.selectionStyle = .none
                return cell
            }
            let subReply = reply.replies[subReplyIndex]
            let cell = PostCommentCellNode(post: subReply)
            cell.selectionStyle = .none
            
            return cell
        }
        return ASCellNode()
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return true
    }
    
    static func fetchData(state:State, post:Post, lastPostID: Double?, completion: @escaping (_ replies:[Post], _ endReached:Bool)->()) {
        
        PostsService.getReplies(post: post, after: lastPostID) { replies in
            print("REPLIES FETCHED: \(replies.count)")
            completion(replies, replies.count == 0)
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        //currentContext = context

        print("RXC: willBeginBatchFetchWith - TOP")
        guard !topState.endReached else { return }
        DispatchQueue.main.async {
            let oldState = self.topState
            self.topState = CommentsViewController.handleAction(.beginBatchFetch, fromState: oldState)
            self.renderDiff(oldState)
        }
        let ref = firestore.collection("posts").document(post.key).collection("comments").order(by: "createdAt", descending: false)
        
        CommentsViewController.fetchData(state: topState, post: post, lastPostID: topState.lastPostTimestamp) { replies, endReached in
            
            if endReached {
                let oldState = self.topState
                self.topState = CommentsViewController.handleAction(.endReached(), fromState: oldState)
            }
            
            let action = Action.endBatchFetch(replies: replies)
            let oldState = self.topState
            self.topState = CommentsViewController.handleAction(action, fromState: oldState)
            self.renderDiff(oldState)
            context.completeBatchFetching(true)
            
            if self.topState.isFirstLoad {
                let oldState = self.topState
                self.topState = CommentsViewController.handleAction(.firstLoadComplete(), fromState: oldState)
            }
        }

    }
    
    fileprivate func renderDiff(_ oldState: State) {
        
        self.tableNode.performBatch(animated: true, updates: {
            // Add or remove items
            let rowCountChange = topState.replies.count - oldState.replies.count
            if rowCountChange > 0 {
                let indices = IndexSet(oldState.replies.count..<topState.replies.count)
                tableNode.insertSections(indices, with: .fade)
            } else if rowCountChange < 0 {
                assertionFailure("Deleting rows is not implemented. YAGNI.")
            }

            // Add or remove spinner.
            if topState.fetchingMore != oldState.fetchingMore {
                if topState.fetchingMore {
                    // Add spinner.
                    let indexSet = IndexSet([topState.replies.count])
                    tableNode.insertSections(indexSet, with: .fade)
                } else {
                    // Remove spinner.
                    let indexSet = IndexSet([oldState.replies.count])
                    tableNode.deleteSections(indexSet, with: .fade)
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
        case let .endBatchFetch(replies):
            
            state.replies.append(contentsOf: replies)
            
            if state.replies.count > 0 {
                let lastPost = state.replies[state.replies.count - 1]
                state.lastPostTimestamp = lastPost.createdAt.timeIntervalSince1970 * 1000
            } else {
                state.lastPostTimestamp = nil
            }
            
            state.fetchingMore = false
            break
        case .endReached:
            state.endReached = true
            break
        case let .insert(reply):
            state.replies.insert(reply, at: 0)
            break
        case let .append(reply):
            state.replies.append(reply)
            break
        case .firstLoadComplete:
            state.isFirstLoad = false
            break
        }
        return state
        
    }

}

extension CommentsViewController: KeyboardAccessoryProtocol {
    @objc func keyboardWillShow(notification:Notification) {
        let t = transitioningDelegate as! DeckTransitioningDelegate
        t.isSwipeToDismissEnabled = false
        //transitioningDelegate?.isSwipeToDismissEnabled = false
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        //self.commentBarHeightAnchor?.constant = commentBar.textHeight + 8.0
        //self.view.layoutIfNeeded()
        var rect:CGRect?
        var offsetPoint:CGFloat?
//        if let focusedReply = focusedReply {
//            
//            if let replyTo = focusedReply.replyTo {
//                print("Reply to: \(replyTo)")
//                for i in 0..<topState.replies.count {
//                    let reply = topState.replies[i]
//                    if replyTo == reply.key {
//                        
//                        for j in 0..<reply.replies.count {
//                            let subReply = reply.replies[j]
//                            if focusedReply.key == subReply.key {
//                                rect = tableNode.rectForRow(at: IndexPath(row: 1 + j, section: i + 2))
//                                break
//                            }
//                        }
//                        break
//                        //rect = tableNode.rectForRow(at: IndexPath(row: 0, section: i + 2))
//                    }
//                }
//            } else {
//                for i in 0..<topState.replies.count {
//                    let reply = topState.replies[i]
//                    if focusedReply.key == reply.key {
//                        
//                        rect = tableNode.rectForRow(at: IndexPath(row: 0, section: i + 2))
//                    }
//                }
//            }
//        }
        
        let keyboardTop = view.bounds.height - keyboardSize.height - commentBar.calculatedHeight
        
        if rect != nil {
            offsetPoint = rect!.origin.y  + rect!.height + 64.0 - keyboardTop
        }
        
        if offsetPoint != nil {
            self.tableNode.contentOffset = CGPoint(x:0,y: offsetPoint!)
        }
        
        self.commentBarBottomAnchor?.constant = -keyboardSize.height
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        self.commentBarBottomAnchor?.constant = 0.0
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardDidHide(notification:Notification) {
        let t = transitioningDelegate as! DeckTransitioningDelegate
        t.isSwipeToDismissEnabled = true

    }
}

extension CommentsViewController: CommentBarDelegate {
    
    func callFunction(text:String, completion:@escaping ((_ success:Bool, _ reply:Post?, _ replyTo:String?)->())) {
        var parameters: [String: Any] = [
            "text" : text,
            "postID": post.key
        ]
        
        if let focusedReply = self.focusedReply {
            if let parentReply = focusedReply.replyTo,
                parentReply != self.post.key {
                parameters["replyTo"] = parentReply
            } else {
                parameters["replyTo"] = focusedReply.key
            }
        }
        
        functions.httpsCallable("addComment").call(parameters) { result, error in
            if let error = error as NSError? {
                print("FUNCTION ERROR")
                completion(false, nil, nil)
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            if let data = result?.data as? [String: Any],
                let success = data["success"] as? Bool,
                let replyData = data["comment"] as? [String:Any],
                let id = data["id"] as? String,
                let reply = Post.parse(id: id, replyData) {
                
                let replyTo = data["replyTo"] as? String
                completion(success, reply, replyTo)
            } else {
                completion(false, nil, nil)
            }
        }
    }
    
    func commentSend(text: String) {
        commentBar.isUserInteractionEnabled = false
        callFunction(text: text) { success, _reply, _replyTo in
            print("SUCCESS: \(success)")
            guard success, let reply = _reply else { return }
            self.commentBar.isUserInteractionEnabled = true
            reply.isYou = true
            if let replyTo = _replyTo {
                reply.replyTo = replyTo
                
                print("Added reply to: \(replyTo)")
                for i in 0..<self.topState.replies.count {
                    let stateReply = self.topState.replies[i]
                    if stateReply.numReplies <= stateReply.replies.count {
                        if stateReply.key == replyTo {
                            stateReply.replies.append(reply)
                            self.tableNode.reloadData()
                            self.tableNode.performBatch(animated: false, updates: {
                                let indexSet = IndexSet(integer: i)
                                self.tableNode.reloadSections(indexSet, with: .fade)
                            }, completion: nil)
                        }
                    }
                }
            } else {
                if self.topState.endReached {
                    let action = Action.append(reply: reply)
                    let oldState = self.topState
                    self.topState = CommentsViewController.handleAction(action, fromState: oldState)
                    let section = self.topState.replies.count - 1
                    let indexSet = IndexSet([section])
                    
                    self.tableNode.performBatchUpdates({
                        self.tableNode.insertSections(indexSet, with: .fade)
                    }, completion: { _ in
                        self.tableNode.scrollToRow(at: IndexPath(row: 0, section: section), at: .bottom, animated: true)
                    })
                }
            }
        }
        commentBar.textView.text = ""
        commentBar.textViewDidChange(self.commentBar.textView)
        commentBar.textView.resignFirstResponder()
        return

    }
}
