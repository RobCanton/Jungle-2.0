//
//  PostCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase

protocol PostCellDelegate:class {
    func postOptions(_ post:Post)
}

class PostCellNode:ASCellNode {
    var imageNode = ASRoundShadowedImageNode(imageCornerRadius: 22.0, imageShadowRadius: 6.0)
    var titleNode = ASTextNode()
    var subnameNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var postTextNode = ASTextNode()
    var actionsNode = ASDisplayNode()
    var dividerNode = ASDisplayNode()
    
    let likeButton = ASButtonNode()
    let commentButton = ASButtonNode()
    let moreButtonNode = ASButtonNode()
    
    var postImageNode = ASRoundShadowedImageNode(imageCornerRadius: 16.0, imageShadowRadius: 8.0)
    
    weak var delegate:PostCellDelegate?
    
    let gapNode = ASDisplayNode()
    
    static let mainInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 0.0, right: 16.0)
    
    weak var post:Post?

    required init(withPost post:Post) {
        super.init()
        self.post = post
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor.white
        
        imageNode.imageNode.backgroundColor = post.anon.color
        titleNode.attributedText = NSAttributedString(string: post.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        
        subnameNode.attributedText = NSAttributedString(string: "YOU", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 11.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        subnameNode.textContainerInset = UIEdgeInsets(top: 1.0, left: 6.0, bottom: 0, right: 6.0)
        subnameNode.backgroundColor = post.anon.color
        subnameNode.isHidden = true
        
        subtitleNode.attributedText = NSAttributedString(string: "General · \(post.createdAt.timeSinceNow())", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        
        postTextNode.maximumNumberOfLines = 0
        postTextNode.truncationMode = .byWordWrapping
        postTextNode.attributedText = NSAttributedString(string: post.text, attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        
        
        if let attachments = post.attachments {
            if attachments.images.count > 0 {
                let image = attachments.images[0]
                postImageNode.imageNode.url = image.url
                postImageNode.style.height = ASDimension(unit: .points, value: 192)
                postImageNode.applyShadow(withColor: hexColor(from: image.colorHex), opacity: 0.5)
            }
        } else {
            postImageNode.style.height = ASDimension(unit: .points, value: 0.0)
        }
        
        
        dividerNode.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        
        likeButton.setImage(UIImage(named: "like"), for: .normal)
        likeButton.laysOutHorizontally = true
        likeButton.contentSpacing = 0.0
        likeButton.contentHorizontalAlignment = .left
        likeButton.contentEdgeInsets = .zero
        commentButton.setImage(UIImage(named: "comment"), for: .normal)
        commentButton.laysOutHorizontally = true
        commentButton.contentSpacing = 0.0
        commentButton.contentHorizontalAlignment = .left
        setLikes(count: post.likes)
        setReplies(count: post.replies)
        
        likeButton.addTarget(self, action: #selector(handleLike), forControlEvents: .touchUpInside)
        
        moreButtonNode.setImage(UIImage(named:"more"), for: .normal)
        moreButtonNode.addTarget(self, action: #selector(handleMoreButton), forControlEvents: .touchUpInside)
        
    }
    
    override func didLoad() {
        super.didLoad()
        subnameNode.layer.cornerRadius = 8
        subnameNode.clipsToBounds = true
        selectionStyle = .none
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        imageNode.style.width = ASDimension(unit: .points, value: 44.0)
        imageNode.style.height = ASDimension(unit: .points, value: 44.0)
        imageNode.style.layoutPosition = CGPoint(x: 0, y: 0)
        
        likeButton.style.height = ASDimension(unit: .points, value: 32.0)
        commentButton.style.height = ASDimension(unit: .points, value: 32.0)
        
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        
        
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
        
        let subnameCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subnameNode)
        let nameStack = ASStackLayoutSpec.horizontal()
        nameStack.children = [titleNode,subnameCenterY]
        nameStack.spacing = 4.0
        
        let titleStack = ASStackLayoutSpec.vertical()
        titleStack.children = [nameStack, subtitleNode]
        titleStack.spacing = 2.0
        
        
        let leftActions = ASStackLayoutSpec.horizontal()
        leftActions.children = [ likeButton, commentButton]
        leftActions.spacing = 0.0
        
    
        likeButton.style.width = ASDimension(unit: .points, value: 72)
        commentButton.style.width = ASDimension(unit: .points, value: 72)
        
        let rightActions = ASStackLayoutSpec.horizontal()
        rightActions.children = [ moreButtonNode ]
        rightActions.spacing = 8.0
        
        gapNode.style.flexGrow = 1.0
        
        let actionsRow = ASStackLayoutSpec.horizontal()
        actionsRow.children = [ leftActions,gapNode, rightActions]
        actionsRow.spacing = 8.0
        
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [titleStack]
        contentStack.spacing = 10.0
        
        if let text = post?.text, !text.isEmpty {
            contentStack.children?.append(postTextNode)
        }
        
        if let attachments = post? .attachments {
            if attachments.images.count > 0 {
                contentStack.children?.append(postImageNode)
            }
        }
        
        contentStack.children?.append(actionsRow)
        
        let mainVerticalStack = ASStackLayoutSpec.vertical()
        mainVerticalStack.children = [contentStack, dividerNode]
        mainVerticalStack.spacing = 4.0
        
        mainVerticalStack.style.layoutPosition = CGPoint(x: 44 + 12.0, y: 0)
        
        let abs = ASAbsoluteLayoutSpec(children: [imageNode, mainVerticalStack])
        return ASInsetLayoutSpec(insets: PostCellNode.mainInsets, child: abs)
    }
    
    func setLikes(count:Int) {
        let str = NSAttributedString(string: "\(count)", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        
        likeButton.setAttributedTitle(str, for: .normal)
    }
    
    func setReplies(count:Int) {
        let str = NSAttributedString(string: "\(count)", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        
        commentButton.setAttributedTitle(str, for: .normal)
    }

    
    @objc func handleLike() {
        guard let post = post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if post.liked {
            post.likes -= 1
            setLiked(false, post)
            let postRef = firestore.collection("posts").document(post.key).collection("likes").document(uid)
            postRef.delete() { error in
            }
        } else {
            post.likes += 1
            setLiked(true, post)
            let postRef = firestore.collection("posts").document(post.key).collection("likes").document(uid)
            postRef.setData(["timestamp":Date().timeIntervalSince1970 * 1000], completion: { error in
                
            })
        }
    }
    
    func setLiked(_ liked:Bool, _ post:Post) {
        post.liked = liked
        if liked {
            likeButton.setImage(UIImage(named:"liked"), for: .normal)
        } else{
            likeButton.setImage(UIImage(named:"like"), for: .normal)
        }
    }
    var postRefListener:ListenerRegistration?
    var likedRefListener:ListenerRegistration?
    var lexiconRefListener:ListenerRegistration?
    
    func listenToPost() {
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("listenToPost")
        let postRef = firestore.collection("posts").document(post.key)
        let likedRef = postRef.collection("likes").document(uid)
        let lexiconRef = postRef.collection("lexicon").document(uid)
        likedRefListener = likedRef.addSnapshotListener({ snapshot, error in
            self.setLiked(snapshot?.exists ?? false, post)
        })
        
        postRefListener = postRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            let id = document.documentID
            if let data = document.data(),
                let updatedPost = Post.parse(id: id, data) {
                if let post = self.post, post.key == updatedPost.key {
                    post.likes = updatedPost.likes
                    self.setLikes(count: post.likes)
                }
                self.setLikes(count: updatedPost.likes)
               // setReplies(count: updatedPost.replies)
                //self.updatePost(updatedPost)
            }
        }
        
        lexiconRefListener = lexiconRef.addSnapshotListener { lexiconSnapshot, error in
            guard let document = lexiconSnapshot else { return }
            
            if let data = document.data(),
                let anon = Anon.parse(data) {
                self.assignAnonymous(anon)
            } else {
                self.assignAnonymous(nil)
            }
        }
    }
    
    
    func assignAnonymous(_ anon:Anon?) {
        
        if let post = post,
            let anon = anon,
            anon.key == post.anon.key {
                subnameNode.attributedText = NSAttributedString(string: "YOU", attributes: [
                    NSAttributedStringKey.font: Fonts.semiBold(ofSize: 11.0),
                    NSAttributedStringKey.foregroundColor: UIColor.white
                ])
                subnameNode.isHidden = false
        } else {
            subnameNode.isHidden = true
        }
    }
    
    func stopListeningToPost() {
        print("stopListeningToPost")
        likedRefListener?.remove()
        postRefListener?.remove()
        lexiconRefListener?.remove()
    }
    
    func updatePost(_ post:Post) {
        guard let currentPost = self.post else { return }
        guard post.key == currentPost.key else { return }
        
        self.post = post
        setLikes(count: post.likes)
        setReplies(count: post.replies)
    }
    
    @objc func handleMoreButton() {
        guard let post = post else { return }
        
        delegate?.postOptions(post)
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        listenToPost()
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        stopListeningToPost()
    }
    
}
