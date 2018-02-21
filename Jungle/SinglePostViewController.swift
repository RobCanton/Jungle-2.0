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

class SinglePostViewController: UIViewController {
    
    var post:Post!
    let tableNode = ASTableNode()
    
    var replies = [Reply]()
    
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
        tableNode.reloadSections(IndexSet(integer: 0), with: .none)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//            self.tableNode.reloadSections(IndexSet(integer: 1), with: .fade)
//        })
        
        let commentBar = UINib(nibName: "CommentBar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        
        view.addSubview(commentBar)
        commentBar.backgroundColor = UIColor.white
        commentBar.translatesAutoresizingMaskIntoConstraints = false
        commentBar.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        commentBar.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        commentBar.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 0).isActive = true
        commentBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        commentBar.applyShadow(radius: 6.0, opacity: 0.05, offset: CGSize(width: 0, height: -6.0), color: UIColor.black, shouldRasterize: false)
        commentBar.clipsToBounds = false
        commentBar.layer.masksToBounds = false
        
        commentBar.isUserInteractionEnabled = true
        
        let commentTap = UITapGestureRecognizer(target: self, action: #selector(openReplyVC))
        commentBar.addGestureRecognizer(commentTap)
        
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
        //navigationController?.navigationBar.barTintColor = UIColor.blue
        
        getReplies()
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
    }
    
    var listener:ListenerRegistration?
    
    func getReplies() {
        
        let repliesRef = firestore.collection("posts").document(post.key).collection("replies").order(by: "createdAt", descending: false)
        listener = repliesRef.addSnapshotListener() { (querySnapshot, err) in
            var _replies = [Reply]()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    print("REPLY DATA: \(data)")
                    if let anon = Anon.parse(data),
                        let text = data["text"] as? String,
                        let createdAt = data["createdAt"] as? Double {
                        let reply = Reply(key: document.documentID, anon: anon, text: text, createdAt: Date(timeIntervalSince1970: createdAt / 1000))
                        _replies.append(reply)
                    }
                }
            }
            
            self.replies = _replies
            self.tableNode.performBatch(animated: false, updates: {
                self.tableNode.reloadSections(IndexSet(integer: 1), with: .none)
                self.tableNode.reloadSections(IndexSet(integer: 2), with: .none)
            }, completion: nil)
            
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
        return replies.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if indexPath.section == 0 {
            let cell = PostCellNode(withPost: post)
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 1 {
            var title:String = "No Comments"
            if replies.count == 1 {
                title = "1 Comment"
            } else if replies.count > 1 {
                title = "\(replies.count) Comments"
            }
            
            let cell = TitleCellNode(title: title)
            return cell
        }
        
        let cell = CommentCellNode(withReply: replies[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
}

class TitleCellNode: ASCellNode {
    var titleNode = ASTextNode()
    
    required init(title: String) {
        super.init()
        automaticallyManagesSubnodes = true
        titleNode.attributedText = NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(12, 44 + 12 + 16, 12, 0), child: titleNode)
    }
}

