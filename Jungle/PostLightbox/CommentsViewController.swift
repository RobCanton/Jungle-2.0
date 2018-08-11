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
import Firebase
import Pulley

class CommentsDrawerViewController:UIViewController {
    var currentPost:Post?
    var commentsVC:CommentsViewController?
    
    var showComments = false
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        pulleyViewController?.view.addGestureRecognizer(pan)
        if showComments, let post = currentPost {
            showComments = false
            let commentsVC = pulleyViewController?.drawerContentViewController as! CommentsDrawerViewController
            commentsVC.setup(withPost: post, showKeyboard: false)
            self.pulleyViewController?.setDrawerPosition(position: .open, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    var interactor:Interactor? = nil
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        
        if let parent = self.pulleyViewController?.parent as? JViewController {
            print("OOH YEA BABY!")
        }
        
        let percentThreshold:CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        if translation.y < 0 {
            if translation.y < -5, let post = currentPost {
                let commentsVC = pulleyViewController?.drawerContentViewController as! CommentsDrawerViewController
                commentsVC.setup(withPost: post, showKeyboard: false)
                self.pulleyViewController?.setDrawerPosition(position: .open, animated: true)
            }
            interactor?.hasStarted = false
            interactor?.shouldFinish = false
            interactor?.cancel()
            return
        }
        
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
    var myProfile:Profile?
    var myAnon:Anon?
    var didRecieveLexicon = false
    
    
    var tableNode = ASTableNode()
    var topState = State.empty
    var currentContext:ASBatchContext?
    var pushTransitionManager = PushTransitionManager()
    
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
        case removeReply(at:Int, sub:Int?)
        case firstLoadComplete()
    }
    
    var commentBar:GlassCommentBar!
    var replyBar:ReplyBar!
    var replyBottomAnchor:NSLayoutConstraint!
    
    var commentBarBottomAnchor:NSLayoutConstraint?
    var commentBarHeightAnchor:NSLayoutConstraint?
    var tableBottomAnchor:NSLayoutConstraint?
    
    var focusedReply:Post?
    var keyboardHeight:CGFloat?
    
    var blurView:UIVisualEffectView!
    var animator:UIViewPropertyAnimator?
    var contentHeight:CGFloat = 0.0
    
    var closeButton:UIButton!
    var subscribeButton:UIButton!
    var isSubscribed:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = post.anon.displayName
        let text = "\(name)  \(post.text)"
        
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
        
        subscribeButton = UIButton(type: .custom)
        subscribeButton.setImage(UIImage(named:"Bell"), for: .normal)
        subscribeButton.tintColor = UIColor.gray
        view.addSubview(subscribeButton)
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        subscribeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        subscribeButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        subscribeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        subscribeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor, multiplier: 1.0).isActive = true
        subscribeButton.addTarget(self, action: #selector(toggleSubscription), for: .touchUpInside)
        
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
        //tableView.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0)
        //tableView.separatorColor = UIColor(white: 0.8, alpha: 1.0)
        tableView.separatorStyle = .none
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
        
        replyBar = ReplyBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 32.0))
        view.insertSubview(replyBar, belowSubview: commentBar)
        replyBar.translatesAutoresizingMaskIntoConstraints = false
        replyBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        replyBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        replyBottomAnchor = replyBar.bottomAnchor.constraint(equalTo: commentBar.topAnchor, constant: 32.0)
        replyBottomAnchor.isActive = true
        replyBar.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        replyBar.replyClose.addTarget(self, action: #selector(cancelReply), for: .touchUpInside)

        //tableView.keyboardDismissMode = .onDrag
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        observePostSubscription()
        observePostLexicon()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = database.child("posts/subscribers/\(post.key)/\(uid)")
        if let prevListener = subscriptionListener {
            ref.removeObserver(withHandle: prevListener)
        }
    }
    
    var lexiconListener:UInt?
    
    func observePostLexicon() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = database.child("posts/lexicon/\(post.key)/\(uid)")
        if let prevListener = lexiconListener {
            ref.removeObserver(withHandle: prevListener)
        }
        myProfile = nil
        myAnon = nil
        didRecieveLexicon = false
        updateAnonSwitch()
        
        ref.observe(.value, with: { snapshot in
            self.didRecieveLexicon = true
            if let data = snapshot.value as? [String:Any] {
                if let anon = Anon.parse(data) {
                    print("WE GOT AN ANON!")
                    self.myAnon = anon
                } else if let profile = Profile.parse(data) {
                    print("WE GOT A PROFILE!")
                    self.myProfile = profile
                }
            } else {
                print("WE GOT NO DATA!")
            }
            self.updateAnonSwitch()
        }, withCancel: { error in
            print("WE GOT AN ERROR: \(error.localizedDescription)")
        })
    }
    
    func updateAnonSwitch() {
        let anonSwitch = commentBar.anonSwitch
        if let profile = myProfile {
            anonSwitch?.display(profile: profile)
        } else if let anon = myAnon {
            anonSwitch?.display(anon: anon)
        } else {
            anonSwitch?.setAnonMode(to: UserService.anonMode)
            anonSwitch?.isUserInteractionEnabled = didRecieveLexicon
        }
    }
    
    var subscriptionListener:UInt?
    func observePostSubscription() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = database.child("posts/subscribers/\(post.key)/\(uid)")
        if let prevListener = subscriptionListener {
            ref.removeObserver(withHandle: prevListener)
        }
        
        subscribeButton.setImage(UIImage(named:"Bell"), for: .normal)
        subscribeButton.alpha = 0.5
        subscribeButton.isUserInteractionEnabled = false
        subscriptionListener = ref.observe(.value, with: { snapshot in
            var isSubscribed = false
            if let value = snapshot.value as? Bool {
                isSubscribed = value
            }
            self.setIsSubscribedToPost(isSubscribed)
        })
        
    }
    
    
    func setIsSubscribedToPost(_ isSubscribed:Bool) {
        self.isSubscribed = isSubscribed
        subscribeButton.alpha = 1.0
        subscribeButton.isUserInteractionEnabled = true
        if isSubscribed {
            subscribeButton.setImage(UIImage(named:"BellOn"), for: .normal)
        } else {
            subscribeButton.setImage(UIImage(named:"Bell"), for: .normal)
        }
    }
    
    @objc func toggleSubscription() {
        guard let isSubscribed = self.isSubscribed else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = database.child("posts/subscribers/\(post.key)/\(uid)")
        if isSubscribed {
            ref.setValue(false) { error, _ in
                if let _  = error {
                    Alerts.showFailureAlert(withMessage: "Unable to unsubscribe from post.")
                } else {
                    Alerts.showSuccessAlert(withMessage: "Unsubscribed from post.")
                }
            }
        } else {
            ref.setValue(true) { error, _ in
                if let _ = error {
                    Alerts.showFailureAlert(withMessage: "Unable to subscribe to post.")
                } else {
                    Alerts.showSuccessAlert(withMessage: "Subscribed to post!")
                }
            }
        }
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
            let cell = PostCommentCellNode(post: post, parentPost: post, isCaption: true)
            cell.selectionStyle = .none
            cell.delegate = self
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
            let cell = PostCommentCellNode(post: reply, parentPost: post)
            cell.delegate = self
            cell.selectionStyle = .none
            cell.dividerNode.isHidden = reply.numReplies > 0
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
            let cell = PostCommentCellNode(post: subReply, parentPost: post, isCaption: false, isSubReply: true)
            cell.dividerNode.isHidden = subReplyIndex < reply.replies.count - 1
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        default:
            let section = indexPath.section - 1
            let reply = topState.replies[section]
            if reply.numReplies > reply.replies.count, indexPath.row == 1  {
                
                let cell = tableNode.nodeForRow(at: indexPath) as? ViewRepliesCellNode
                cell?.setFetchingMode()
                reply.fetchReplies {
                    
                    self.tableNode.performBatch(animated: false, updates: {
                        self.tableNode.reloadSections(IndexSet([indexPath.section]), with: .none)
                    }, completion: { _ in })
                    
                }
            }
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
        case let .removeReply(replyIndex, subReplyIndex):
            if let subReplyIndex = subReplyIndex {
                state.replies[replyIndex].replies.remove(at: subReplyIndex)
            } else {
                state.replies.remove(at: replyIndex)
            }
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
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        
        if let focusedReply = focusedReply,
            let offsetPoint = getTableOffset(forReply: focusedReply, keyboardHeight: keyboardSize.height) {
            self.tableNode.setContentOffset(offsetPoint, animated: true)
        }
        
        self.commentBarBottomAnchor?.constant = -keyboardSize.height - 20.0
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardDidShow(notification:Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        keyboardHeight = keyboardSize.height
        
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        self.commentBarBottomAnchor?.constant = -20
        keyboardHeight = nil
        //self.commentBar.setReply(nil)

        self.replyBar.setReply(nil)
        self.replyBottomAnchor.constant = 32
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardDidHide(notification:Notification) {

    }
    
    func getTableOffset(forReply: Post, keyboardHeight:CGFloat) -> CGPoint? {
        var rect:CGRect?
        var offsetPoint:CGFloat?
        
        if let focusedReply = focusedReply,
            let replyTo = focusedReply.replyTo {
            if replyTo == post.key {
                
                for i in 0..<topState.replies.count {
                    let reply = topState.replies[i]
                    if focusedReply.key == reply.key {
                        rect = tableNode.rectForRow(at: IndexPath(row: 0, section: i + 1))
                        break
                    }
                }
            }
        }
        
        let keyboardTop = view.bounds.height - keyboardHeight - commentBar.calculatedHeight - 32.0
        
        if rect != nil {
            let rectBottom = rect!.origin.y  + rect!.height
            if rectBottom < keyboardTop {
                return nil
            }
            //print("RECT BOTTOM: \(rect!.origin.y + rect!.height) | Keyboard: \(keyboardTop)")
            offsetPoint = rectBottom + 64.0 - keyboardTop
            
        }
        
        return offsetPoint != nil ? CGPoint(x: 0, y: offsetPoint!) : nil
    }
}

extension CommentsViewController: CommentBarDelegate {
    
    func callFunction(text:String, completion:@escaping ((_ success:Bool, _ reply:Post?, _ replyTo:String?)->())) {
        var parameters: [String: Any] = [
            "text" : text,
            "postID": post.key,
            "isAnonymous": commentBar.anonSwitch.anonMode
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
                print("Error: \(error.localizedDescription)")
                completion(false, nil, nil)
            
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print("ERROR: \(code)-\(message)")
                    
                }
                Alerts.showFailureAlert(withMessage: "Comment failed to send.")
                return completion(false, nil, nil)
            } else if let data = result?.data as? [String: Any],
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
        commentBar.textView.text = ""
        commentBar.textViewDidChange(self.commentBar.textView)
        commentBar.textView.resignFirstResponder()
        commentBar.placeHolderLabel.isHidden = false
        commentBar.placeHolderLabel.font = Fonts.semiBold(ofSize: 15.0)
        commentBar.placeHolderLabel.text = "Sending..."
        
        let pColor = commentBar.placeHolderLabel.textColor
        commentBar.placeHolderLabel.textColor = tagColor
        callFunction(text: text) { success, _reply, _replyTo in
            self.focusedReply = nil
             self.commentBar.placeHolderLabel.font = Fonts.regular(ofSize: 15.0)
            self.commentBar.placeHolderLabel.text = "Reply..."
            self.commentBar.placeHolderLabel.textColor = pColor
            self.commentBar.isUserInteractionEnabled = true
            
            guard success, let reply = _reply else { return }
            
            reply.isYou = true
            if let replyTo = _replyTo, replyTo != self.post.key {
                reply.replyTo = replyTo
                
                print("Added reply to: \(replyTo)")
                for i in 0..<self.topState.replies.count {
                    let stateReply = self.topState.replies[i]
                        if stateReply.key == replyTo {
                            print("Found Correct reply")
                            stateReply.numReplies += 1
                            stateReply.replies.append(reply)
                            //self.tableNode.reloadData()
                            self.tableNode.performBatch(animated: false, updates: {
                                let indexSet = IndexSet(integer: i + 1)
                                print("RELOADING TABLE SECTION for: \(stateReply.text)")
                                self.tableNode.reloadSections(indexSet, with: .fade)
                            }, completion: { _ in
                                var row = stateReply.replies.count
                                if stateReply.numReplies > stateReply.replies.count {
                                    row += 1
                                }
                                self.tableNode.scrollToRow(at: IndexPath(row: row, section: i + 1), at: .bottom, animated: true)
                            })
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
            
            NotificationService.authorizationStatus { _s in
                
                switch _s {
                case .authorized:
                    print("AUTHORIZED")
                    break
                case .denied:
                    print("DENIED")
                    break
                case .notDetermined:
                    print("NOT DETERMINED MAN")
                    let message = "Would you like to be notified when users interact with your posts and comments?"
                    NotificationService.showRequestAlert(nil, message: message)
                    break
                }
            }
        }
        return
    }
    
    override var prefersStatusBarHidden: Bool {
        get { return true }
    }
}

extension CommentsViewController: CommentCellDelegate {
    func postOpen(tag: String) {
        let vc = SearchViewController()
        vc.initialSearch = tag
        
        pushTransitionManager.navBarHeight = nil
        vc.interactor = pushTransitionManager.interactor
        vc.transitioningDelegate = pushTransitionManager
        self.pulleyViewController?.present(vc, animated: true, completion: nil)
    }
    
    func handleMore(_ post: Post) {
        let alert = UIAlertController(title: post.anon.displayName, message: post.text, preferredStyle: .actionSheet)
        
        if post.isYou {
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                
                UploadService.deletePost(post) { success in
                    print("Post deleted: \(success)")
                    let state = self.topState
                    if success {
                        for i in 0..<state.replies.count {
                            let reply = state.replies[i]
                            if reply.key == post.key {
                                
                                self.topState.replies[i].deleted = true
                                break
                            } else {
                                for j in 0..<reply.replies.count {
                                    let subReply = reply.replies[j]
                                    if subReply.key == post.key {
                                        self.topState.replies[i].replies[j].deleted = true
                                        break
                                    }
                                }
                            }
                        }
                        self.tableNode.reloadData()
                    }
                    
                }
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
                let reportSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let inappropriate = UIAlertAction(title: "It's Inappropriate", style: .destructive, handler: { _ in
                    ReportService.reportPost(post, type: .inappropriate)
                })
                reportSheet.addAction(inappropriate)
                let spam = UIAlertAction(title: "It's Spam", style: .destructive, handler: { _ in
                    ReportService.reportPost(post, type: .spam)
                })
                reportSheet.addAction(spam)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
                reportSheet.addAction(cancel)
                self.present(reportSheet, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleReply(_ reply: Post) {
        guard let replyTo = reply.replyTo else { return }
        if replyTo == post.key {
            self.focusedReply = reply
            self.commentBar.setText("")
            self.replyBar.setReply(reply)
            self.replyBottomAnchor.constant = 0
            self.view.layoutIfNeeded()
            
            if let keyboardHeight = keyboardHeight {
                if let focusedReply = self.focusedReply,
                    let offsetPoint = getTableOffset(forReply: focusedReply, keyboardHeight: keyboardHeight) {
                    self.tableNode.setContentOffset(offsetPoint, animated: true)
                }
            } else {
                self.commentBar.textView.becomeFirstResponder()
            }
        } else {
            self.focusedReply = reply
            self.commentBar.setText("@\(reply.anon.displayName) ")
            
            self.replyBar.setReply(reply)
            self.replyBottomAnchor.constant = 0
            self.view.layoutIfNeeded()
            
            if let keyboardHeight = keyboardHeight {
                if let focusedReply = self.focusedReply,
                    let offsetPoint = getTableOffset(forReply: focusedReply, keyboardHeight: keyboardHeight) {
                    self.tableNode.setContentOffset(offsetPoint, animated: true)
                }
            } else {
                self.commentBar.textView.becomeFirstResponder()
            }
            
        }
    }
    
    @objc func cancelReply() {
        self.focusedReply = nil
        self.commentBar.setText("")
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
            self.replyBottomAnchor.constant = 32
            self.view.layoutIfNeeded()
        }, completion: {_ in
            self.replyBar.setReply(nil)
        })
    }
    
}
