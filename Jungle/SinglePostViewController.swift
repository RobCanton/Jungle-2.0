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
class SinglePostViewController: UIViewController {
    
    var post:Post!
    let tableNode = ASTableNode()
    
    struct State {
        var replies: [Reply]
        var fetchingMore: Bool
        var lastPostTimestamp:Double?
        var endReached:Bool
        static let empty = State(replies: [], fetchingMore: false, lastPostTimestamp: nil, endReached: false)
    }
    
    var state = State.empty
    
    var newPostsListener:ListenerRegistration?
    
    enum Action {
        case beginBatchFetch
        case endBatchFetch(replies: [Reply])
        case endReached()
        case insert(reply:Reply)
    }
    
    var commentBar:CommentBar!
    var commentBarBottomAnchor:NSLayoutConstraint?
    var commentBarHeightAnchor:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutGuide:UILayoutGuide!
        
        layoutGuide = view.safeAreaLayoutGuide
        
        tableNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -44.0).isActive = true
        tableNode.view.contentInsetAdjustmentBehavior = .never
        tableNode.view.separatorStyle = .none
        
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.keyboardDismissMode = .onDrag
        tableNode.reloadSections(IndexSet(integer: 0), with: .none)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//            self.tableNode.reloadSections(IndexSet(integer: 1), with: .fade)
//        })
        
        let height = CommentBar.topHeight + CommentBar.botHeight + 50.0
        commentBar = CommentBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: height))
        
        view.addSubview(commentBar)
        commentBar.backgroundColor = UIColor.white
        commentBar.translatesAutoresizingMaskIntoConstraints = false
        commentBar.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        commentBar.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        commentBarBottomAnchor = commentBar.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 0)
        commentBarBottomAnchor?.isActive = true
        commentBarHeightAnchor = commentBar.heightAnchor.constraint(equalToConstant: height)
        commentBarHeightAnchor?.isActive = true
        commentBar.applyShadow(radius: 6.0, opacity: 0.03, offset: CGSize(width: 0, height: -6.0), color: UIColor.black, shouldRasterize: false)
        commentBar.clipsToBounds = false
        commentBar.layer.masksToBounds = false
        commentBar.delegate = self
        commentBar.prepareTextView()
        
        commentBar.setComposeMode(false)
        self.commentBarHeightAnchor?.constant = commentBar.textHeight + CommentBar.textMarginHeight + 4
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
        navigationController?.setNavigationBarHidden(false, animated: animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    var listener:ListenerRegistration?
    
    static func fetchData(state:State, post:Post, lastPostID: Double?, completion: @escaping (_ replies:[Reply], _ endReached:Bool)->()) {
        
        let repliesRef = firestore.collection("posts").document(post.key).collection("replies").order(by: "createdAt", descending: false)
        
        var queryRef:Query!
        if let lastPostID = lastPostID {
            queryRef = repliesRef.start(after: [lastPostID]).limit(to: 15)
        } else{
            queryRef = repliesRef.limit(to: 15)
        }
        
        queryRef.getDocuments() { (querySnapshot, err) in
            var _replies = [Reply]()
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
                    if let anon = Anon.parse(data),
                        let text = data["text"] as? String,
                        let createdAt = data["createdAt"] as? Double {
                        let reply = Reply(key: document.documentID, anon: anon, text: text, createdAt: Date(timeIntervalSince1970: createdAt / 1000))
                        _replies.append(reply)
                    }
                }
            }
            completion(_replies, endReached)
            
        }

    }
    
}

extension SinglePostViewController: ASTableDelegate, ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 3
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        }
        var count = state.replies.count
        if state.fetchingMore {
            count += 1
        }
        return count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if indexPath.section == 0 {
            let cell = PostCellNode(withPost: post)
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 1 {
            
            let cell = TitleCellNode(title: "Top")
            cell.selectionStyle = .none
            return cell
        }
        let rowCount = self.tableNode(tableNode, numberOfRowsInSection: 2)
        
        if state.fetchingMore && indexPath.row == rowCount - 1 {
            let node = LoadingCellNode()
            node.style.height = ASDimensionMake(44.0)
            return node;
        }
        
        let cell = CommentCellNode(withReply: state.replies[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        guard !state.endReached else { return }
        DispatchQueue.main.async {
            let oldState = self.state
            self.state = SinglePostViewController.handleAction(.beginBatchFetch, fromState: oldState)
            self.renderDiff(oldState)
        }
        
        SinglePostViewController.fetchData(state: state, post: post, lastPostID: state.lastPostTimestamp) { replies, endReached in
            
            if endReached {
                let oldState = self.state
                self.state = SinglePostViewController.handleAction(.endReached(), fromState: oldState)
            }
            
            let action = Action.endBatchFetch(replies: replies)
            let oldState = self.state
            self.state = SinglePostViewController.handleAction(action, fromState: oldState)
            self.renderDiff(oldState)
            context.completeBatchFetching(true)
        }
    }
    
    fileprivate func renderDiff(_ oldState: State) {
        
        self.tableNode.performBatchUpdates({
            
            // Add or remove items
            let rowCountChange = state.replies.count - oldState.replies.count
            if rowCountChange > 0 {
                let indexPaths = (oldState.replies.count..<state.replies.count).map { index in
                    IndexPath(row: index, section: 2)
                }
                tableNode.insertRows(at: indexPaths, with: .none)
            } else if rowCountChange < 0 {
                assertionFailure("Deleting rows is not implemented. YAGNI.")
            }
            
            // Add or remove spinner.
            if state.fetchingMore != oldState.fetchingMore {
                if state.fetchingMore {
                    // Add spinner.
                    let spinnerIndexPath = IndexPath(row: state.replies.count, section: 2)
                    tableNode.insertRows(at: [ spinnerIndexPath ], with: .none)
                } else {
                    // Remove spinner.
                    let spinnerIndexPath = IndexPath(row: oldState.replies.count, section: 2)
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
            state.replies.append(reply)
            break
        }
        return state
        
    }
    
}

extension SinglePostViewController: KeyboardAccessoryProtocol {
    @objc func keyboardWillShow(notification:Notification) {

        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        commentBar.setComposeMode(true)
        self.commentBarHeightAnchor?.constant = commentBar.textHeight + commentBar.nonTextHeight
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.15, animations: {
            self.commentBarBottomAnchor?.constant = -keyboardSize.height
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        print("keyboardWillHide")
        commentBar.setComposeMode(false)
        self.commentBarHeightAnchor?.constant = commentBar.textHeight + CommentBar.textMarginHeight + 4
        self.commentBarHeightAnchor?.isActive = true
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.15, animations: {
            self.commentBarBottomAnchor?.constant = 0.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
}

extension SinglePostViewController: CommentBarDelegate {
    func commentTextDidChange(height: CGFloat) {
        commentBarHeightAnchor?.constant = height + commentBar.nonTextHeight
        self.view.layoutIfNeeded()
    }
    
    func commentSend(text: String) {
        guard let user = Auth.auth().currentUser else { return }
        user.getIDToken() { token, error in
            let parameters: [String: Any] = [
                "uid" : user.uid,
                "text" : text
            ]
            self.commentBar.textView.text = ""
            self.commentBar.textViewDidChange(self.commentBar.textView)
            self.commentBar.textView.resignFirstResponder()
            self.commentBar.placeHolderTextView.isHidden = false
            let headers: HTTPHeaders = ["Authorization": "Bearer \(token!)", "Accept": "application/json", "Content-Type" :"application/json"]
            
            Alamofire.request("\(API_ENDPOINT)/addReply/\(self.post.key)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                DispatchQueue.main.async {
                    if let dict = response.result.value as? [String:Any], let success = dict["success"] as? Bool, success, let replyData = dict["reply"] as? [String:Any], let id = dict["id"] as? String {
                        if let reply = Reply.parse(id: id, replyData) {
                            print("Got the reply")
                            if self.state.endReached {
                                let action = Action.insert(reply: reply)
                                let oldState = self.state
                                self.state = SinglePostViewController.handleAction(action, fromState: oldState)
                                let indexPath = IndexPath(row: self.state.replies.count - 1, section: 2)
                            
                                self.tableNode.performBatchUpdates({
                                    
                                    self.tableNode.insertRows(at: [indexPath], with: .none)
                                }, completion: { _ in
                                    self.tableNode.scrollToRow(at: indexPath, at: .bottom, animated: true)
                                })
                            }
                        }
                    }
                }
            }
        }
    }
}
