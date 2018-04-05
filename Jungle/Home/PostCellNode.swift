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
    var postCellNode:PostContentCellNode!
    
    required init(withPost post:Post, type: PostsTableType, isSinglePost:Bool?=nil) {
        super.init()
        backgroundColor = UIColor.clear//hexColor(from: "E8EBE0")
        automaticallyManagesSubnodes = true
        postCellNode = PostContentCellNode(withPost: post, type: type, isSinglePost: isSinglePost)
        
    }
    
    override func didLoad() {
        super.didLoad()
        selectionStyle = .none
        postCellNode.layer.cornerRadius = 8.0
        postCellNode.clipsToBounds = true
        view.clipsToBounds = false
        view.applyShadow(radius: 8.0, opacity: 0.25, offset: CGSize(width: 0, height: 6.0), color: hexColor(from: "#617660"), shouldRasterize: false)
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let inset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0.0, 8.0, 12.0, 8.0), child: postCellNode)
        return inset
    }
    
    func setHighlighted(_ highlighted:Bool) {
        print("setHighlighted: \(highlighted)")
        postCellNode.alpha = highlighted ? 0.67 : 1.0
    }
    
    func setSelected(_ selected:Bool) {
        print("setSelected: \(selected)")
        postCellNode.alpha = selected ? 0.67 : 1.0
    }
}

class PostContentCellNode:ASDisplayNode {
    
    let gradientColorTop = accentColor
    let gradientColorBot = hexColor(from: "#22D29F")
    
    var imageNode = ASRoundShadowedImageNode(imageCornerRadius: 16.0, imageShadowRadius: 0.0)
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
    var postImageNode = ASNetworkImageNode()
    
    var transitionManager = LightboxViewerTransitionManager()
    weak var delegate:PostCellDelegate?
    
    var tagsCollectionNode = PostTagsCollectionNode()
    
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
        
        backgroundColor = post.anon.color//UIColor.white
        
        imageNode.mainImageNode.backgroundColor = UIColor.white.withAlphaComponent(0.5)//post.anon.color
        
        postImageNode.addTarget(self, action: #selector(handleImageTap), forControlEvents: .touchUpInside)
        postImageNode.isUserInteractionEnabled = true
        
        titleNode.attributedText = NSAttributedString(string: post.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.white//post.anon.color
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
            NSAttributedStringKey.foregroundColor: post.anon.color//UIColor.white
            ])
        subnameNode.textContainerInset = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 0, right: 4.0)
        subnameNode.backgroundColor = UIColor.white//post.anon.color
        
        var locationStr = ""
        if let location = post.location {
            locationStr = " · \(location.locationStr)"
        }
        
        let subtitleStr = "\(post.createdAt.timeSinceNow())\(locationStr)"
        
        subtitleNode.attributedText = NSAttributedString(string: subtitleStr, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.75)//textColor
            ])
        
        postTextNode.maximumNumberOfLines = 0
        postTextNode.truncationMode = .byWordWrapping
        
        let fontSize:CGFloat = self.isSinglePost ? 18.0 : 16.0
        
        postTextNode.setText(text: post.textClean, withSize: fontSize, normalColor: UIColor.white, activeColor: accentColor)
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
        countLabel.attributedText = NSAttributedString(string: "\(post.votes)", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
        
        
        if let attachments = post.attachments {
            if attachments.images.count > 0 {
                let image = attachments.images[0]
                let color =  hexColor(from: image.colorHex)
                postImageNode.backgroundColor = color
                postImageNode.url = image.url
                postImageNode.style.height = ASDimension(unit: .points, value: UIScreen.main.bounds.width)
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
        
        commentButton.laysOutHorizontally = true
        commentButton.contentSpacing = 2.0
        commentButton.contentHorizontalAlignment = .middle

        likeButton.addTarget(self, action: #selector(handleUpvote), forControlEvents: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(handleDownvote), forControlEvents: .touchUpInside)
        
        moreButtonNode.setImage(moreImage, for: .normal)
        moreButtonNode.addTarget(self, action: #selector(handleMoreButton), forControlEvents: .touchUpInside)
        moreButtonNode.contentHorizontalAlignment = .right
        
        let textFont = Fonts.regular(ofSize: 12.0)
        
        let maxWidth = UIScreen.main.bounds.width - 48.0
        var numLines:Int = post.tags.count > 0 ? 1 : 0
        var currentWidth:CGFloat = 0
        for tag in post.tags {
            
            let textWidth = UILabel.size(text: tag, height: 24.0, font: textFont).width + 12
            if currentWidth + textWidth < maxWidth {
                currentWidth += textWidth
            } else {
                numLines += 1
                currentWidth = 0
            }
        }
        
        var gaps:CGFloat = 0
        if numLines > 0 {
            gaps = CGFloat(numLines - 1) * 8.0
        }
        let tagsHeight = gaps + CGFloat(numLines) * 24.0
        tagsCollectionNode.style.height = ASDimension(unit: .points, value: tagsHeight)
        tagsCollectionNode.tags = post.tags
        
    }
    
    override func didLoad() {
        super.didLoad()
        subnameNode.layer.cornerRadius = 4
        subnameNode.clipsToBounds = true
        //selectionStyle = .none
        
        imageNode.addTarget(self, action: #selector(handleImageTap), forControlEvents: .touchUpInside)
        imageNode.isUserInteractionEnabled = true
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        imageNode.style.width = ASDimension(unit: .points, value: 32.0)
        imageNode.style.height = ASDimension(unit: .points, value: 32.0)
        
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
        
        subnameNode.style.height = ASDimension(unit: .points, value: 16.0)
        
        let nameStack = ASStackLayoutSpec.vertical()
        nameStack.spacing = 1.0
        nameStack.children = [hTitleStack, subtitleNode]
        
        let imageStack = ASStackLayoutSpec.horizontal()
        imageStack.children = [imageNode, nameStack]
        imageStack.spacing = 10.0
        
        let imageInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(12, 12, 0, 12), child: imageStack)
        
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
        contentStack.children = [imageInset]
        contentStack.spacing = 10.0
        
        let textInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 12, 0, 12), child: postTextNode)
            
        if let text = post?.text, !text.isEmpty {
            contentStack.children?.append(textInset)
        }
        
        if let attachments = post? .attachments {
            if attachments.images.count > 0 {
                contentStack.children?.append(postImageNode)
            }
        }
        if let tags = post?.tags, tags.count > 0 {
            contentStack.children?.append(tagsCollectionNode)
        }
        
        let actionsInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 12, 12, 12), child: actionsRow)
        contentStack.children?.append(actionsInset)
        return contentStack
    }

    func setComments(count:Int) {
        let countStr = "\(count)"
        let str = NSMutableAttributedString(string: "\(countStr) Replies", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
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
            let postRef = database.child("posts/votes/\(post.key)/\(uid)")
            postRef.removeValue()
        } else {
            if post.vote == .downvoted {
                countChange += 1
            }
            
            countChange += 1
            post.vote = .upvoted
            let postRef = database.child("posts/votes/\(post.key)/\(uid)")
            postRef.setValue(true)
        }
        post.votes += countChange
        setNumVotes(post.votes)
        setVote(post.vote, animated: true)
    }
    
    @objc func handleDownvote() {
        guard let post = post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var countChange = 0
        if post.vote == .downvoted {
            countChange += 1
            post.vote = .notvoted
            
            let postRef = database.child("posts/votes/\(post.key)/\(uid)")
            postRef.removeValue()
        } else {
            
            if post.vote == .upvoted {
                countChange -= 1
            }
            
            countChange -= 1
            
            post.vote = .downvoted
            
            let postRef = database.child("posts/votes/\(post.key)/\(uid)")
            postRef.setValue(false)
        }
        post.votes += countChange
        setNumVotes(post.votes)
        setVote(post.vote, animated: true)
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
    
    var voteRef:DatabaseReference?
    var metaRef:DatabaseReference?
    func listenToPost() {
        guard let post = self.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("listenToPost")
        voteRef = database.child("posts/votes/\(post.key)/\(uid)")
        voteRef?.observe(.value, with: { snapshot in
            var vote = Vote.notvoted
            if let _vote = snapshot.value as? Bool {
                vote = _vote ? .upvoted : .downvoted
            }
            post.vote = vote
            self.setVote(post.vote, animated: false)
        }, withCancel: { error in
            post.vote = .notvoted
            self.setVote(post.vote, animated: false)
        })
        
        metaRef = database.child("posts/meta/\(post.key)")
        metaRef?.keepSynced(true)
        metaRef?.observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String:Any],
                let votes = data["votes"] as? [String:Int] {
                post.votes = votes["votesSum"] ?? 0
            } else {
                post.votes = 0
            }
            self.setNumVotes(post.votes)
        }, withCancel: { _ in
            post.votes = 0
            self.setNumVotes(post.votes)
        })
    }
    
    func setNumVotes(_ votes:Int) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        countLabel.attributedText = NSAttributedString(string: "\(votes)", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.paragraphStyle: paragraph
            ])
    }
    
    func stopListeningToPost() {
        print("stopListeningToPost")
        voteRef?.removeAllObservers()
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
    
}

extension PostContentCellNode: LightboxTransitionSourceDelegate {
    func transitionWillBegin(_ isPresenting: Bool) {
        postImageNode.alpha = 0.0
    }
    
    func transitionDidEnd(_ isPresenting: Bool) {
        postImageNode.alpha = 1.0
    }
    
    func transitionSourceImage() -> UIImage? {
        
        return postImageNode.image
    }
    
    func transitionSourceURL() -> URL? {
        return post?.attachments?.images[0].url
    }
    
    func transitionSourceFrame(_ parentView: UIView) -> CGRect {
        let frame = view.convert(postImageNode.view.frame, to: parentView)

        return frame
    }
    
    
}
