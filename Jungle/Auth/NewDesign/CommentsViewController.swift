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
import Pulley

class CommentsDrawerViewController:UIViewController {
    var currentPost:Post?
    var commentsVC:CommentsViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blue.withAlphaComponent(0.25)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        pulleyViewController?.view.addGestureRecognizer(pan)
    }
    var interactor:Interactor? = nil
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        
        if let parent = self.pulleyViewController?.parent as? JViewController {
            print("OOH YEA BABY!")
        }
        
        let percentThreshold:CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        if translation.y <= 0 {
            //interactor?.hasStarted = false
            return
        }
        print("translation: \(translation.y)")
        let lightBox = self.pulleyViewController?.primaryContentViewController as! LightboxViewController
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        lightBox.setCurrentCellVolume(1 - progress)
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
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
    
    
    func setup(withPost post:Post, showKeyboard:Bool?=nil) {
        if let showKeyboard = showKeyboard, showKeyboard {
            print("SHOW DAT KEYBOARD!")
            DispatchQueue.main.async {
                self.commentsVC?.commentBar.textView.becomeFirstResponder()
            }
            //commentsVC?.commentBar.textView.becomeFirstResponder()
        }
        if let currentPost = currentPost, currentPost.key == post.key {
            return
        }
        
        commentsVC?.willMove(toParentViewController: nil)
        commentsVC?.view.removeFromSuperview()
        commentsVC?.didMove(toParentViewController: nil)
        commentsVC = nil
        
        self.currentPost = post
        commentsVC = CommentsViewController()
        commentsVC!.post = post
        commentsVC!.willMove(toParentViewController: self)
        addChildViewController(commentsVC!)
        commentsVC!.view.frame = view.bounds
        view.addSubview(commentsVC!.view)
        commentsVC!.didMove(toParentViewController: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        get { return true }
    }
    
}

extension CommentsDrawerViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 0.0
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return view.bounds.height * 3/5 + bottomSafeArea
    }
    
    
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.open, .collapsed] // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        if distance < view.bounds.height {
            commentsVC?.commentBar.textView.resignFirstResponder()
        }
        
        
    }
    
    
    
}


class CommentsViewController:UIViewController, ASTableDelegate, ASTableDataSource {
    
    var post:Post!
    
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
    
    var blurView:UIVisualEffectView!
    var animator:UIViewPropertyAnimator?
    var contentHeight:CGFloat = 0.0
    
    var closeButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = post.anon.displayName
        let text = "\(name)  \(post.textClean)"
        
        let width = UIScreen.main.bounds.width - 60.0
        let textHeight = UILabel.size(text: text, width: width, font: Fonts.regular(ofSize: 15.0)).height
        contentHeight = max(textHeight, 28) + 24.0
        
        closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named:"Remove2"), for: .normal)
        closeButton.tintColor = UIColor.gray
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor, multiplier: 1.0).isActive = true
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        let title = UILabel(frame: .zero)
        title.text = "COMMENTS"
        title.font = Fonts.semiBold(ofSize: 13.0)
        title.textColor = UIColor.gray
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        title.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        view.backgroundColor = UIColor.white
        
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        view.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        divider.topAnchor.constraint(equalTo: view.topAnchor, constant: 43.5).isActive = true
        divider.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let layoutGuide = view.safeAreaLayoutGuide
        
        let tableView = tableNode.view
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 44).isActive = true
        
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0)
        tableView.separatorColor = UIColor(white: 0.8, alpha: 1.0)
        tableNode.performBatch(animated: false, updates: {
            self.tableNode.reloadData()
        }, completion: { _ in })
        
        commentBar = GlassCommentBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        
        view.addSubview(commentBar)
        commentBar.translatesAutoresizingMaskIntoConstraints = false
        commentBar.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        commentBar.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        commentBarBottomAnchor  = commentBar.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -20)
        commentBarBottomAnchor?.isActive = true
        commentBar.prepareTextView()
        commentBar.delegate = self

        tableView.keyboardDismissMode = .onDrag
        tableView.bottomAnchor.constraint(equalTo: commentBar.topAnchor).isActive = true
        self.view.layoutIfNeeded()
        
    }
    
    @objc func handleDismiss() {
        self.pulleyViewController?.setDrawerPosition(position: .collapsed, animated: true)
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
    
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        var sections = 1
        sections += topState.replies.count
        if topState.fetchingMore {
            sections += 1
        }
        return sections
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if topState.fetchingMore, section == topState.replies.count + 1 {
            return 1
        }
        let reply = topState.replies[section - 1]
        let loadMore = reply.numReplies > reply.replies.count ? 1 : 0
        return  1 + reply.replies.count + loadMore
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if indexPath.section == 0 {
            let cell = PostCommentCellNode(post: post)
            cell.selectionStyle = .none
            cell.timeNode.isHidden = true
            return cell
        }
        let rowCount = topState.replies.count
        let section = indexPath.section - 1
        if topState.fetchingMore && section == rowCount {
            let node = LoadingCellNode()
            node.style.height = ASDimensionMake(44.0)
            return node;
        }
        
        let reply = topState.replies[section]
        if indexPath.row == 0 {
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
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            pulleyViewController?.setDrawerPosition(position: .open, animated: true)
        }
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
                let indices = IndexSet(oldState.replies.count + 1..<topState.replies.count + 1)
                tableNode.insertSections(indices, with: .fade)
            } else if rowCountChange < 0 {
                assertionFailure("Deleting rows is not implemented. YAGNI.")
            }

            // Add or remove spinner.
            if topState.fetchingMore != oldState.fetchingMore {
                if topState.fetchingMore {
                    // Add spinner.
                    let indexSet = IndexSet([topState.replies.count + 1])
                    tableNode.insertSections(indexSet, with: .fade)
                } else {
                    // Remove spinner.
                    let indexSet = IndexSet([oldState.replies.count + 1])
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
        //let t = transitioningDelegate as! DeckTransitioningDelegate
        //t.isSwipeToDismissEnabled = false
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
        
        self.commentBarBottomAnchor?.constant = -keyboardSize.height - 20.0
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        self.commentBarBottomAnchor?.constant = -20
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardDidHide(notification:Notification) {
        //let t = transitioningDelegate as! DeckTransitioningDelegate
        //t.isSwipeToDismissEnabled = true

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
            if let replyTo = _replyTo, replyTo != self.post.key {
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
                                self.tableNode.reloadSections(indexSet, with: .top)
                            }, completion: nil)
                        }
                    }
                }
            } else {
                if self.topState.endReached {
                    let action = Action.append(reply: reply)
                    let oldState = self.topState
                    self.topState = CommentsViewController.handleAction(action, fromState: oldState)
                    let section = self.topState.replies.count
                    let indexSet = IndexSet([section])
                    
                    self.tableNode.performBatchUpdates({
                        self.tableNode.insertSections(indexSet, with: .top)
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
    
    override var prefersStatusBarHidden: Bool {
        get { return true }
    }
}
