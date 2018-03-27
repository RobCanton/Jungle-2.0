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
    
    var replyLine = ASDisplayNode()
    var isReply = false

    struct Constants {
        static let imageWidth:CGFloat = 36.0
        static let mainInsets = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 0.0, right: 0.0)
        static let replyLineWidth:CGFloat = 3.0
    }
    
    struct ReplyConstants {
        static let imageWidth:CGFloat = 24.0
        static let mainInsets = UIEdgeInsets(top: 4.0, left: 16.0, bottom: 0.0, right: 0.0)
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
    

    
    required init(reply:Reply, toPost post:Post, isReply:Bool?=nil, hideDivider:Bool?=nil, hideReplyLine:Bool?=nil) {
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
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: reply.anon.color
            ])
        
        var subnameStr = ""
        if reply.isYou {
            subnameStr = "YOU"
            subnameNode.isHidden = false
        } else if reply.anon.key == post.anon.key {
            subnameStr = "OP"
            subnameNode.isHidden = false
        } else {
            subnameNode.isHidden = true
        }
        
        subnameNode.attributedText = NSAttributedString(string: subnameStr, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 9.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        subnameNode.textContainerInset = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 0, right: 4.0)
        subnameNode.backgroundColor = reply.anon.color

        let subtitleStr = " · \(reply.createdAt.timeSinceNow())"
        
        subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: subtitleColor
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
            NSAttributedStringKey.foregroundColor: subtitleColor,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
        
        dividerNode.backgroundColor = subtitleColor.withAlphaComponent(0.25)
        dividerNode.isHidden = self.isReply
        replyLine.isHidden = hideReplyLine ?? true
        
        replyLine.backgroundColor = subtitleColor.withAlphaComponent(0.25)
        
        likeButton.setImage(upvoteImage, for: .normal)
        likeButton.laysOutHorizontally = true
        likeButton.contentSpacing = 6.0
        likeButton.contentHorizontalAlignment = .middle
        likeButton.contentEdgeInsets = .zero
        likeButton.tintColor = buttonColor
        likeButton.tintColorDidChange()
        likeButton.alpha = 0.80
        
        dislikeButton.setImage(downvoteImage, for: .normal)
        dislikeButton.laysOutHorizontally = true
        dislikeButton.contentSpacing = 6.0
        dislikeButton.contentHorizontalAlignment = .middle
        dislikeButton.contentEdgeInsets = .zero
        dislikeButton.tintColor = buttonColor
        dislikeButton.tintColorDidChange()
        dislikeButton.alpha = 0.80
        
        likeButton.addTarget(self, action: #selector(handleUpvote), forControlEvents: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(handleDownvote), forControlEvents: .touchUpInside)
        
        let commentStr = NSAttributedString(string: "Reply", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: subtitleColor
            ])
        commentButton.setAttributedTitle(commentStr, for: .normal)
        commentButton.laysOutHorizontally = true
        commentButton.contentSpacing = 8.0
        commentButton.contentHorizontalAlignment = .middle
        commentButton.alpha = 0.80
        countLabel.alpha = 0.80
       
        moreButtonNode.setImage(moreImage, for: .normal)
        moreButtonNode.contentHorizontalAlignment = .right
        
        commentButton.addTarget(self, action: #selector(handleReply), forControlEvents: .touchUpInside)
        
        replyImageNode.style.width = ASDimension(unit: .points, value: 24)
        replyImageNode.style.height = ASDimension(unit: .points, value: 24)
        
        titleNode.tintColor = subtitleColor
        titleNode.tintColorDidChange()
        
        setTitle("SillyDeer Replied · \(reply.numReplies) Replies")
        self.setNumVotes(reply.votes)
        self.setVote(reply.vote, animated: false)
    }
    
    override func didLoad() {
        super.didLoad()
        subnameNode.layer.cornerRadius = 4
        subnameNode.clipsToBounds = true
        selectionStyle = .none
        
        imageNode.clipsToBounds = true
        imageNode.layer.cornerRadius = Constants.imageWidth / 2
        
        replyLine.cornerRadius = Constants.replyLineWidth / 2
        replyLine.clipsToBounds = true
        
    }
    
    func setTitle(_ text:String) {
        let attrTitle = NSAttributedString(string: text, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
            ])
        replyTitleNode.attributedText = attrTitle
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.style.width = ASDimension(unit: .points, value: Constants.imageWidth)
        imageNode.style.height = ASDimension(unit: .points, value: Constants.imageWidth)
        
        
        likeButton.style.height = ASDimension(unit: .points, value: 32.0)
        dislikeButton.style.height = ASDimension(unit: .points, value: 32.0)
        commentButton.style.height = ASDimension(unit: .points, value: 32.0)
        
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
        
        
        let subnameCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subnameNode)
        
        let nameStack = ASStackLayoutSpec.horizontal()
        nameStack.children = [titleNode]
        nameStack.spacing = 4.0
        
        if !subnameNode.isHidden {
            nameStack.children?.append(subnameCenterY)
        }
        
        replyLine.style.width = ASDimension(unit: .points, value: Constants.replyLineWidth)
        replyLine.style.flexGrow = 1.0
        let replyLineXPos = Constants.mainInsets.left + Constants.imageWidth/2 - Constants.replyLineWidth/2
        var top = Constants.mainInsets.top
        if isReply {
            top = ReplyConstants.mainInsets.top
        }
        replyLine.style.layoutPosition = CGPoint(x:replyLineXPos, y: Constants.imageWidth + 4.0 + top)
        let replyLineAbs = ASAbsoluteLayoutSpec(children: [replyLine])
        
        let imageStack = ASStackLayoutSpec.vertical()
        imageStack.children = [imageNode]
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
        
        ainsets = UIEdgeInsetsMake(0, -6.0, 0, -16.0)
        
        let actionsInset = ASInsetLayoutSpec(insets: ainsets, child: actionsRow)
        contentStack.children?.append(actionsInset)
        
        let mainVerticalStack = ASStackLayoutSpec.vertical()
        mainVerticalStack.children = [contentStack]
        mainVerticalStack.spacing = 0.0
        
        
        let abs = ASAbsoluteLayoutSpec(children: [imageStack, mainVerticalStack])
        
        var insets:UIEdgeInsets!
        actionsRow.children?.append(commentButton)
        mainVerticalStack.style.layoutPosition = CGPoint(x: CommentCellNode.Constants.imageWidth + 8.0, y: 0)
        
        if self.isReply {
            insets = UIEdgeInsets(top: 4.0, left: 16.0, bottom: 6.0, right: 0.0)
        } else {
            insets = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 6.0, right: 6.0)
        }
        let mainInset = ASInsetLayoutSpec(insets: insets, child: abs)
        let o = ASOverlayLayoutSpec(child: mainInset, overlay: replyLineAbs)
        let yoursaying = ASStackLayoutSpec.vertical()
        yoursaying.children = [dividerNode, o]
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let replyRef = firestore.collection("replies").document(reply.key)
        let votesRef = replyRef.collection("votes").document(uid)
        
        
        var countChange = 0
        if reply.vote == .upvoted {
            reply.vote = .notvoted
            countChange -= 1
            //reply.votes += countChange
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
        //reply.votes += countChange
        //setNumVotes(reply.votes)
    }
    
    @objc func handleDownvote() {
        guard let reply = reply else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let replyRef = firestore.collection("replies").document(reply.key)
        let votesRef = replyRef.collection("votes").document(uid)
        
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
            
            //setNumVotes(reply.votes)
            
            reply.vote = .downvoted
            
            
            votesRef.setData([
                "uid": uid,
                "val": false
                ], completion: { error in
            })
        }
        //reply.votes += countChange
        //setNumVotes(reply.votes)
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
            likeButton.alpha = 0.80
            dislikeButton.alpha = 0.80
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
            likeButton.alpha = 0.80
            dislikeButton.alpha = 0.80
            break
        case .notvoted:
            likeButton.setImage(upvoteImage, for: .normal)
            dislikeButton.setImage(downvoteImage, for: .normal)
            votesColor = UIColor.gray
            likeButton.alpha = 0.80
            dislikeButton.alpha = 0.80
            break
        }
        if reply != nil {
            //setNumVotes(reply!.votes)
        }
        
    }
    
    var votesColor = UIColor.gray
    func setNumVotes(_ votes:Int) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "\(votes)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: subtitleColor,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
    }
    
    var commentVotesRef:DatabaseReference?
    var metaRefListener:ListenerRegistration?
    var likedRefListener:ListenerRegistration?
    var lexiconRefListener:ListenerRegistration?
    
    func listenToReply() {
        guard let reply = self.reply else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        listeningDict[reply.key] = true
        let replyRef = firestore.collection("replies").document(reply.key)
        let voteRef = replyRef.collection("votes").document(uid)
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
        
        commentVotesRef = database.child("replies/meta/\(reply.key)/votes")
        commentVotesRef?.keepSynced(true)
        commentVotesRef?.observe(.value, with: { snapshot in
            let votesSum = snapshot.value as? Int ?? 0
            self.setNumVotes(votesSum)
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
        if let reply = self.reply  {
            listeningDict[reply.key] = nil
        }
        
        likedRefListener?.remove()
        commentVotesRef?.keepSynced(false)
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
        //setNumVotes(0)
        //setVote(.notvoted, animated: false)
        print("DID EXIT THAT VISIBLE STATE FAM")
    }
}

