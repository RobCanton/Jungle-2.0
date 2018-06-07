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



extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}

class BlockedPostCellNode: ASDisplayNode {

    var titleNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var tapNode = ASTextNode()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        
        titleNode.attributedText = NSAttributedString(string: "Content Blocked", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0), NSAttributedStringKey.foregroundColor: UIColor.black])
        
        subtitleNode.attributedText = NSAttributedString(string: "Contains muted word(s).", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 15.0), NSAttributedStringKey.foregroundColor: UIColor.black])
        
        tapNode.attributedText = NSAttributedString(string: "Tap to change content settings", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 12.0), NSAttributedStringKey.foregroundColor: UIColor.black])
    }
}

class PostCellNode:ASCellNode {
    var postCellNode:PostContentCellNode!
    var isSinglePost = false
    required init(withPost post:Post, isSinglePost:Bool?=nil) {
        super.init()
        self.isSinglePost = isSinglePost ?? false
        automaticallyManagesSubnodes = true
        postCellNode = PostContentCellNode(withPost: post, isSinglePost: isSinglePost)
        
    }
    
    override func didLoad() {
        super.didLoad()
        selectionStyle = .none
        postCellNode.layer.cornerRadius = 4.0
        postCellNode.clipsToBounds = true
//        postCellNode.layer.borderColor = UIColor(white: 0.0, alpha: 0.01).cgColor
//        postCellNode.layer.borderWidth = 1.0
        view.clipsToBounds = false
        view.applyShadow(radius: 5.0, opacity: 0.35, offset: CGSize(width: 0, height: 5.0), color: hexColor(from: "acada4"), shouldRasterize: false)
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        if isSinglePost {
            let inset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: postCellNode)
            return inset
        }
        let inset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 10, 15, 10), child: postCellNode)
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
    var videoNode = ASVideoNode()
    
    let likeButton = ASButtonNode()
    let dislikeButton = ASButtonNode()
    let commentButton = ASButtonNode()
    let moreButtonNode = ASButtonNode()
    
    let groupNode = ASButtonNode()
    
    let countLabel = ASTextNode()
    var postImageNode = ASNetworkImageNode()
    
    //var transitionManager = LightboxViewerTransitionManager()
    weak var delegate:PostCellDelegate?
    
    var tagsCollectionNode = PostTagsCollectionNode()
    
    let gapNode = ASDisplayNode()
    var topCommentBox:CommentPreviewNode!
    
    static let mainInsets = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 0.0, right: 16.0)
    
    weak var post:Post?
    
    var isSinglePost = false

    private(set) var bgColor = UIColor.white
    private(set) var textColor = hexColor(from: "708078")
    private(set) var buttonColor = hexColor(from: "BEBEBE")
    private(set) var upvoteImage:UIImage!
    private(set) var upvotedImage:UIImage!
    private(set) var downvoteImage:UIImage!
    private(set) var downvotedImage:UIImage!
    private(set) var commentImage:UIImage!
    private(set) var moreImage:UIImage!
    
    var isKing = false
    
    required init(withPost post:Post,  isSinglePost:Bool?=nil) {
        super.init()
        self.post = post
        self.topCommentBox = CommentPreviewNode(reply: post.topComment, toPost: post)
        
        if isSinglePost != nil {
            self.isSinglePost = isSinglePost!
        }
        automaticallyManagesSubnodes = true
        
        upvoteImage = UIImage(named:"upvote")
        upvotedImage = UIImage(named:"upvoted")
        downvoteImage = UIImage(named:"downvote")
        downvotedImage = UIImage(named:"downvoted")
        commentImage = UIImage(named:"comment")
        moreImage = UIImage(named:"more")
        
        backgroundColor = UIColor.white
        
        imageNode.mainImageNode.backgroundColor = post.anon.color
        
        postImageNode.addTarget(self, action: #selector(handleImageTap), forControlEvents: .touchUpInside)
        postImageNode.isUserInteractionEnabled = true
        postImageNode.shouldCacheImage = true
        
        titleNode.attributedText = NSAttributedString(string: post.anon.displayName, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.black
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
            NSAttributedStringKey.font: Fonts.medium(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: UIColor(white: 0.5, alpha: 1.0)
            ])
    
        if post.isOffensive, !self.isSinglePost {
            postTextNode.setBlockedText()
            
            postTextNode.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            postTextNode.layer.cornerRadius = 4.0
            postTextNode.clipsToBounds = true
            postTextNode.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
            subtitleNode.alpha = 0.3
            imageNode.alpha = 0.3
            titleNode.alpha = 0.3
            subnameNode.alpha = 0.3
            likeButton.alpha = 0.3
            countLabel.alpha = 0.3
            dislikeButton.alpha = 0.3
            commentButton.alpha = 0.3
            moreButtonNode.alpha = 0.3
            
            postImageNode.style.height = ASDimension(unit: .points, value: 0.0)
            
        } else {
            
            likeButton.alpha = 1.0
            countLabel.alpha = 1.0
            dislikeButton.alpha = 1.0
            commentButton.alpha = 1.0
            moreButtonNode.alpha = 1.0
            
            var fontSize:CGFloat
            if self.isSinglePost {
                fontSize = 16.0
                postTextNode.maximumNumberOfLines = 0
                postTextNode.truncationMode = .byWordWrapping
            } else {
                fontSize = 16.0
                postTextNode.maximumNumberOfLines = 3
                postTextNode.truncationMode = .byWordWrapping
            }
            postTextNode.maximumNumberOfLines = 0
            postTextNode.truncationMode = .byWordWrapping
            
            
            postTextNode.setText(text: post.textClean, withSize: fontSize, normalColor: UIColor.black, activeColor: accentColor)
            postTextNode.tapHandler = { type, textValue in
                print("ACTIVE TEXT TAPPED")
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
            
            postImageNode.backgroundColor = buttonColor
            if let attachments = post.attachments {
                print("WEVE GOT ATTACHMENTS")
                if let images = attachments.images, images.count > 0 {
                    print("BUT WE HAVE NO IMAGES")
                    let image = images[0]
                    postImageNode.url = image.url
                    let imageWidth = UIScreen.main.bounds.width - 20
                    let imageHeight = imageWidth / image.ratio
                    let minImageHeight = min(imageHeight, imageWidth)
                    postImageNode.style.height = ASDimension(unit: .points, value: minImageHeight)
                } else if let video = attachments.video {
                    UploadService.retrieveVideo(withKey: post.key, url: video.url) { vidURL, fromFile in
                        if let url = vidURL {
                            let videoHeight = UIScreen.main.bounds.width / video.ratio
                            self.videoNode.style.height = ASDimension(unit: .points, value: videoHeight)
                            DispatchQueue.main.async {
                                
                                self.videoNode.shouldAutoplay = true
                                self.videoNode.shouldAutorepeat = true
                                self.videoNode.asset = AVAsset(url: url)
                                self.videoNode.play()
                                
                                self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                            }
                            
                        } else{
                            print("NO VIDEO DATA")
                        }
                    }
                }
            } else {
                postImageNode.style.height = ASDimension(unit: .points, value: 0.0)
            }
        }

        
        dividerNode.backgroundColor = textColor.withAlphaComponent(0.25)
        
        setNumVotes()
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
        setComments(count: post.numReplies)
        
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
        tagsCollectionNode.delegate = self
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
        contentStack.spacing = 10.0
        
        var textInset:ASInsetLayoutSpec!
        if isSinglePost {
            textInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(10, 12, 0, 12), child: postTextNode)
        } else {
            contentStack.children?.append(imageInset)
            textInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 12, 0, 12), child: postTextNode)
        }
        
        if let attachments = post?.attachments {
            if let images = attachments.images, images.count > 0 {
                contentStack.children?.append(postImageNode)
            } else if let _ = attachments.video {
                contentStack.children?.append(videoNode)
            }
        }
        
        if let text = post?.text, !text.isEmpty {
            contentStack.children?.append(textInset)
        }
        
        if !isSinglePost, post?.topComment != nil {
            let dividerInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 12, 0, 12), child: dividerNode)
            contentStack.children?.append(dividerInset)
            contentStack.children?.append(topCommentBox)
        }
        
        let actionsInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 12, 12, 12), child: actionsRow)
        contentStack.children?.append(actionsInset)
        return contentStack
    }

    func setComments(count:Int) {
        let countStr = "\(count)"
        let str = NSMutableAttributedString(string: "\(countStr)", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: buttonColor
            ])
        commentButton.setAttributedTitle(str, for: .normal)
    }

    
    @objc func handleUpvote() {
        guard let post = post else { return }
        guard let user = Auth.auth().currentUser else { return }
        
        if user.isAnonymous {
            mainProtocol.openLoginView()
            return
        }
        
        let uid = user.uid
        
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
        print("COUNT CHANGE!: \(countChange)")
        post.votes += countChange
        setNumVotes()
        setVote(post.vote, animated: true)
    }
    
    @objc func handleDownvote() {
        guard let post = post else { return }
        guard let user = Auth.auth().currentUser else { return }
        
        if user.isAnonymous {
            mainProtocol.openLoginView()
            return
        }
        
        let uid = user.uid
        
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
        setNumVotes()
        setVote(post.vote, animated: true)
    }
    
    var isAnimatingDownvote = false
    var isAnimatingUpVote = false
    
    func setVote(_ vote:Vote, animated:Bool) {
        guard let post = self.post else { return }
        switch vote {
        case .upvoted:
//            if animated && !isAnimatingUpVote {
//                isAnimatingUpVote = true
//                //likeButton.isUserInteractionEnabled = false
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
//                        //self.likeButton.isUserInteractionEnabled = true
//                    })
//                })
//            }
            likeButton.imageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: post.anon.color) ?? image
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
//                //self.dislikeButton.isUserInteractionEnabled = false
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
//                        //self.dislikeButton.isUserInteractionEnabled = true
//                    })
//                })
//            }
            likeButton.imageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: self.buttonColor) ?? image
            }
            likeButton.imageNode.setNeedsDisplayWithCompletion(nil)
            dislikeButton.imageNode.imageModificationBlock = { image in
                return image.maskWithColor(color: post.anon.color) ?? image
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
            self.setNumVotes()
        }, withCancel: { _ in
            post.votes = 0
            self.setNumVotes()
        })
    }
    
    func setNumVotes() {
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
//        
//        
//        let lightBoxVC = LightboxViewController()
//        lightBoxVC.post = post
//        
//        
//        //transitionManager.sourceDelegate = self
//        //transitionManager.destinationDelegate = lightBoxVC
//        //lightBoxVC.transitioningDelegate = transitionManager
//        parentVC.present(lightBoxVC, animated: true, completion: nil)
        
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

extension PostContentCellNode: TagsCollectionDelegate {
    func postOpen(tag: String) {
        delegate?.postOpen(tag: tag)
    }
}
