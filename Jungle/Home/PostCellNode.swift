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
    
    var imageNode = ASRoundShadowedImageNode(imageCornerRadius: 22.0, imageShadowRadius: 0.0)
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
    
    static let mainInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 0.0, right: 16.0)
    
    weak var post:Post?
    
    

    private(set) var bgColor = UIColor.white
    private(set) var textColor = UIColor.gray
    private(set) var buttonColor = grayColor
    private(set) var upvoteImage:UIImage!
    private(set) var upvotedImage:UIImage!
    private(set) var downvoteImage:UIImage!
    private(set) var downvotedImage:UIImage!
    private(set) var commentImage:UIImage!
    private(set) var moreImage:UIImage!
    
    var isKing = false
    
    required init(withPost post:Post, type: PostsTableType) {
        super.init()
        self.post = post
        automaticallyManagesSubnodes = true
        
        upvoteImage = UIImage(named:"upvote")
        upvotedImage = UIImage(named:"upvoted")
        downvoteImage = UIImage(named:"downvote")
        downvotedImage = UIImage(named:"downvoted")
        commentImage = UIImage(named:"comment2")
        moreImage = UIImage(named:"more")
        isKing = type == .popular && post.rank != nil && post.rank == 1
        
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
            NSAttributedStringKey.foregroundColor: textColor
            ])
        
        subnameNode.attributedText = NSAttributedString(string: "YOU", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 11.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        subnameNode.textContainerInset = UIEdgeInsets(top: 1.0, left: 6.0, bottom: 0, right: 6.0)
        subnameNode.backgroundColor = post.anon.color
        subnameNode.isHidden = true
        
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
        
        postTextNode.setText(text: post.text, withFont: Fonts.medium(ofSize: 15.0), normalColor: textColor, activeColor: accentColor)
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

        
        dividerNode.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        
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
        
        commentButton.setImage(commentImage, for: .normal)
        commentButton.laysOutHorizontally = true
        commentButton.contentSpacing = 8.0
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
            rankButton.isHidden = type != .popular
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
        subnameNode.layer.cornerRadius = 8
        subnameNode.clipsToBounds = true
        selectionStyle = .none
        
        imageNode.addTarget(self, action: #selector(handleImageTap), forControlEvents: .touchUpInside)
        imageNode.isUserInteractionEnabled = true
        
//        let layoutGuide = view.safeAreaLayoutGuide
//        gradientView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 64.0))
//        gradientView.backgroundColor = UIColor.red.withAlphaComponent(0.25)
//
//        if isKing {
//            view.insertSubview(gradientView, at: 0)
//            gradientView.translatesAutoresizingMaskIntoConstraints = false
//            gradientView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
//            gradientView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
//            gradientView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
//            gradientView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
//            view.sendSubview(toBack: gradientView)
//            gradientView.contentMode = .scaleAspectFill
//            gradientView.image = UIImage(named:"BoxGradient")
//        }
//        gradientView.isHidden = !isKing
    }
    
    var gradientView:UIImageView!
    
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
        contentStack.spacing = 10.0
        
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
        
        let actionsInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 16.0), child: actionsRow)
        contentStack.children?.append(actionsInset)
        
        let mainVerticalStack = ASStackLayoutSpec.vertical()
        mainVerticalStack.children = [contentStack, dividerNode]
        mainVerticalStack.spacing = 4.0
        
        mainVerticalStack.style.layoutPosition = CGPoint(x: 44 + 10.0, y: 0)
        
        let abs = ASAbsoluteLayoutSpec(children: [imageStack, mainVerticalStack])
        let mainInset = ASInsetLayoutSpec(insets: PostCellNode.mainInsets, child: abs)
        return mainInset
    }

    func setReplies(count:Int) {
        let str = NSAttributedString(string: "\(count)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: buttonColor
            ])
        
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
        post.votes += countChange
        setNumVotes(post.votes)
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
        post.votes += countChange
        setNumVotes(post.votes)
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
            likeButton.setImage(upvotedImage, for: .normal)
            dislikeButton.setImage(downvoteImage, for: .normal)
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
            likeButton.setImage(upvoteImage, for: .normal)
            dislikeButton.setImage(downvotedImage, for: .normal)
            break
        case .notvoted:
            likeButton.setImage(upvoteImage, for: .normal)
            dislikeButton.setImage(downvoteImage, for: .normal)
            break
        }
    }
    
    var metaRefListener:ListenerRegistration?
    var likedRefListener:ListenerRegistration?
    var lexiconRefListener:ListenerRegistration?
    
    func listenToPost() {
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("listenToPost")
        let postRef = firestore.collection("posts").document(post.key)
        let metaVotesRef = firestore.collection("postMeta").document(post.key)
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
        
        metaRefListener = metaVotesRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            if let data = document.data() {
                post.votes = data["votesSum"] as? Int ?? 0
                post.replies = data["comments"] as? Int ?? 0
                self.setNumVotes(post.votes)
                self.setReplies(count: post.replies)
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
            NSAttributedStringKey.foregroundColor: buttonColor,
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
        metaRefListener?.remove()
        lexiconRefListener?.remove()
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
//        if isKing {
//            view.sendSubview(toBack: gradientView)
//        }
        
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        stopListeningToPost()
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
