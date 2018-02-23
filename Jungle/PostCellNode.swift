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
    let dislikeButton = ASButtonNode()
    let commentButton = ASButtonNode()
    let moreButtonNode = ASButtonNode()
    
    let countLabel = ASTextNode()
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
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "-", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: grayColor,
            NSAttributedStringKey.paragraphStyle: paragraph
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
        
        likeButton.setImage(UIImage(named: "upvote"), for: .normal)
        likeButton.laysOutHorizontally = true
        likeButton.contentSpacing = 6.0
        likeButton.contentHorizontalAlignment = .middle
        likeButton.contentEdgeInsets = .zero
        likeButton.tintColor = grayColor
        likeButton.tintColorDidChange()
        
        dislikeButton.setImage(UIImage(named: "downvote"), for: .normal)
        dislikeButton.laysOutHorizontally = true
        dislikeButton.contentSpacing = 6.0
        dislikeButton.contentHorizontalAlignment = .middle
        dislikeButton.contentEdgeInsets = .zero
        dislikeButton.tintColor = grayColor
        dislikeButton.tintColorDidChange()
        
        commentButton.setImage(UIImage(named: "comment2"), for: .normal)
        commentButton.laysOutHorizontally = true
        commentButton.contentSpacing = 8.0
        commentButton.contentHorizontalAlignment = .middle
        
        likeButton.addTarget(self, action: #selector(handleUpvote), forControlEvents: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(handleDownvote), forControlEvents: .touchUpInside)
        
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
        
        
        likeButton.style.height = ASDimension(unit: .points, value: 32.0)
        dislikeButton.style.height = ASDimension(unit: .points, value: 32.0)
        commentButton.style.height = ASDimension(unit: .points, value: 32.0)
        
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        
        
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
        
        
        let nameStack = ASStackLayoutSpec.horizontal()
        nameStack.children = [titleNode]
        nameStack.spacing = 4.0
        
        let subnameCenterX = ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: .minimumX, child: subnameNode)
        let imageStack = ASStackLayoutSpec.vertical()
        imageStack.children = [imageNode, subnameCenterX]
        imageStack.spacing = 6.0
        imageStack.style.layoutPosition = CGPoint(x: 0, y: 0)
        
        let titleStack = ASStackLayoutSpec.vertical()
        titleStack.children = [nameStack, subtitleNode]
        titleStack.spacing = 2.0
        
        
        
        let leftActions = ASStackLayoutSpec.horizontal()
        leftActions.children = [ likeButton, dislikeButton, commentButton]
        leftActions.spacing = 0.0
        
    
        let countCenterY = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: countLabel)
        let likeStack = ASStackLayoutSpec.horizontal()
        likeStack.children = [ likeButton, countCenterY, dislikeButton ]
        likeStack.spacing = 0.0
    
        countLabel.style.width = ASDimension(unit: .points, value: 28.0)
        countLabel.style.flexGrow = 1.0
        likeButton.style.flexShrink = 1.0
        dislikeButton.style.flexShrink = 1.0
        likeStack.style.width = ASDimension(unit: .fraction, value: 0.35)
        commentButton.style.width = ASDimension(unit: .fraction, value: 0.35)
        moreButtonNode.style.width = ASDimension(unit: .fraction, value: 0.3)
        
        let rightActions = ASStackLayoutSpec.horizontal()
        rightActions.children = [  ]
        rightActions.spacing = 8.0
        
        gapNode.style.flexGrow = 1.0
        
        let actionsRow = ASStackLayoutSpec.horizontal()

        actionsRow.children = [ likeStack, commentButton, moreButtonNode]
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
        
        mainVerticalStack.style.layoutPosition = CGPoint(x: 44 + 10.0, y: 0)
        
        let abs = ASAbsoluteLayoutSpec(children: [imageStack, mainVerticalStack])
        return ASInsetLayoutSpec(insets: PostCellNode.mainInsets, child: abs)
    }
    
    func setLikes(count:Int) {
        let str = NSAttributedString(string: "\(count)", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        
        //likeButton.setAttributedTitle(str, for: .normal)
    }
    
    func setReplies(count:Int) {
        let str = NSAttributedString(string: "\(count)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: grayColor
            ])
        
        commentButton.setAttributedTitle(str, for: .normal)
    }

    
    @objc func handleUpvote() {
        guard let post = post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if post.vote == .upvoted {
            post.vote = .notvoted
            let postRef = firestore.collection("posts").document(post.key).collection("votes").document(uid)
            postRef.delete() { error in
            }
        } else {
            post.vote = .upvoted
            let postRef = firestore.collection("posts").document(post.key).collection("votes").document(uid)
            postRef.setData(["val": true], completion: { error in
                
            })
        }
        setVote(post.vote, animated: true)
    }
    
    @objc func handleDownvote() {
        guard let post = post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if post.vote == .downvoted {
            post.vote = .notvoted
            let postRef = firestore.collection("posts").document(post.key).collection("votes").document(uid)
            postRef.delete() { error in
            }
        } else {
            post.vote = .downvoted
            let postRef = firestore.collection("posts").document(post.key).collection("votes").document(uid)
            postRef.setData(["val": false], completion: { error in
                
            })
        }
        setVote(post.vote, animated: true)
    }
    
    func setVote(_ vote:Vote, animated:Bool) {
        switch vote {
        case .upvoted:
            if animated {
                likeButton.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
                    var frame = self.likeButton.view.frame
                    frame.origin.y -= 10.0
                    self.likeButton.view.frame = frame
                }, completion: { _ in
                    UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: [.curveEaseOut], animations: {
                        var frame = self.likeButton.view.frame
                        frame.origin.y += 10.0
                        self.likeButton.view.frame = frame
                    }, completion: { _ in
                        self.likeButton.isUserInteractionEnabled = true
                    })
                })
            }
            likeButton.setImage(UIImage(named:"upvoted"), for: .normal)
            dislikeButton.setImage(UIImage(named:"downvote"), for: .normal)
            break
        case .downvoted:
            if animated {
                self.dislikeButton.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
                    var frame = self.dislikeButton.view.frame
                    frame.origin.y += 10.0
                    self.dislikeButton.view.frame = frame
                }, completion: { _ in
                    UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: [.curveEaseOut], animations: {
                        var frame = self.dislikeButton.view.frame
                        frame.origin.y -= 10.0
                        self.dislikeButton.view.frame = frame
                    }, completion: { _ in
                        self.dislikeButton.isUserInteractionEnabled = true
                    })
                })
            }
            likeButton.setImage(UIImage(named:"upvote"), for: .normal)
            dislikeButton.setImage(UIImage(named:"downvoted"), for: .normal)
            break
        case .notvoted:
            likeButton.setImage(UIImage(named:"upvote"), for: .normal)
            dislikeButton.setImage(UIImage(named:"downvote"), for: .normal)
            break
        }
    }
    
    @objc func setDisliked() {
        dislikeButton.setImage(UIImage(named:"downvoted"), for: .normal)
        
    }
    var postRefListener:ListenerRegistration?
    var likedRefListener:ListenerRegistration?
    var lexiconRefListener:ListenerRegistration?
    
    func listenToPost() {
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("listenToPost")
        let postRef = firestore.collection("posts").document(post.key)
        let voteRef = postRef.collection("votes").document(uid)
        let lexiconRef = postRef.collection("lexicon").document(uid)
        likedRefListener = voteRef.addSnapshotListener({ snapshot, error in
            if let snapshot = snapshot,
                let data = snapshot.data(),
                let val = data["val"] as? Bool {
                post.vote = val ? .upvoted : .downvoted
            } else {
                post.vote = .notvoted
            }
            self.setVote(post.vote, animated: false)
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
                    post.votes = updatedPost.votes
                    self.setNumVotes(post.votes)

                }
                //self.setLikes(count: updatedPost.likes)
                self.setReplies(count: updatedPost.replies)
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
    
    func setNumVotes(_ votes:Int) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "\(votes)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: grayColor,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
    }
    
    func assignAnonymous(_ anon:Anon?) {
        
        if let post = post,
            let anon = anon,
            anon.key == post.anon.key {
                self.post?.isYou = true
                subnameNode.attributedText = NSAttributedString(string: "YOU", attributes: [
                    NSAttributedStringKey.font: Fonts.semiBold(ofSize: 11.0),
                    NSAttributedStringKey.foregroundColor: UIColor.white
                ])
                subnameNode.isHidden = false
        } else {
            self.post?.isYou = false
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
