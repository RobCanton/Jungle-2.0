//
//  SinglePostCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-04.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class PostContentNode:ASDisplayNode {
    var videoNode = ASVideoNode()
    var gradientNode = ASDisplayNode()
    var post:Post?
    required init(post: Post) {
        super.init()
        self.post = post
        automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        super.didLoad()
        let gradient = CAGradientLayer()
        gradient.frame = UIScreen.main.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor(white: 0.0, alpha: 0.2).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientNode.view.layer.addSublayer(gradient)
        //gradientNode.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let overlay = ASOverlayLayoutSpec(child: videoNode, overlay: gradientNode)
        return overlay
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        guard let post = self.post else { return }
        if let videoURL = post.attachments?.video?.url {
            UploadService.retrieveVideo(withKey: post.key, url: videoURL) { vidURL, fromFile in
                if let url = vidURL {
                    print("WE GOT THE VIDEO DATA")
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
        
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        videoNode.player?.replaceCurrentItem(with: nil)
        //videoNode.
    }
}

class ContentOverlayNode:ASControlNode {
    
    var postTextNode = ASTextNode()
    var avatarNode = ASNetworkImageNode()
    var usernameNode = ASTextNode()
    
    required init(post:Post) {
        super.init()
        automaticallyManagesSubnodes = true
        postTextNode.maximumNumberOfLines = 3
        postTextNode.attributedText = NSAttributedString(string: post.textClean, attributes: [
            NSAttributedStringKey.font: Fonts.light(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        
        usernameNode.attributedText = NSAttributedString(string: "KANYEWEST" , attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        
        avatarNode.style.height = ASDimension(unit: .points, value: 24.0)
        avatarNode.style.width = ASDimension(unit: .points, value: 24.0)
        
        avatarNode.layer.cornerRadius = 12.0
        avatarNode.clipsToBounds = true
        avatarNode.backgroundColor = UIColor.white
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let centerUsername = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: usernameNode)
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.children = [avatarNode, centerUsername]
        titleStack.spacing = 8.0
        
        let contentStack = ASStackLayoutSpec.vertical()
        contentStack.children = [titleStack, postTextNode]
        contentStack.spacing = 6.0
        
        let mainInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        return ASInsetLayoutSpec(insets: mainInsets, child: contentStack)
    }
}

protocol SinglePostDelegate:class {
    func openComments(_ post:Post)
}

class SinglePostCellNode: ASCellNode, ASTableDelegate, ASTableDataSource {
    
    var contentNode:PostContentNode!
    var contentOverlay:ContentOverlayNode!
    weak var delegate:SinglePostDelegate?
    var post:Post?
    required init(post:Post) {
        super.init()
        self.post = post
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor.black
        contentNode = PostContentNode(post: post)
        contentOverlay = ContentOverlayNode(post: post)
        
        contentOverlay.addTarget(self, action: #selector(handleOverlayTap), forControlEvents: .touchUpInside)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let overlayStack = ASStackLayoutSpec.vertical()
        overlayStack.children = [contentOverlay]
        overlayStack.alignContent = .end
        overlayStack.justifyContent = .end
        
        let overlay = ASOverlayLayoutSpec(child: contentNode, overlay: overlayStack)
        return ASInsetLayoutSpec(insets: .zero, child: overlay)
    }
    
    @objc func handleOverlayTap() {
        guard let post = self.post else { return }
        delegate?.openComments(post)
    }
    
    
}
