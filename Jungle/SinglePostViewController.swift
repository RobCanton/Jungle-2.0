//
//  SinglePostViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase
import Alamofire

protocol KeyboardAccessoryProtocol {
    func keyboardWillShow(notification:Notification)
    func keyboardWillHide(notification:Notification)
}

enum SortMode {
    case top, live
}

extension SinglePostViewController: PushTransitionDestinationDelegate {
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

class SinglePostViewController: UIViewController {
    
    var post:Post!
    let tableNode = ASTableNode()
    var commentBar:JCommentBar!
    var commentBarBottomAnchor:NSLayoutConstraint?
    var commentBarHeightAnchor:NSLayoutConstraint?
    var topState = State.empty
    var liveState = State.empty
    var listener:ListenerRegistration?
    var liveListener:ListenerRegistration?
    var currentContext:ASBatchContext?
    var sortMode = SortMode.top
    var navView:JNavigationBar!
    
    var focusedReply:Post?
    
    var tableTopAnchor:NSLayoutConstraint?
    var tableBottomAnchor:NSLayoutConstraint?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = hexColor(from: "#eff0e9")
        view.addSubview(tableNode.view)
        tableNode.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutGuide:UILayoutGuide!
        

        layoutGuide = view.safeAreaLayoutGuide
        
        let tv = SinglePostNavigationBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 64.0))
        view.addSubview(tv)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tv.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        tv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tv.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        tv.setPost(post)
        tv.backButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        tv.clipsToBounds = false
        //tv.applyShadow(radius: 5.0, opacity: 0.05, offset: CGSize(width:0,height:5.0), color: UIColor.black, shouldRasterize: false)
        
        tableNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        
        
        tableTopAnchor = tableNode.view.topAnchor.constraint(equalTo: tv.bottomAnchor)
        tableTopAnchor?.isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -44.0)
        tableBottomAnchor = tableNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 0)
        tableBottomAnchor?.isActive = true
        tableNode.view.contentInsetAdjustmentBehavior = .never
        tableNode.view.separatorColor = UIColor.clear
        tableNode.view.separatorStyle = .none
        
        //tableNode.view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.batchFetchingDelegate = self
        tableNode.view.showsVerticalScrollIndicator = false
        tableNode.backgroundColor = hexColor(from: "#eff0e9")
        tableNode.view.keyboardDismissMode = .onDrag
        tableNode.reloadSections(IndexSet(integer: 0), with: .none)

        commentBar = JCommentBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        
        view.addSubview(commentBar)
        
        commentBar.translatesAutoresizingMaskIntoConstraints = false
        commentBar.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        commentBar.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        commentBarBottomAnchor  = commentBar.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 0)
        commentBarBottomAnchor?.isActive = true
        commentBar.activeColor = post.anon.color
        commentBar.delegate = self
        commentBar.prepareTextView()
        tableBottomAnchor?.constant = -commentBar.minimumHeight
        
        //commentBar.setComposeMode(false)
        self.view.layoutIfNeeded()
    }
    
    @objc func openReplyVC() {
        let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewReplyNavController") as! UINavigationController
        let controller = nav.viewControllers[0] as! NewReplyViewController
        controller.post = post
        self.present(nav, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if let user = Auth.auth().currentUser {
            if user.isAnonymous {
                //self.commentBar.textView.isUserInteractionEnabled = false
                let tap = UITapGestureRecognizer(target: self, action: #selector(showLoginView))
                self.commentBar.addGestureRecognizer(tap)
                self.commentBar.isUserInteractionEnabled = true
            } else {
                //self.commentBar.textView.isUserInteractionEnabled = true
                if let gestures = commentBar.gestureRecognizers {
                    for gesture in gestures {
                        commentBar.removeGestureRecognizer(gesture)
                    }
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    @objc func showLoginView() {
        mainProtocol.openLoginView()
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleDismiss() {
    
        self.navigationController?.popViewController(animated: true)
    }
    
    func setSort(mode:SortMode) {
        if mode == sortMode { return }
        currentContext?.cancelBatchFetching()
        currentContext = nil
        
        // Clean up table before changing sorting modes
        switch sortMode {
        case .top:
            
            let indices = IndexSet(2..<topState.replies.count+2)
            topState = .empty
            
            tableNode.deleteSections(indices, with: .none)
            break
        case .live:
            let indices = IndexSet(2..<liveState.replies.count+2)
            liveState = .empty
            tableNode.deleteSections(indices, with: .none)
            self.disableLiveComments()
            break
        }
        
        self.sortMode = mode
        if let titleNode = self.tableNode.nodeForRow(at: IndexPath(row: 0, section: 1)) as? TitleCellNode {
            titleNode.setSortTitle(self.sortMode)
        }
        
        switch sortMode {
        case .top:
            let indices = IndexSet(2..<topState.replies.count+2)
            self.tableNode.reloadSections(indices, with: .none)
            break
        case .live:
            let indices = IndexSet(2..<liveState.replies.count+2)
            self.tableNode.reloadSections(indices, with: .none)
            break
        }
    }
    
    func enableLiveComments() {
        if sortMode != .live {
            return
        }
        
        liveListener?.remove()
        let postsRef = firestore.collection("posts").document(post.key).collection("comments")
        var query:Query!
        if liveState.replies.count > 0 {
            let firstPost = liveState.replies[0].createdAt.timeIntervalSince1970 * 1000
            query = postsRef.whereField("createdAt", isGreaterThan: firstPost).order(by: "createdAt", descending: true).limit(to: 1)
        } else {
          query = postsRef.order(by: "createdAt", descending: true).limit(to: 1)
        }
        
        
//        liveListener = query.addSnapshotListener({ snapshot, error in
//            var reply:Reply?
//            if let documents = snapshot?.documents {
//
//                if documents.count > 0 {
//                    let firstDoc = documents[0]
//                    let data = firstDoc.data()
//                    if let anon = Anon.parse(data),
//                        let text = data["text"] as? String,
//                        let createdAt = data["createdAt"] as? Double {
//                        reply = Reply(key: firstDoc.documentID, anon: anon, text: text, createdAt: Date(timeIntervalSince1970: createdAt / 1000), numReplies: 4,votes:0, replies:[])
//
//                    }
//                }
//            }
//            if let reply = reply {
//                let action = Action.insert(reply: reply)
//                let oldState = self.liveState
//                self.liveState = SinglePostViewController.handleAction(action, fromState: oldState)
//                let indexPath = IndexPath(row: 0, section: 2)
//
//                self.tableNode.performBatchUpdates({
//                    self.tableNode.insertRows(at: [indexPath], with: .top)
//                }, completion: nil)
//            }
//        })
        
    }
    
    func disableLiveComments() {
        liveListener?.remove()
    }
    
    static func fetchData(state:State, post:Post, ref:Query, lastPostID: Double?, completion: @escaping (_ replies:[Post], _ endReached:Bool)->()) {
        
        PostsService.getReplies(post: post, after: lastPostID) { replies in
            print("REPLIES FETCHED: \(replies.count)")
            completion(replies, replies.count == 0)
        }
    }
    
}

extension SinglePostViewController: ASTableDelegate, ASTableDataSource, ASBatchFetchingDelegate {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        var sections = 2

        switch sortMode {
        case .top:
            sections += topState.replies.count
            if topState.fetchingMore {
                sections += 1
            }
            break
        case .live:
            sections += liveState.replies.count
//            if liveState.fetchingMore {
//                sections += 1
//            }
            break
        }
        return sections
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            let replySection = section - 2
            switch sortMode {
            case .top:
                if topState.fetchingMore, section == topState.replies.count + 2 {
                    return 1
                }
                let reply = topState.replies[replySection]
                let loadMore = reply.numReplies > reply.replies.count ? 1 : 0
                return  1 + reply.replies.count + loadMore
            case .live:
                return 1
            }
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        switch indexPath.section {
        case 0:
            let cell = PostCellNode(withPost: post, isSinglePost: true)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.white
            return cell
        case 1:
            let cell = TitleCellNode(mode: sortMode)
            cell.selectionStyle = .none
            return cell
        default:
            
            let section = indexPath.section - 2
            
            switch sortMode {
            case .top:
                let rowCount = topState.replies.count
                
                if topState.fetchingMore && section == rowCount {
                    let node = LoadingCellNode()
                    node.style.height = ASDimensionMake(44.0)
                    return node;
                }
                let reply = topState.replies[section]
                if indexPath.row == 0 {
                    let replyLine = reply.numReplies == 0 && reply.replies.count == 0
                    let cell = CommentCellNode(reply: reply, toPost: post)
                    cell.selectionStyle = .none
                    cell.delegate = self
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
                    let hideReplyLine = subReplyIndex == reply.replies.count - 1
                    let cell = CommentCellNode(reply: subReply, toPost: post, isReply: true, isLastReply: subReplyIndex == reply.replies.count - 1)
                    cell.selectionStyle = .none
                    
                    cell.delegate = self
                    return cell
                }
            case .live:
               
                //let rowCount = self.tableNode(tableNode, numberOfRowsInSection: 2)
                
//                if liveState.fetchingMore && section == rowCount - 1 {
//                    let node = LoadingCellNode()
//                    node.style.height = ASDimensionMake(44.0)
//                    return node;
//                }
                
                let cell = CommentCellNode(reply: liveState.replies[section], toPost: post)
                cell.selectionStyle = .none
                cell.delegate = self
                return cell
            }
            
        }
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Top", style: .default, handler: { _ in
                self.setSort(mode: .top)
            }))
            alert.addAction(UIAlertAction(title: "Live", style: .default, handler: { _ in
                self.setSort(mode: .live)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        default:
            let section = indexPath.section - 2
            switch sortMode {
            case .top:
                
                let reply = topState.replies[section]
                if reply.numReplies > reply.replies.count, indexPath.row == 1  {
                    
                    let cell = tableNode.nodeForRow(at: indexPath) as? ViewRepliesCellNode
                    cell?.setFetchingMode()
                    reply.fetchReplies {

                        self.tableNode.performBatch(animated: false, updates: {
                            self.tableNode.reloadSections(IndexSet([indexPath.section]), with: .none)
                        }, completion: { _ in
//                            for node in tableNode.visibleNodes {
//                                if let cell = node as? CommentCellNode {
//                                    cell.listenToReply()
//                                }
//                            }
                        })

                    }
                }
                break
            case .live:
                break
            }
        }
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return true
    }
    
    func shouldFetchBatch(withRemainingTime remainingTime: TimeInterval, hint: Bool) -> Bool {
        
        return true
    }
    
    
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        currentContext = context
        switch sortMode {
        case .top:
            print("RXC: willBeginBatchFetchWith - TOP")
            guard !topState.endReached else { return }
            DispatchQueue.main.async {
                let oldState = self.topState
                self.topState = SinglePostViewController.handleAction(.beginBatchFetch, fromState: oldState)
                self.renderDiff(oldState)
            }
            let ref = firestore.collection("posts").document(post.key).collection("comments").order(by: "createdAt", descending: false)
            
            SinglePostViewController.fetchData(state: topState, post: post, ref: ref, lastPostID: topState.lastPostTimestamp) { replies, endReached in
                
                if endReached {
                    let oldState = self.topState
                    self.topState = SinglePostViewController.handleAction(.endReached(), fromState: oldState)
                }
                
                let action = Action.endBatchFetch(replies: replies)
                let oldState = self.topState
                self.topState = SinglePostViewController.handleAction(action, fromState: oldState)
                self.renderDiff(oldState)
                context.completeBatchFetching(true)
                
                if self.topState.isFirstLoad {
                    let oldState = self.topState
                    self.topState = SinglePostViewController.handleAction(.firstLoadComplete(), fromState: oldState)
                }
            }
            break
        case .live:
            print("RXC: willBeginBatchFetchWith - LIVE")
            guard !liveState.endReached else { return }
            DispatchQueue.main.async {
                let oldState = self.liveState
                self.liveState = SinglePostViewController.handleAction(.beginBatchFetch, fromState: oldState)

                self.renderDiff(oldState)
            }
            let ref = firestore.collection("posts").document(post.key).collection("comments").order(by: "createdAt", descending: true)
            
            SinglePostViewController.fetchData(state: liveState, post: post, ref: ref, lastPostID: liveState.lastPostTimestamp) { replies, endReached in
                
                if endReached {
                    let oldState = self.liveState
                    self.liveState = SinglePostViewController.handleAction(.endReached(), fromState: oldState)
                }
                
                let action = Action.endBatchFetch(replies: replies)
                let oldState = self.liveState
                self.liveState = SinglePostViewController.handleAction(action, fromState: oldState)
                self.renderDiff(oldState)
                context.completeBatchFetching(true)
                
                if self.liveState.isFirstLoad {
                    let oldState = self.liveState
                    self.liveState = SinglePostViewController.handleAction(.firstLoadComplete(), fromState: oldState)
                    self.enableLiveComments()
                }
            }
            break
        }
    }
    
    fileprivate func renderDiff(_ oldState: State) {
        
        switch sortMode {
        case .top:
            self.tableNode.performBatch(animated: false, updates: {
                // Add or remove items
                let rowCountChange = topState.replies.count - oldState.replies.count
                if rowCountChange > 0 {
                    let indices = IndexSet(oldState.replies.count+2..<topState.replies.count+2)
                    tableNode.insertSections(indices, with: .none)
                } else if rowCountChange < 0 {
                    assertionFailure("Deleting rows is not implemented. YAGNI.")
                }
                
                // Add or remove spinner.
                if topState.fetchingMore != oldState.fetchingMore {
                    if topState.fetchingMore {
                        // Add spinner.
                        let indexSet = IndexSet([topState.replies.count+2])
                        tableNode.insertSections(indexSet, with: .none)
                    } else {
                        // Remove spinner.
                        let indexSet = IndexSet([oldState.replies.count+2])
                        tableNode.deleteSections(indexSet, with: .none)
                    }
                }
            }, completion: nil)
            
            break
        case .live:
            print("RENDERDIFF LIVE STATE")
            self.tableNode.performBatchUpdates({
                
                // Add or remove items
                let rowCountChange = liveState.replies.count - oldState.replies.count
                if rowCountChange > 0 {
                    let indexPaths = (oldState.replies.count..<liveState.replies.count).map { index in
                        IndexPath(row: index, section: 2)
                    }
                    print("INSERT LIVE ROWS: \(indexPaths)")
                    let indices = IndexSet(oldState.replies.count+2..<liveState.replies.count+2)
                    tableNode.insertSections(indices, with: .none)
                } else if rowCountChange < 0 {
                    assertionFailure("Deleting rows is not implemented. YAGNI.")
                }
                
//                // Add or remove spinner.
//                if liveState.fetchingMore != oldState.fetchingMore {
//                    if liveState.fetchingMore {
//                        // Add spinner.
//                        let indexSet = IndexSet([liveState.replies.count+2])
//                        tableNode.insertSections(indexSet, with: .none)
//                    } else {
//                        // Remove spinner.
//                        let indexSet = IndexSet([liveState.replies.count+2])
//                        tableNode.deleteSections(indexSet, with: .none)
//                    }
//                }
            }, completion:nil)
            break
        }
        
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

extension SinglePostViewController: KeyboardAccessoryProtocol {
    @objc func keyboardWillShow(notification:Notification) {

        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        //self.commentBarHeightAnchor?.constant = commentBar.textHeight + 8.0
        //self.view.layoutIfNeeded()
        var rect:CGRect?
        var offsetPoint:CGFloat?
        if let focusedReply = focusedReply {
            
            if let replyTo = focusedReply.replyTo {
                print("Reply to: \(replyTo)")
                for i in 0..<topState.replies.count {
                    let reply = topState.replies[i]
                    if replyTo == reply.key {
                        
                        for j in 0..<reply.replies.count {
                            let subReply = reply.replies[j]
                            if focusedReply.key == subReply.key {
                                rect = tableNode.rectForRow(at: IndexPath(row: 1 + j, section: i + 2))
                                break
                            }
                        }
                        break
                        //rect = tableNode.rectForRow(at: IndexPath(row: 0, section: i + 2))
                    }
                }
            } else {
                for i in 0..<topState.replies.count {
                    let reply = topState.replies[i]
                    if focusedReply.key == reply.key {
                        
                        rect = tableNode.rectForRow(at: IndexPath(row: 0, section: i + 2))
                    }
                }
            }
        }
        
        let keyboardTop = view.bounds.height - keyboardSize.height - commentBar.calculatedHeight

        if rect != nil {
            offsetPoint = rect!.origin.y  + rect!.height + 64.0 - keyboardTop
        }

        UIView.animate(withDuration: 0.15, animations: {
            if offsetPoint != nil {
                self.tableNode.contentOffset = CGPoint(x:0,y: offsetPoint!)
            }
            
            self.commentBarBottomAnchor?.constant = -keyboardSize.height
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        print("keyboardWillHide")
        focusedReply = nil

        UIView.animate(withDuration: 0.15, animations: {
            self.commentBarBottomAnchor?.constant = 0.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
}

extension SinglePostViewController: CommentBarDelegate {
    
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
                            self.tableNode.performBatch(animated: false, updates: {
                                let indexSet = IndexSet(integer: i + 2)
                                self.tableNode.reloadSections(indexSet, with: .none)
                            }, completion: nil)
                        }
                    }
                }
            } else {
                switch self.sortMode {
                case .top:
                    if self.topState.endReached {
                        let action = Action.append(reply: reply)
                        let oldState = self.topState
                        self.topState = SinglePostViewController.handleAction(action, fromState: oldState)
                        let section = 2 + self.topState.replies.count - 1
                        let indexSet = IndexSet([section])
                        
                        self.tableNode.performBatchUpdates({
                            self.tableNode.insertSections(indexSet, with: .top)
                        }, completion: { _ in
                            self.tableNode.scrollToRow(at: IndexPath(row: 0, section: section), at: .bottom, animated: true)
                        })
                    }
                    break
                case .live:
                    break
                }
            }
        }
        commentBar.textView.text = ""
        commentBar.textViewDidChange(self.commentBar.textView)
        commentBar.textView.resignFirstResponder()
        return
        
//        user.getIDToken() { token, error in
//
//            var parameters: [String: Any] = [
//                "uid" : user.uid,
//                "text" : text,
//            ]
//
//            if let focusedReply = self.focusedReply {
//                if let parentReply = focusedReply.replyTo,
//                    parentReply != self.post.key {
//                    parameters["replyTo"] = parentReply
//                } else {
//                    parameters["replyTo"] = focusedReply.key
//                }
//            }
//
//            print("SEND PARAMS: \(parameters)")
//            self.commentBar.textView.text = ""
//            self.commentBar.textViewDidChange(self.commentBar.textView)
//            self.commentBar.textView.resignFirstResponder()
//            //self.commentBar.placeHolderTextView.isHidden = false
//            let headers: HTTPHeaders = ["Authorization": "Bearer \(token!)", "Accept": "application/json", "Content-Type" :"application/json"]
//
//            Alamofire.request("\(API_ENDPOINT)/addComment/\(self.post.key)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
//                DispatchQueue.main.async {
//                    if let dict = response.result.value as? [String:Any], let success = dict["success"] as? Bool, success, let replyData = dict["comment"] as? [String:Any], let id = dict["id"] as? String {
//                        print("GOTTY: \(replyData)")
//                        if let reply = Post.parse(id: id, replyData) {
//                            reply.isYou = true
//                            if let replyTo = dict["replyTo"] as? String {
//                                reply.replyTo = replyTo
//
//                                print("Added reply to: \(replyTo)")
//                                for i in 0..<self.topState.replies.count {
//                                    let stateReply = self.topState.replies[i]
//                                    if stateReply.numReplies <= stateReply.replies.count {
//                                        if stateReply.key == replyTo {
//                                            stateReply.replies.append(reply)
//                                            self.tableNode.performBatch(animated: false, updates: {
//                                                let indexSet = IndexSet(integer: i + 2)
//                                                self.tableNode.reloadSections(indexSet, with: .none)
//                                            }, completion: nil)
//                                        }
//                                    }
//                                }
//                            } else {
//                                switch self.sortMode {
//                                case .top:
//                                    if self.topState.endReached {
//                                        let action = Action.append(reply: reply)
//                                        let oldState = self.topState
//                                        self.topState = SinglePostViewController.handleAction(action, fromState: oldState)
//                                        let section = 2 + self.topState.replies.count - 1
//                                        let indexSet = IndexSet([section])
//                                        self.tableNode.performBatchUpdates({
//                                            self.tableNode.insertSections(indexSet, with: .top)
//                                        }, completion: { _ in
//                                            self.tableNode.scrollToRow(at: IndexPath(row: 0, section: section), at: .bottom, animated: true)
//                                        })
//                                    }
//                                    break
//                                case .live:
//                                    break
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
}

extension SinglePostViewController: CommentCellDelegate {
    func handleReply(_ reply:Post) {
        self.focusedReply = reply
        self.commentBar.textView.becomeFirstResponder()
        //commentBar.setReply(reply)
        
    }
}

