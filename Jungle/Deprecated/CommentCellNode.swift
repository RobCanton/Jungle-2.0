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
    func handleReply(_ reply:Post)
}

class CommentPreviewNode:ASDisplayNode {
    var imageNode = ASNetworkImageNode()
    var titleNode = ASTextNode()
    var subnameNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var postTextNode = ActiveTextNode()
    
    var hasText = false
    
    required init(reply:Post?, toPost post: Post) {
        super.init()
        automaticallyManagesSubnodes = true
        guard let reply = reply else { return }
        hasText = post.text != ""
        
        imageNode.backgroundColor = reply.anon.color

        titleNode.attributedText = NSAttributedString(string: reply.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.black
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
        
        print("\(reply.text) IT IS YOU: \(reply.isYou)")
        subnameNode.attributedText = NSAttributedString(string: subnameStr, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 9.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        subnameNode.textContainerInset = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 0, right: 4.0)
        subnameNode.backgroundColor = reply.anon.color
        
        let subtitleStr = ""//" · \(reply.createdAt.timeSinceNow())"
        
        subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: subtitleColor
            ])
        
        postTextNode.maximumNumberOfLines = 2
        postTextNode.truncationMode = .byTruncatingTail
        
        postTextNode.setText(text: reply.text, withSize: 14.0, normalColor: UIColor.black, activeColor: accentColor)
        postTextNode.tapHandler = { type, textValue in
            
        }
    }
    
    override func didLoad() {
        super.didLoad()
        subnameNode.layer.cornerRadius = 4
        subnameNode.clipsToBounds = true
        
        imageNode.clipsToBounds = true
        imageNode.layer.cornerRadius = 10.0
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.style.width = ASDimension(unit: .points, value: 20.0)
        imageNode.style.height = ASDimension(unit: .points, value: 20.0)
        
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
        
        let titleCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleNode)
        let subnameCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subnameNode)
        let subtitleCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subtitleNode)
        
        let hTitleStack = ASStackLayoutSpec.horizontal()
        hTitleStack.children = [titleCenterY]
        hTitleStack.spacing = 4.0
        
        if !subnameNode.isHidden {
            hTitleStack.children?.append(subnameCenterY)
        }
        
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
        
        let nameStack = ASStackLayoutSpec.horizontal()
        nameStack.spacing = 1.0
        nameStack.children = [hTitleStack, subtitleCenterY]
        
        let imageStack = ASStackLayoutSpec.horizontal()
        imageStack.children = [imageNode, nameStack]
        imageStack.spacing = 8.0
        
        let imageInsets = UIEdgeInsetsMake(4.0, 12, 0, 12)
        let imageInset = ASInsetLayoutSpec(insets: imageInsets, child: imageStack)
        
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = []
        contentStack.spacing = 8.0
        
        contentStack.children?.append(imageInset)
        
        let textInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 12, 0, 12), child: postTextNode)
        
        if hasText {
            contentStack.children?.append(textInset)
        }
        
        let contentInsets = UIEdgeInsets.zero
        
        return ASInsetLayoutSpec(insets: contentInsets, child: contentStack)
        
    }
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
    
    //var transitionManager = LightboxViewerTransitionManager()
    weak var delegate:CommentCellDelegate?
    weak var reply:Post?
    weak var post:Post?
    
    let gapNode = ASDisplayNode()
    
    var replyLine = ASDisplayNode()
    var isReply = false
    var isLastReply = false

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
    private(set) var textColor = hexColor(from: "708078")
    private(set) var buttonColor = hexColor(from: "BEBEBE")
    private(set) var upvoteImage:UIImage!
    private(set) var upvotedImage:UIImage!
    private(set) var downvoteImage:UIImage!
    private(set) var downvotedImage:UIImage!
    private(set) var commentImage:UIImage!
    private(set) var moreImage:UIImage!
    

    
    required init(reply:Post, toPost post:Post, isReply:Bool?=nil, isLastReply:Bool?=nil) {
        super.init()

        self.reply = reply
        self.post = post
        self.isReply = isReply ?? false
        self.isLastReply = isLastReply ?? false
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
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
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
        
        postTextNode.setText(text: reply.text, withSize: 14.0, normalColor: UIColor.black, activeColor: accentColor)
        postTextNode.tapHandler = { type, textValue in
           
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "-", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: subtitleColor,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
        
        dividerNode.backgroundColor = hexColor(from: "#eff0e9")
        dividerNode.isHidden = false//hideDivider ?? false
        replyLine.isHidden = false //hideReplyLine ?? true
        
        replyLine.backgroundColor = subtitleColor.withAlphaComponent(0.25)
        
        likeButton.setImage(upvoteImage, for: .normal)
        likeButton.laysOutHorizontally = true
        likeButton.contentSpacing = 6.0
        likeButton.contentHorizontalAlignment = .middle
        likeButton.contentEdgeInsets = .zero
        likeButton.imageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: self.buttonColor) ?? image
        }
        //likeButton.imageNode.tintColor = UIColor.red
        
        dislikeButton.setImage(downvoteImage, for: .normal)
        dislikeButton.laysOutHorizontally = true
        dislikeButton.contentSpacing = 6.0
        dislikeButton.contentHorizontalAlignment = .middle
        dislikeButton.contentEdgeInsets = .zero
        dislikeButton.tintColor = buttonColor
        dislikeButton.tintColorDidChange()
        
        dislikeButton.imageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: self.buttonColor) ?? image
        }
        
        commentButton.laysOutHorizontally = true
        commentButton.setImage(commentImage, for: .normal)
        commentButton.contentSpacing = 2.0
        commentButton.contentHorizontalAlignment = .middle
        commentButton.imageNode.imageModificationBlock = { image in
            return image.maskWithColor(color: self.buttonColor) ?? image
        }
        
        let str = NSMutableAttributedString(string: "Reply", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: buttonColor
            ])
        commentButton.setAttributedTitle(str, for: .normal)
        
        likeButton.addTarget(self, action: #selector(handleUpvote), forControlEvents: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(handleDownvote), forControlEvents: .touchUpInside)
        
        commentButton.setImage(commentImage, for: .normal)
        commentButton.laysOutHorizontally = true
        commentButton.contentSpacing = 0.0
        commentButton.contentHorizontalAlignment = .middle
       
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
        imageNode.layer.cornerRadius = 10.0
        
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
        imageNode.style.width = ASDimension(unit: .points, value: 20.0)
        imageNode.style.height = ASDimension(unit: .points, value: 20.0)
        
        
        likeButton.style.height = ASDimension(unit: .points, value: 32.0)
        dislikeButton.style.height = ASDimension(unit: .points, value: 32.0)
        commentButton.style.height = ASDimension(unit: .points, value: 32.0)
        
        dividerNode.style.height = ASDimension(unit: .points, value: 4.0)
        
        
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
        
        let titleCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleNode)
        let subnameCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subnameNode)
        let subtitleCenterY = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subtitleNode)
        
        let hTitleStack = ASStackLayoutSpec.horizontal()
        hTitleStack.children = [titleCenterY]
        hTitleStack.spacing = 4.0
        
        if !subnameNode.isHidden {
            hTitleStack.children?.append(subnameCenterY)
        }
        
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
        
        let nameStack = ASStackLayoutSpec.horizontal()
        nameStack.spacing = 1.0
        nameStack.children = [hTitleStack, subtitleCenterY]
        
        let imageStack = ASStackLayoutSpec.horizontal()
        imageStack.children = [imageNode, nameStack]
        imageStack.spacing = 8.0
        
        let imageInsets = isReply ? UIEdgeInsetsMake(0.0, 12, 0, 12) : UIEdgeInsetsMake(4.0, 12, 0, 12)
        let imageInset = ASInsetLayoutSpec(insets: imageInsets, child: imageStack)
        
        let countCenterY = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: countLabel)
        let likeStack = ASStackLayoutSpec.horizontal()
        likeStack.children = [ likeButton, countCenterY, dislikeButton ]
        likeStack.spacing = 0.0
        
        countLabel.style.flexGrow = 1.0
        
        let actionsRow = ASStackLayoutSpec.horizontal()
        actionsRow.style.flexGrow = 1.0
        actionsRow.children = [ likeStack, commentButton, moreButtonNode]
        actionsRow.spacing = 0.0
        actionsRow.alignContent = .spaceBetween
        actionsRow.justifyContent = .spaceBetween
        likeStack.style.width = ASDimension(unit: .fraction, value: 0.3333)
        commentButton.style.width = ASDimension(unit: .fraction, value: 0.3333)
        moreButtonNode.style.width = ASDimension(unit: .fraction, value: 0.3333)
        
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = []
        contentStack.spacing = 8.0
        
        if !isReply {
            contentStack.children?.append(dividerNode)
        }
        
        contentStack.children?.append(imageInset)
        
        let textInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 12, 0, 12), child: postTextNode)
        
        if let text = post?.text, !text.isEmpty {
            contentStack.children?.append(textInset)
        }
        
        if let attachments = post? .attachments {
//            if attachments.images.count > 0 {
//                contentStack.children?.append(postImageNode)
//            }
        }
        
        
        let actionsInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 12, 12, 12), child: actionsRow)
        
        let fullStack = ASStackLayoutSpec.vertical()
        fullStack.spacing = -2.0
        fullStack.children = [contentStack, actionsInset]
        
        var contentInsets = UIEdgeInsets.zero
        if isReply {
            contentInsets = UIEdgeInsetsMake(0, 16, 0, 0)
        }
        dividerNode.isHidden = isReply
        replyLine.isHidden = !isReply
        
        replyLine.style.width = ASDimension(unit: .points, value: 1.0)
        replyLine.style.flexGrow = 1.0
        //replyLine.style.height = ASDimension(unit: .points, value: constrainedSize.max.height - 50)
        let replyLineXPos:Double = 12.0
        
        replyLine.style.layoutPosition = CGPoint(x:replyLineXPos, y: 0.0)
        
        let replyLineAbs = ASAbsoluteLayoutSpec(children: [replyLine])
        let replyLineInsets = isLastReply ? UIEdgeInsetsMake(0, 0, 12, 0) : UIEdgeInsetsMake(0, 0, 0, 0)
        let replyLineInset = ASInsetLayoutSpec(insets: replyLineInsets, child: replyLineAbs)
        let yo = ASInsetLayoutSpec(insets: contentInsets, child: fullStack)
        
        return ASOverlayLayoutSpec(child: yo, overlay: replyLineInset)
    
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
        guard let user = Auth.auth().currentUser else { return }
        
        if user.isAnonymous {
            mainProtocol.openLoginView()
            return
        }
        
        let uid = user.uid
        
        var countChange = 0
        if reply.vote == .upvoted {
            reply.vote = .notvoted
            countChange -= 1
            let postRef = database.child("posts/votes/\(reply.key)/\(uid)")
            postRef.removeValue()
        } else {
            if reply.vote == .downvoted {
                countChange += 1
            }
            
            countChange += 1
            reply.vote = .upvoted
            let postRef = database.child("posts/votes/\(reply.key)/\(uid)")
            postRef.setValue(true)
        }
        reply.votes += countChange
        setNumVotes(reply.votes)
        setVote(reply.vote, animated: true)
    }
    
    @objc func handleDownvote() {
        guard let reply = reply else { return }
        guard let user = Auth.auth().currentUser else { return }
        
        if user.isAnonymous {
            mainProtocol.openLoginView()
            return
        }
        
        let uid = user.uid
        
        var countChange = 0
        if reply.vote == .downvoted {
            countChange += 1
            reply.vote = .notvoted
            
            let postRef = database.child("posts/votes/\(reply.key)/\(uid)")
            postRef.removeValue()
        } else {
            
            if reply.vote == .upvoted {
                countChange -= 1
            }
            
            countChange -= 1
            
            reply.vote = .downvoted
            
            let postRef = database.child("posts/votes/\(reply.key)/\(uid)")
            postRef.setValue(false)
        }
        reply.votes += countChange
        setNumVotes(reply.votes)
        setVote(reply.vote, animated: true)
    }
    
    var isAnimatingDownvote = false
    var isAnimatingUpVote = false
    
    func setVote(_ vote:Vote, animated:Bool) {
        guard let reply = reply else {return}
        switch vote {
        case .upvoted:
//            if animated && !isAnimatingUpVote {
//                isAnimatingUpVote = true
//                UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseOut], animations: {
//                    var frame = self.likeButton.view.frame
//                    frame.origin.y -= 16.0
//                    self.likeButton.view.frame = frame
//                }, completion: { _ in
//                    UIView.animate(withDuration: 0.50, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.6, options: [.curveEaseIn], animations: {
//                        var frame = self.likeButton.view.frame
//                        frame.origin.y += 16.0
//                        self.likeButton.view.frame = frame
//                    }, completion: { _ in
//                        self.isAnimatingUpVote = false
//                    })
//                })
//            }
            likeButton.imageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: reply.anon.color) ?? image
            }
            likeButton.imageNode.setNeedsDisplayWithCompletion(nil)
            dislikeButton.imageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: self.buttonColor) ?? image
            }
            dislikeButton.imageNode.setNeedsDisplayWithCompletion(nil)
            break
        case .downvoted:
//            if animated && !isAnimatingDownvote {
//                isAnimatingDownvote = true
//                UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
//                    var frame = self.dislikeButton.view.frame
//                    frame.origin.y += 10.0
//                    self.dislikeButton.view.frame = frame
//                }, completion: { _ in
//                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.6, options: [.curveEaseIn], animations: {
//                        var frame = self.dislikeButton.view.frame
//                        frame.origin.y -= 10.0
//                        self.dislikeButton.view.frame = frame
//                    }, completion: { _ in
//                        self.isAnimatingDownvote = false
//                    })
//                })
//            }
            likeButton.imageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: self.buttonColor) ?? image
            }
            likeButton.imageNode.setNeedsDisplayWithCompletion(nil)
            dislikeButton.imageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: reply.anon.color) ?? image
            }
            dislikeButton.imageNode.setNeedsDisplayWithCompletion(nil)
            break
        case .notvoted:
            likeButton.imageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: self.buttonColor) ?? image
            }
            likeButton.imageNode.setNeedsDisplayWithCompletion(nil)
            dislikeButton.imageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: self.buttonColor) ?? image
            }
            dislikeButton.imageNode.setNeedsDisplayWithCompletion(nil)
            break
        }
        
    }
    
    var votesColor = UIColor.gray
    func setNumVotes(_ votes:Int) {
        guard let post = self.post else { return }
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "\(post.votes)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: post.vote == .notvoted ? buttonColor : post.anon.color,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
        let labelWidth = UILabel.size(text: "\(post.votes)", height: 50.0, font: Fonts.semiBold(ofSize: 14.0)).width
        countLabel.style.width = ASDimension(unit: .points, value: labelWidth + 5.0)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    var voteRef:DatabaseReference?
    var metaRef:DatabaseReference?
    func listenToPost() {
        guard let reply = self.reply else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("listenToPost")
        voteRef = database.child("posts/votes/\(reply.key)/\(uid)")
        voteRef?.observe(.value, with: { snapshot in
            var vote = Vote.notvoted
            if let _vote = snapshot.value as? Bool {
                vote = _vote ? .upvoted : .downvoted
            }
            reply.vote = vote
            self.setVote(reply.vote, animated: false)
        }, withCancel: { error in
            reply.vote = .notvoted
            self.setVote(reply.vote, animated: false)
        })
        
        metaRef = database.child("posts/meta/\(reply.key)")
        metaRef?.keepSynced(true)
        metaRef?.observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String:Any],
                let votes = data["votes"] as? [String:Int] {
                reply.votes = votes["votesSum"] ?? 0
            } else {
                reply.votes = 0
            }
            self.setNumVotes(reply.votes)
        }, withCancel: { _ in
            reply.votes = 0
            self.setNumVotes(reply.votes)
        })
    }
    
    func stopListeningToPost() {
        print("stopListeningToPost")
        voteRef?.removeAllObservers()
        metaRef?.keepSynced(false)
        metaRef?.removeAllObservers()
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

