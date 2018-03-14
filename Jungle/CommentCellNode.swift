//
//  CommentCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit
import Firebase

protocol CommentCellDelegate:class {
    func handleReply(_ reply:Reply)
}

class CommentCellNode:ASCellNode {
    
    let gradientColorTop = accentColor
    let gradientColorBot = hexColor(from: "#22D29F")
    
    var imageNode = ASNetworkImageNode()
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
    
    var replyImageNode = ASRoundShadowedImageNode(imageCornerRadius: 12.0, imageShadowRadius: 0.0)
    var replyTitleNode = ASTextNode()
    
    let groupNode = ASButtonNode()
    
    let countLabel = ASTextNode()
    var postImageNode = ASRoundShadowedImageNode(imageCornerRadius: 18.0, imageShadowRadius: 8.0)
    
    var transitionManager = LightboxViewerTransitionManager()
    weak var delegate:CommentCellDelegate?
    weak var reply:Reply?
    weak var post:Post?
    
    let gapNode = ASDisplayNode()
    
    var isReply = false

    struct Constants {
        static let imageWidth:CGFloat = 36.0
        static let mainInsets = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 0.0, right: 0.0)
    }
    
    struct ReplyConstants {
        static let imageWidth:CGFloat = 24.0
        static let mainInsets = UIEdgeInsets(top: 4.0, left: 16.0 + 36.0 + 8.0, bottom: 0.0, right: 0.0)
    }
    
    private(set) var bgColor = UIColor.white
    private(set) var textColor = UIColor.gray
    private(set) var buttonColor = grayColor
    private(set) var upvoteImage:UIImage!
    private(set) var upvotedImage:UIImage!
    private(set) var downvoteImage:UIImage!
    private(set) var downvotedImage:UIImage!
    private(set) var commentImage:UIImage!
    private(set) var moreImage:UIImage!
    

    
    required init(reply:Reply, toPost post:Post, isReply:Bool?=nil, hideDivider:Bool?=nil) {
        super.init()

        self.reply = reply
        self.post = post
        self.isReply = isReply != nil ? isReply! : false
        
        automaticallyManagesSubnodes = true
        
        upvoteImage = UIImage(named:"upvote")
        upvotedImage = UIImage(named:"upvoted")
        downvoteImage = UIImage(named:"downvote")
        downvotedImage = UIImage(named:"downvoted")
        commentImage = UIImage(named:"reply")
        moreImage = UIImage(named:"more")
        
    
        backgroundColor = bgColor
        
        imageNode.backgroundColor = reply.anon.color
        
        postImageNode.isUserInteractionEnabled = true
        
        titleNode.attributedText = NSAttributedString(string: reply.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: textColor
            ])
        
        subnameNode.attributedText = NSAttributedString(string: "YOU", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 10.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        subnameNode.textContainerInset = UIEdgeInsets(top: 1.0, left: 6.0, bottom: 0, right: 6.0)
        subnameNode.backgroundColor = reply.anon.color
        subnameNode.isHidden = true
        

        let subtitleStr = " · \(reply.createdAt.timeSinceNow())"
        
        subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: textColor
            ])
        
        postTextNode.maximumNumberOfLines = 0
        postTextNode.truncationMode = .byWordWrapping
        
        postTextNode.setText(text: reply.text, withFont: Fonts.regular(ofSize: 14.0), normalColor: UIColor.black, activeColor: accentColor)
        postTextNode.tapHandler = { type, textValue in
           
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "-", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: buttonColor,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
        
//
//        if let attachments = post.attachments {
//            if attachments.images.count > 0 {
//                let image = attachments.images[0]
//                let color =  hexColor(from: image.colorHex)
//                postImageNode.mainImageNode.backgroundColor = color
//                postImageNode.mainImageNode.url = image.url
//                postImageNode.style.height = ASDimension(unit: .points, value: 192)
//                postImageNode.applyShadow(withColor: color, opacity: 0.5)
//            }
//        } else {
//            postImageNode.style.height = ASDimension(unit: .points, value: 0.0)
//        }
        
        dividerNode.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        if let hideDivider = hideDivider {
            dividerNode.isHidden = hideDivider
        } else {
            dividerNode.isHidden = reply.numReplies > 0 || self.isReply
        }
        
        likeButton.setImage(upvoteImage, for: .normal)
        likeButton.laysOutHorizontally = true
        likeButton.contentSpacing = 6.0
        likeButton.contentHorizontalAlignment = .middle
        likeButton.contentEdgeInsets = .zero
        likeButton.tintColor = buttonColor
        likeButton.tintColorDidChange()
        likeButton.alpha = 0.75
        
        dislikeButton.setImage(downvoteImage, for: .normal)
        dislikeButton.laysOutHorizontally = true
        dislikeButton.contentSpacing = 6.0
        dislikeButton.contentHorizontalAlignment = .middle
        dislikeButton.contentEdgeInsets = .zero
        dislikeButton.tintColor = buttonColor
        dislikeButton.tintColorDidChange()
        dislikeButton.alpha = 0.75
        
        likeButton.addTarget(self, action: #selector(handleUpvote), forControlEvents: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(handleDownvote), forControlEvents: .touchUpInside)
        
        let commentStr = NSAttributedString(string: "Reply", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: buttonColor
            ])
        commentButton.setAttributedTitle(commentStr, for: .normal)
        commentButton.laysOutHorizontally = true
        commentButton.contentSpacing = 8.0
        commentButton.contentHorizontalAlignment = .middle
        commentButton.alpha = 0.75
        countLabel.alpha = 0.75
       
        moreButtonNode.setImage(moreImage, for: .normal)
        moreButtonNode.contentHorizontalAlignment = .right
        
        commentButton.addTarget(self, action: #selector(handleReply), forControlEvents: .touchUpInside)
        
        replyImageNode.style.width = ASDimension(unit: .points, value: 24)
        replyImageNode.style.height = ASDimension(unit: .points, value: 24)
        
        titleNode.tintColor = UIColor.gray
        titleNode.tintColorDidChange()
        
        setTitle("SillyDeer Replied · \(reply.numReplies) Replies")
        self.setNumVotes(reply.votes)
        self.setVote(reply.vote, animated: false)
    }
    
    override func didLoad() {
        super.didLoad()
        subnameNode.layer.cornerRadius = 8
        subnameNode.clipsToBounds = true
        selectionStyle = .none
        
        imageNode.clipsToBounds = true
        
        if self.isReply {
            imageNode.layer.cornerRadius = ReplyConstants.imageWidth / 2
        } else {
            imageNode.layer.cornerRadius = Constants.imageWidth / 2
        }
        
    }
    
    func setTitle(_ text:String) {
        let attrTitle = NSAttributedString(string: text, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        replyTitleNode.attributedText = attrTitle
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        if isReply {
            imageNode.style.width = ASDimension(unit: .points, value: ReplyConstants.imageWidth)
            imageNode.style.height = ASDimension(unit: .points, value: ReplyConstants.imageWidth)
        } else {
            imageNode.style.width = ASDimension(unit: .points, value: Constants.imageWidth)
            imageNode.style.height = ASDimension(unit: .points, value: Constants.imageWidth)
        }
        
        
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
        
        let subtitleCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subtitleNode)
        let subtitleInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: subtitleCenterY)
        
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.children = [nameStack, subtitleInset]
        titleStack.spacing = 0.0
        
        let titleRow = ASStackLayoutSpec.horizontal()
        titleStack.style.flexGrow = 1.0
        titleRow.children = [ titleStack]
        
        let countCenterY = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: countLabel)
        let likeStack = ASStackLayoutSpec.horizontal()
        likeStack.children = [ likeButton, countCenterY, dislikeButton ]
        likeStack.spacing = 4.0
        
        countLabel.style.width = ASDimension(unit: .points, value: 24)
        countLabel.style.flexGrow = 1.0
        likeButton.style.flexShrink = 1.0
        dislikeButton.style.flexShrink = 1.0
//        likeStack.style.width = ASDimension(unit: .fraction, value: 0.35)
//        commentButton.style.width = ASDimension(unit: .fraction, value: 0.35)
//        moreButtonNode.style.width = ASDimension(unit: .fraction, value: 0.3)

        gapNode.style.flexGrow = 1.0
        
        let actionsRow = ASStackLayoutSpec.horizontal()
        actionsRow.children = [ likeStack]
        actionsRow.spacing = 32.0
        //actionsRow.justifyContent = .end
        
        
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [titleRow]
        contentStack.spacing = 4.0
        
        if let text = reply?.text, !text.isEmpty {
            contentStack.children?.append(postTextNode)
        }
        var ainsets = UIEdgeInsets.zero
        
        if !isReply {
            ainsets = UIEdgeInsetsMake(0, -6.0, 0, -16.0)
        }
        
        
        let actionsInset = ASInsetLayoutSpec(insets: ainsets, child: actionsRow)
        contentStack.children?.append(actionsInset)
        
        let mainVerticalStack = ASStackLayoutSpec.vertical()
        mainVerticalStack.children = [contentStack]
        mainVerticalStack.spacing = 0.0
        
        
        
        let abs = ASAbsoluteLayoutSpec(children: [imageStack, mainVerticalStack])
        
        var insets:UIEdgeInsets!
        if isReply {
            mainVerticalStack.style.layoutPosition = CGPoint(x: CommentCellNode.ReplyConstants.imageWidth + 8.0, y: 0)
            insets = UIEdgeInsets(top: 4.0, left: 16.0 + 36.0 + 8.0, bottom: 0.0, right: 0.0)
        } else {
            actionsRow.children?.append(commentButton)
            mainVerticalStack.style.layoutPosition = CGPoint(x: CommentCellNode.Constants.imageWidth + 8.0, y: 0)
            insets = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 6.0, right: 0.0)
        }
        let mainInset = ASInsetLayoutSpec(insets: insets, child: abs)
        let yoursaying = ASStackLayoutSpec.vertical()
        yoursaying.children = [mainInset, dividerNode]
        yoursaying.spacing = 0.0
        return yoursaying
    
    }

    
    @objc func handleReply() {
        guard let reply = self.reply else { return }
        delegate?.handleReply(reply)
    }
    
    func setHighlighted(_ highlighted:Bool) {
        backgroundColor = highlighted ? UIColor(white: 0.95, alpha: 1.0) : bgColor
    }
    
    func setSelected(_ selected:Bool) {
        backgroundColor = selected ? UIColor(white: 0.95, alpha: 1.0) : bgColor
    }
    
    @objc func handleUpvote() {
        guard let reply = reply else { return }
        guard let post = post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var votesRef:DocumentReference!
        let postRef = firestore.collection("posts").document(post.key)
        var commentRef:DocumentReference!
        
        if let replyTo = reply.replyTo {
            commentRef = postRef.collection("comments").document(reply.key).collection("replies").document(replyTo)
        } else {
            commentRef = postRef.collection("comments").document(reply.key)
        }
       votesRef = commentRef.collection("votes").document(uid)
        
        
        var countChange = 0
        if reply.vote == .upvoted {
            reply.vote = .notvoted
            countChange -= 1
            reply.votes += countChange
            //setNumVotes(reply.votes)
            votesRef.delete() { error in
            }
        } else {
            if reply.vote == .downvoted {
                countChange += 1
            }
            
            countChange += 1
            //reply.votes += countChange
            //setNumVotes(reply.votes)
            reply.vote = .upvoted

            votesRef.setData([
                "uid": uid,
                "val": true
                ], completion: { error in
                    
            })
        }
        setVote(reply.vote, animated: true)
//        reply.votes += countChange
//        setNumVotes(reply.votes)
    }
    
    @objc func handleDownvote() {
        guard let reply = reply else { return }
        guard let post = post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var votesRef:DocumentReference!
        let postRef = firestore.collection("posts").document(post.key)
        let commentRef = postRef.collection("comments").document(reply.key)
        votesRef = commentRef.collection("votes").document(uid)
        
        var countChange = 0
        if reply.vote == .downvoted {
            countChange += 1
            reply.vote = .notvoted
            //reply.votes += countChange
            //setNumVotes(reply.votes)
            
            votesRef.delete() { error in}
            
        } else {
            
            if reply.vote == .upvoted {
                countChange -= 1
            }
            
            countChange -= 1
            
            //reply.votes += countChange
            //setNumVotes(reply.votes)
            
            reply.vote = .downvoted
            
            
            votesRef.setData([
                "uid": uid,
                "val": false
                ], completion: { error in
            })
        }
        setVote(reply.vote, animated: true)

    }
    
    var isAnimatingDownvote = false
    var isAnimatingUpVote = false
    
    func setVote(_ vote:Vote, animated:Bool) {
        print("META SETVOTE: \(vote)")
        switch vote {
        case .upvoted:
            if animated && !isAnimatingUpVote {
                isAnimatingUpVote = true
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
                    })
                })
            }
            likeButton.setImage(upvotedImage, for: .normal)
            dislikeButton.setImage(downvoteImage, for: .normal)
            votesColor = accentColor
            likeButton.alpha = 1.0
            dislikeButton.alpha = 0.75
            break
        case .downvoted:
            if animated && !isAnimatingDownvote {
                isAnimatingDownvote = true
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
                    })
                })
            }
            likeButton.setImage(upvoteImage, for: .normal)
            dislikeButton.setImage(downvotedImage, for: .normal)
            votesColor = redColor
            likeButton.alpha = 0.75
            dislikeButton.alpha = 1.0
            break
        case .notvoted:
            likeButton.setImage(upvoteImage, for: .normal)
            dislikeButton.setImage(downvoteImage, for: .normal)
            votesColor = UIColor.gray
            likeButton.alpha = 0.75
            dislikeButton.alpha = 0.75 
            break
        }
        if reply != nil {
            setNumVotes(reply!.votes)
        }
        
    }
    
    var votesColor = UIColor.gray
    func setNumVotes(_ votes:Int) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "\(votes)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: votesColor,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
    }
    
    var commentVotesRef:DatabaseReference?
    var metaRefListener:ListenerRegistration?
    var likedRefListener:ListenerRegistration?
    var lexiconRefListener:ListenerRegistration?
    
    func listenToReply() {
        guard let post = self.post else { return }
        guard let reply = self.reply else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let postRef = firestore.collection("posts").document(post.key)
        let commentRef = postRef.collection("comments").document(reply.key)
        let voteRef = commentRef.collection("votes").document(uid)
        //let lexiconRef = postRef.collection("lexicon").document(uid)
        print("RXC listenToReply")
        likedRefListener?.remove()
        let options = DocumentListenOptions()
        options.includeMetadataChanges(true)
        
        
        
        likedRefListener = voteRef.addSnapshotListener(options: options, listener: { snapshot, error in
            
            var vote = Vote.notvoted
            
            if let snapshot = snapshot {
                
            
                let meta = snapshot.metadata
                print("META hasPendingWrites: \(meta.hasPendingWrites) | fromCache: \(meta.isFromCache)")
                //if (meta.isFromCache) { return }
                if let data = snapshot.data(),
                    let val = data["val"] as? Bool {
                    vote = val ? .upvoted : .downvoted
                }
                print("META hasPendingWrites: \(meta.hasPendingWrites) | fromCache: \(meta.isFromCache) | vote: \(vote)")
            }
            

            reply.vote = vote
            self.setVote(reply.vote, animated: false)
            
        })
        
        commentVotesRef = database.child("posts/comments/\(post.key)/comments/\(reply.key)")
        commentVotesRef?.observe(.value, with: { snapshot in
            if let dict = snapshot.value as? [String:Any] {
                let votesUp = dict["votesUp"] as? Int ?? 0
                let votesDown = dict["votesDown"] as? Int ?? 0
                let votesSum = votesUp - votesDown
                self.setNumVotes(votesSum)
            }
        })
//        metaRefListener = metaVotesRef.addSnapshotListener { documentSnapshot, error in
//            guard let document = documentSnapshot else {
//                print("Error fetching document: \(error!)")
//                return
//            }
//            if let data = document.data() {
//                post.votes = data["votesSum"] as? Int ?? 0
//                post.comments = data["numComments"] as? Int ?? 0
//                self.setNumVotes(post.votes)
//                //self.setComments(count: post.comments)
//            }
//        }
    }
    
    func stopListeningToReply() {
        print("RXC stopListeningToReply")
        likedRefListener?.remove()
        commentVotesRef?.removeAllObservers()
        //metaRefListener?.remove()
        //lexiconRefListener?.remove()
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        listenToReply()
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        stopListeningToReply()
        setNumVotes(0)
        setVote(.notvoted, animated: false)
        print("DID EXIT THAT VISIBLE STATE FAM")
    }
}

