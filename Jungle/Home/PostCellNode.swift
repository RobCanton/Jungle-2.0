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
    func postParentVC() -> UIViewController
    func postOpen(tag:String)
}

class PostCellNode:ASCellNode {
    
    let gradientColorTop = accentColor
    let gradientColorBot = hexColor(from: "#22D29F")
    
    var imageNode = ASRoundShadowedImageNode(imageCornerRadius: 20.0, imageShadowRadius: 0.0)
    var titleNode = ASTextNode()
    var subnameNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var postTextNode = ActiveTextNode()
    var actionsNode = ASDisplayNode()
    var dividerNode = ASDisplayNode()
    var rankButton = ASButtonNode()
    
    let likeButton = ASButtonNode()
    let dislikeButton = ASButtonNode()
    let commentButton = ASButtonNode()
    let moreButtonNode = ASButtonNode()
    
    let groupNode = ASButtonNode()
    
    let countLabel = ASTextNode()
    var postImageNode = ASRoundShadowedImageNode(imageCornerRadius: 16.0, imageShadowRadius: 8.0)
    
    var transitionManager = LightboxViewerTransitionManager()
    weak var delegate:PostCellDelegate?
    
    let gapNode = ASDisplayNode()
    
    static let mainInsets = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 0.0, right: 16.0)
    
    weak var post:Post?
    
    var isSinglePost = false

    private(set) var bgColor = UIColor.white
    private(set) var textColor = hexColor(from: "708078")
    private(set) var buttonColor = hexColor(from: "708078")
    private(set) var upvoteImage:UIImage!
    private(set) var upvotedImage:UIImage!
    private(set) var downvoteImage:UIImage!
    private(set) var downvotedImage:UIImage!
    private(set) var commentImage:UIImage!
    private(set) var moreImage:UIImage!
    
    var isKing = false
    
    required init(withPost post:Post, type: PostsTableType, isSinglePost:Bool?=nil) {
        super.init()
        self.post = post
        if isSinglePost != nil {
            self.isSinglePost = isSinglePost!
        }
        automaticallyManagesSubnodes = true
        
        upvoteImage = UIImage(named:"upvote")
        upvotedImage = UIImage(named:"upvoted")
        downvoteImage = UIImage(named:"downvote")
        downvotedImage = UIImage(named:"downvoted")
        commentImage = UIImage(named:"comment2")
        moreImage = UIImage(named:"more")
        
        // isKing = type == .popular && post.rank != nil && post.rank == 1
        
//        if isKing {
//            textColor = UIColor.white
//            buttonColor = UIColor.white
//            upvoteImage = UIImage(named:"upvote_white")
//            upvotedImage = UIImage(named:"upvoted_white")
//            downvoteImage = UIImage(named:"downvote_white")
//            downvotedImage = UIImage(named:"downvoted_white")
//            commentImage = UIImage(named:"comment_white")
//            moreImage = UIImage(named:"more_white")
//        }
        
        backgroundColor = bgColor
        
        imageNode.mainImageNode.backgroundColor = post.anon.color
        
        postImageNode.addTarget(self, action: #selector(handleImageTap), forControlEvents: .touchUpInside)
        postImageNode.isUserInteractionEnabled = true
        
        titleNode.attributedText = NSAttributedString(string: post.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: post.anon.color
            ])
        
        var subnameStr = ""
        if post.myAnonKey == post.anon.key {
            subnameStr = "YOU"
            subnameNode.isHidden = false
        }else {
            subnameNode.isHidden = true
        }
        
        subnameNode.attributedText = NSAttributedString(string: subnameStr, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 9.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        subnameNode.textContainerInset = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 0, right: 4.0)
        subnameNode.backgroundColor = post.anon.color
        
        var locationStr = ""
        if let location = post.location {
            locationStr = " · \(location.locationStr)"
        }
        
        let subtitleStr = "\(post.createdAt.timeSinceNow())\(locationStr)"
        
        subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: textColor
            ])
        
        postTextNode.maximumNumberOfLines = 0
        postTextNode.truncationMode = .byWordWrapping
        
        let postFont = self.isSinglePost ? Fonts.regular(ofSize: 18.0) : Fonts.regular(ofSize: 16.0)
        
        postTextNode.setText(text: post.text, withFont: postFont, normalColor: UIColor.black, activeColor: accentColor)
        postTextNode.tapHandler = { type, textValue in
            switch type {
            case .hashtag:
                self.delegate?.postOpen(tag: textValue)
                break
            case .mention:
                break
            case .link:
                break
            }
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "-", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: buttonColor,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
        
        
        if let attachments = post.attachments {
            if attachments.images.count > 0 {
                let image = attachments.images[0]
                let color =  hexColor(from: image.colorHex)
                postImageNode.mainImageNode.backgroundColor = color
                postImageNode.mainImageNode.url = image.url
                postImageNode.style.height = ASDimension(unit: .points, value: 192)
                postImageNode.applyShadow(withColor: color, opacity: 0.5)
            }
        } else {
            postImageNode.style.height = ASDimension(unit: .points, value: 0.0)
        }

        
        dividerNode.backgroundColor = textColor.withAlphaComponent(0.25)
        
        likeButton.setImage(upvoteImage, for: .normal)
        likeButton.laysOutHorizontally = true
        likeButton.contentSpacing = 6.0
        likeButton.contentHorizontalAlignment = .middle
        likeButton.contentEdgeInsets = .zero
        likeButton.tintColor = buttonColor
        likeButton.tintColorDidChange()
        
        dislikeButton.setImage(downvoteImage, for: .normal)
        dislikeButton.laysOutHorizontally = true
        dislikeButton.contentSpacing = 6.0
        dislikeButton.contentHorizontalAlignment = .middle
        dislikeButton.contentEdgeInsets = .zero
        dislikeButton.tintColor = buttonColor
        dislikeButton.tintColorDidChange()
        
        
        //commentButton.setImage(commentImage, for: .normal)
        commentButton.laysOutHorizontally = true
        commentButton.contentSpacing = 2.0
        commentButton.contentHorizontalAlignment = .middle

        likeButton.addTarget(self, action: #selector(handleUpvote), forControlEvents: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(handleDownvote), forControlEvents: .touchUpInside)
        
        moreButtonNode.setImage(moreImage, for: .normal)
        moreButtonNode.addTarget(self, action: #selector(handleMoreButton), forControlEvents: .touchUpInside)
        moreButtonNode.contentHorizontalAlignment = .right
        
        if isKing {
            rankButton.setImage(UIImage(named:"crown_king"), for: .normal)
            rankButton.setAttributedTitle(nil, for: .normal)
            rankButton.isHidden = false
            backgroundColor = hexColor(from: "#FFFAE6")
            rankButton.backgroundColor = nil
            rankButton.clipsToBounds = false
        } else {
            backgroundColor = UIColor.white
            let rankText = NSAttributedString(string: "\(post.rank ?? 999)", attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.paragraphStyle: paragraph
                ])
            rankButton.setAttributedTitle(rankText, for: .normal)
            rankButton.isHidden = true//type != .popular
            rankButton.backgroundColor = post.anon.color
            rankButton.layer.cornerRadius = 13.0
            rankButton.clipsToBounds = true
        }
        let groupText = NSAttributedString(string: "Marvel Movies", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: post.anon.color
            ])
        groupNode.setAttributedTitle(groupText, for: .normal)
        groupNode.contentEdgeInsets = UIEdgeInsetsMake(0, 8.0, 0.0, 8.0)
        groupNode.contentHorizontalAlignment = .left
        groupNode.layer.cornerRadius = 12.0
        groupNode.clipsToBounds = true
        
        groupNode.layer.borderColor = post.anon.color.cgColor
        groupNode.layer.borderWidth = 1.5
        
    }
    
    override func didLoad() {
        super.didLoad()
        subnameNode.layer.cornerRadius = 4
        subnameNode.clipsToBounds = true
        selectionStyle = .none
        
        imageNode.addTarget(self, action: #selector(handleImageTap), forControlEvents: .touchUpInside)
        imageNode.isUserInteractionEnabled = true
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        imageNode.style.width = ASDimension(unit: .points, value: 40.0)
        imageNode.style.height = ASDimension(unit: .points, value: 40.0)
        
        
        likeButton.style.height = ASDimension(unit: .points, value: 32.0)
        dislikeButton.style.height = ASDimension(unit: .points, value: 32.0)
        commentButton.style.height = ASDimension(unit: .points, value: 32.0)
        
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        
        
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
        
        let subnameCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subnameNode)
        
        let hTitleStack = ASStackLayoutSpec.horizontal()
        hTitleStack.children = [titleNode]
        hTitleStack.spacing = 4.0
        
        if !subnameNode.isHidden {
            hTitleStack.children?.append(subnameCenterY)
        }
        
        if isSinglePost {
            subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
            
            
            let nameStack = ASStackLayoutSpec.vertical()
            nameStack.spacing = 2.0
            nameStack.children = [hTitleStack, subtitleNode]
            
            let imageStack = ASStackLayoutSpec.horizontal()
            imageStack.children = [imageNode, nameStack]
            imageStack.spacing = 8.0
            
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
            
            let actionsRow = ASStackLayoutSpec.horizontal()
            actionsRow.style.flexGrow = 1.0
            actionsRow.children = [ likeStack, commentButton]
            actionsRow.spacing = 8.0
            
            
            let contentStack = ASStackLayoutSpec.vertical()
            contentStack.children = [imageStack]
            contentStack.spacing = 10.0
            
            let textInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0.0), child: postTextNode)
            
            if let text = post?.text, !text.isEmpty {
                contentStack.children?.append(textInset)
            }
            
            if let attachments = post? .attachments {
                if attachments.images.count > 0 {
                    contentStack.children?.append(postImageNode)
                }
            }
            
            let actionsInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 16.0), child: actionsRow)
            contentStack.children?.append(actionsInset)
            
            let mainInset = ASInsetLayoutSpec(insets: PostCellNode.mainInsets, child: contentStack)
            let mainVerticalStack = ASStackLayoutSpec.vertical()
            mainVerticalStack.children = [mainInset, dividerNode]
            mainVerticalStack.spacing = 4.0
            return mainVerticalStack
        }
        
        let imageStack = ASStackLayoutSpec.vertical()
        imageStack.children = [imageNode]
        imageStack.spacing = 6.0
        imageStack.style.layoutPosition = CGPoint(x: 0, y: 0)
        
        let titleStack = ASStackLayoutSpec.vertical()
        titleStack.children = [hTitleStack, subtitleNode]
        titleStack.spacing = 2.0
        
        //let rankCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: rankButton)
        rankButton.style.flexShrink = 1.0
        if isKing {
            rankButton.style.minWidth = ASDimension(unit: .points, value: 32.0)
            rankButton.style.height = ASDimension(unit: .points, value: 32.0)
        } else {
            rankButton.style.minWidth = ASDimension(unit: .points, value: 26.0)
            rankButton.style.height = ASDimension(unit: .points, value: 26.0)
        }
        let titleRow = ASStackLayoutSpec.horizontal()
        titleStack.style.flexGrow = 1.0
        titleRow.children = [ titleStack, rankButton]
        
        
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
        contentStack.children = [titleRow]
        contentStack.spacing = 8.0
        
        if let text = post?.text, !text.isEmpty {
            contentStack.children?.append(postTextNode)
        }
        
        if let attachments = post? .attachments {
            if attachments.images.count > 0 {
                contentStack.children?.append(postImageNode)
            }
        }
        
//        groupNode.style.height = ASDimension(unit: .points, value: 24.0)
//        let groupStack = ASStackLayoutSpec.horizontal()
//        groupStack.children = [groupNode,gapNode]
//        contentStack.children?.append(groupStack)
        
        let actionsInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, -4, 0, 16.0), child: actionsRow)
        contentStack.children?.append(actionsInset)
        
        let mainVerticalStack = ASStackLayoutSpec.vertical()
        mainVerticalStack.children = [contentStack]
        mainVerticalStack.spacing = 4.0
        
        mainVerticalStack.style.layoutPosition = CGPoint(x: 40.0 + 10.0, y: 0)
        
        let abs = ASAbsoluteLayoutSpec(children: [imageStack, mainVerticalStack])
        let mainInset = ASInsetLayoutSpec(insets: PostCellNode.mainInsets, child: abs)
        let dividerStack = ASStackLayoutSpec.vertical()
        dividerStack.children = [mainInset, dividerNode]
        dividerStack.spacing = 6.0
        return dividerStack
    }

    func setComments(count:Int) {
        let countStr = "\(count)"
        let str = NSMutableAttributedString(string: "\(countStr) Replies", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: buttonColor
            ])
//        let countAttributes = [
//            NSAttributedStringKey.font : Fonts.medium(ofSize: 14.0),
//            NSAttributedStringKey.foregroundColor: buttonColor
//            ] as [NSAttributedStringKey : Any]
//        str.addAttributes(countAttributes, range: NSRange(location: 0, length: countStr.characters.count))
        
        commentButton.setAttributedTitle(str, for: .normal)
    }

    
    @objc func handleUpvote() {
        guard let post = post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var countChange = 0
        if post.vote == .upvoted {
            post.vote = .notvoted
            countChange -= 1
            let postRef = firestore.collection("posts").document(post.key).collection("votes").document(uid)
            postRef.delete() { error in
            }
        } else {
            if post.vote == .downvoted {
                countChange += 1
            }
            
            countChange += 1
            post.vote = .upvoted
            let postRef = firestore.collection("posts").document(post.key).collection("votes").document(uid)
            postRef.setData([
                "uid": uid,
                "val": true
                ], completion: { error in
                
            })
        }
        setVote(post.vote, animated: true)
        //post.votes += countChange
        //setNumVotes(post.votes)
    }
    
    @objc func handleDownvote() {
        guard let post = post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var countChange = 0
        if post.vote == .downvoted {
            countChange += 1
            post.vote = .notvoted
            let postRef = firestore.collection("posts").document(post.key).collection("votes").document(uid)
            postRef.delete() { error in
            }
        } else {
            
            if post.vote == .upvoted {
                countChange -= 1
            }
            
            countChange -= 1
            
            post.vote = .downvoted
            let postRef = firestore.collection("posts").document(post.key).collection("votes").document(uid)
            postRef.setData([
                "uid": uid,
                "val": false
                ], completion: { error in
                
            })
        }
        setVote(post.vote, animated: true)
        //post.votes += countChange
        //setNumVotes(post.votes)
    }
    
    var isAnimatingDownvote = false
    var isAnimatingUpVote = false
    
    func setVote(_ vote:Vote, animated:Bool) {
        switch vote {
        case .upvoted:
            if animated && !isAnimatingUpVote {
                isAnimatingUpVote = true
                //likeButton.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseOut], animations: {
                    var frame = self.likeButton.view.frame
                    frame.origin.y -= 16.0
                    self.likeButton.view.frame = frame
                }, completion: { _ in
                    UIView.animate(withDuration: 0.50, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.6, options: [.curveEaseIn], animations: {
                        var frame = self.likeButton.view.frame
                        frame.origin.y += 16.0
                        self.likeButton.view.frame = frame
                    }, completion: { _ in
                        self.isAnimatingUpVote = false
                        //self.likeButton.isUserInteractionEnabled = true
                    })
                })
            }
            likeButton.alpha = 0.75
            dislikeButton.alpha = 1.0
            likeButton.setImage(upvotedImage, for: .normal)
            dislikeButton.setImage(downvoteImage, for: .normal)
            break
        case .downvoted:
            if animated && !isAnimatingDownvote {
                isAnimatingDownvote = true
                //self.dislikeButton.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
                    var frame = self.dislikeButton.view.frame
                    frame.origin.y += 10.0
                    self.dislikeButton.view.frame = frame
                }, completion: { _ in
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.6, options: [.curveEaseIn], animations: {
                        var frame = self.dislikeButton.view.frame
                        frame.origin.y -= 10.0
                        self.dislikeButton.view.frame = frame
                    }, completion: { _ in
                        self.isAnimatingDownvote = false
                        //self.dislikeButton.isUserInteractionEnabled = true
                    })
                })
            }
            likeButton.alpha = 1.0
            dislikeButton.alpha = 0.75
            likeButton.setImage(upvoteImage, for: .normal)
            dislikeButton.setImage(downvotedImage, for: .normal)
            break
        case .notvoted:
            likeButton.alpha = 1.0
            dislikeButton.alpha = 1.0
            likeButton.setImage(upvoteImage, for: .normal)
            dislikeButton.setImage(downvoteImage, for: .normal)
            break
        }
    }
    
    var likedRefListener:ListenerRegistration?
    var metaRef:DatabaseReference?
    func listenToPost() {
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("listenToPost")
        let postRef = firestore.collection("posts").document(post.key)
        let voteRef = postRef.collection("votes").document(uid)
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
        
        metaRef = database.child("posts/meta/\(post.key)")
        metaRef?.keepSynced(true)
        metaRef?.observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String:Any] {
                let votesUp = data["votesUp"] as? Int ?? 0
                let votesDown = data["votesDown"] as? Int ?? 0
                var numComments = data["numComments"] as? Int ?? 0
                let comments = data["comments"] as? [String:[String:Any]] ?? [:]
                
                for (_, commentDict) in comments {
                    
                    if let numReplies = commentDict["numReplies"] as? Int {
                        numComments += numReplies
                    }
                }
                post.votes = votesUp - votesDown
                post.comments = numComments
                self.setNumVotes(post.votes)
                self.setComments(count: post.comments)
            }
        })
    }
    
    func setNumVotes(_ votes:Int) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "\(votes)", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: buttonColor,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
    }
    
    func stopListeningToPost() {
        print("stopListeningToPost")
        likedRefListener?.remove()
        metaRef?.keepSynced(false)
        metaRef?.removeAllObservers()
    }
    
    func updatePost(_ post:Post) {
        guard let currentPost = self.post else { return }
        guard post.key == currentPost.key else { return }
        
        self.post = post
    }
    
    @objc func handleMoreButton() {
        guard let post = self.post else { return }
        delegate?.postOptions(post)
        
    }
    
    @objc func handleImageTap() {
        guard let post = post,
            let parentVC = delegate?.postParentVC() else { return }
        
        
        let lightBoxVC = LightboxViewController()
        lightBoxVC.post = post
        
        
        //transitionManager.sourceDelegate = self
        //transitionManager.destinationDelegate = lightBoxVC
        //lightBoxVC.transitioningDelegate = transitionManager
        parentVC.present(lightBoxVC, animated: true, completion: nil)
        
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        listenToPost()
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        stopListeningToPost()
    }
    
    
    func setHighlighted(_ highlighted:Bool) {
        print("setHighlighted: \(highlighted)")
        backgroundColor = highlighted ? UIColor(white: 0.95, alpha: 1.0) : bgColor
    }
    
    func setSelected(_ selected:Bool) {
        print("setSelected: \(selected)")
        backgroundColor = selected ? UIColor(white: 0.95, alpha: 1.0) : bgColor
    }
    
}

extension PostCellNode: LightboxTransitionSourceDelegate {
    func transitionWillBegin(_ isPresenting: Bool) {
        postImageNode.alpha = 0.0
    }
    
    func transitionDidEnd(_ isPresenting: Bool) {
        postImageNode.alpha = 1.0
    }
    
    func transitionSourceImage() -> UIImage? {
        
        return postImageNode.mainImageNode.image
    }
    
    func transitionSourceURL() -> URL? {
        return post?.attachments?.images[0].url
    }
    
    func transitionSourceFrame(_ parentView: UIView) -> CGRect {
        let frame = view.convert(postImageNode.view.frame, to: parentView)

        return frame
    }
    
    
}
