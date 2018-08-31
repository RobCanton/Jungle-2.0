//
//  PostVideoNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-08.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Pastel

class PostContentNode:ASDisplayNode {
    var pastelNode:PastelNode!
    var avatarNode:AvatarNode!
    var usernameNode = ASTextNode()
    var imageNode = ASNetworkImageNode()
    var videoNode = ASVideoNode()
    var textNode = ActiveTextNode()
    var subnameNode = ASTextNode()
    var timeNode = ASTextNode()
    var gradientNode = ASDisplayNode()
    var spinnerNode = SpinnerNode()
    weak var post:Post?
    var blurNode:BlurNode?
    
    var blockedMessageNode:ASDisplayNode?
    var blockedIconNode:ASImageNode?
    var blockedTitleNode:ASTextNode?
    var blockedButtonNode:ASButtonNode?
    required init(post: Post) {
        super.init()
        self.post = post
        pastelNode = PastelNode(gradient: post.gradient)
        automaticallyManagesSubnodes = true
        videoNode.backgroundColor = UIColor.black
        imageNode.backgroundColor = UIColor.black
        
        textNode.isUserInteractionEnabled = true
        
        avatarNode = AvatarNode(post: post, cornerRadius: 22, imageInset: 6)
        avatarNode.style.height = ASDimension(unit: .points, value: 44)
        avatarNode.style.width = ASDimension(unit: .points, value: 44)
        
        subnameNode.isHidden = true
        
        if let profile = post.profile {
            usernameNode.attributedText = NSAttributedString(string: profile.username , attributes: [
                NSAttributedStringKey.font: Fonts.bold(ofSize: 18.0),
                NSAttributedStringKey.foregroundColor: UIColor.white
                ])
        } else {
            usernameNode.attributedText = NSAttributedString(string: post.anon.displayName , attributes: [
                NSAttributedStringKey.font: Fonts.bold(ofSize: 18.0),
                NSAttributedStringKey.foregroundColor: UIColor.white
                ])
            
            if post.isYou {
                subnameNode.isHidden = false
                subnameNode.attributedText = NSAttributedString(string: "YOU", attributes: [
                    NSAttributedStringKey.font: Fonts.semiBold(ofSize: 10.0),
                    NSAttributedStringKey.foregroundColor: post.anon.color
                    ])
                subnameNode.textContainerInset = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)
                subnameNode.backgroundColor = UIColor.white
            }
        }
        
        
        
        timeNode.attributedText = NSAttributedString(string: "1h ago" , attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        
        subnameNode.isHidden = true
        timeNode.isHidden = true
        
        
        if let _ = post.blockedMessage {
            videoNode.muted = true
            videoNode.isHidden = true
            
            usernameNode.isHidden = true
            avatarNode.isHidden = true
            spinnerNode.alpha = 0.0
            blockedMessageNode = ASDisplayNode()
            backgroundColor = .clear
            blockedIconNode = ASImageNode()
            blockedIconNode?.image = UIImage(named:"danger")
            blockedIconNode?.imageModificationBlock = { image in
                return image.maskWithColor(color: UIColor.white) ?? image
            }
            
            blockedTitleNode = ASTextNode()
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            blockedTitleNode?.attributedText = NSAttributedString(string: "Content Hidden", attributes: [
                NSAttributedStringKey.paragraphStyle: paragraphStyle,
                NSAttributedStringKey.font: Fonts.medium(ofSize: 16.0),
                NSAttributedStringKey.foregroundColor: UIColor.white
            ])
            blockedButtonNode = ASButtonNode()
            blockedButtonNode?.setTitle("Show Anyways", with: Fonts.semiBold(ofSize: 14.0), with: UIColor.gray, for: .normal)
            
            blockedMessageNode?.automaticallyManagesSubnodes = true
            blockedMessageNode?.layoutSpecBlock = { _, _ in
                let iconCenterXY = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: self.blockedIconNode!)
                let vStack = ASStackLayoutSpec.vertical()
                vStack.spacing = 8.0
                vStack.children = [iconCenterXY, self.blockedTitleNode!, self.blockedButtonNode!]
                return vStack
            }
            
        } else {
            setup()
        }
        
        
    }
    
    func setup() {
        guard let post = self.post else { return }
        if post.attachments.isVideo {
            setupVideo(post)
        } else if post.attachments.isImage {
            setupImage(post)
        } else {
            setupText(post)
        }
    }
    
    func setupText(_ post:Post) {
        usernameNode.isHidden = false
        avatarNode.isHidden = false
        spinnerNode.stopAnimating()
        spinnerNode.alpha = 0.0
        imageNode.isHidden = true
        videoNode.isHidden = true
        subnameNode.isHidden = false
        timeNode.isHidden = false
        //backgroundColor = accentColor
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        textNode.textContainerInset = UIEdgeInsetsMake(16,24,16,24)
        textNode.setText(text: post.text, withSize: 24.0, normalColor: .white, activeColor: UIColor.white.withAlphaComponent(0.67))
    }
    
    func setupVideo(_ post:Post) {
        
        usernameNode.isHidden = true
        avatarNode.isHidden = true
        videoNode.isHidden = false
        videoNode.muted = false
        spinnerNode.isHidden = false
        imageNode.isHidden = true
        UploadService.retrieveVideo(withKey: post.key) { vidURL, fromFile in
            if let url = vidURL {
                DispatchQueue.main.async {
                    
                    self.videoNode.shouldAutoplay = true
                    self.videoNode.shouldAutorepeat = true
                    self.videoNode.muted = false
                    
                    self.videoNode.asset = AVAsset(url: url)
                    self.videoNode.play()
                    
                    self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                }
                
            }
        }
    }
    
    func setupImage(_ post:Post) {
        usernameNode.isHidden = true
        avatarNode.isHidden = true
        videoNode.isHidden = true
        videoNode.muted = true
        imageNode.isHidden = false
        spinnerNode.isHidden = false
        
        UploadService.retrieveImage(withKey: post.key) { image, _ in
            self.imageNode.image = image
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        subnameNode.layer.cornerRadius = 2.0
        subnameNode.clipsToBounds = true
        
        let gradient = CAGradientLayer()
        gradient.frame = UIScreen.main.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor(white: 0.0, alpha: 0.35).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientNode.view.layer.addSublayer(gradient)
        gradientNode.isUserInteractionEnabled = false
        gradientNode.view.isUserInteractionEnabled = false
        spinnerNode.activityIndicatorView.activityIndicatorViewStyle = .white
        spinnerNode.startAnimating()
    

    }
    
    func temporaryUnblock() {
        guard let post = self.post else { return }
        self.blockedMessageNode?.isHidden = true
        self.spinnerNode.alpha = 1.0
        self.setup()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spinnerCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: spinnerNode)
        let pastelOverlay = ASOverlayLayoutSpec(child: pastelNode, overlay: imageNode)
        let videoImageOverlay = ASOverlayLayoutSpec(child: pastelOverlay, overlay: videoNode)
        
        let subnameCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: subnameNode)
        let usernameStack = ASStackLayoutSpec.horizontal()
        usernameStack.children = [usernameNode, subnameCenter]
        usernameStack.spacing = 8.0
        
        let nameStack = ASStackLayoutSpec.vertical()
        nameStack.children = [usernameStack, timeNode]
        nameStack.spacing = 2.0
        
        let titleStack = ASStackLayoutSpec.horizontal()
        titleStack.children = [avatarNode, nameStack ]
        titleStack.spacing = 10
        titleStack.style.width = ASDimension(unit: .points, value: constrainedSize.max.width - 48)
        let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 24, 0, 24), child: titleStack)
        textNode.style.maxHeight = ASDimension(unit: .points, value: constrainedSize.max.height - 64 - 44 - 44)
        let textStack = ASStackLayoutSpec.vertical()
        textStack.children = [titleInset, textNode]
        textStack.spacing = 0.0
        
        let centerText = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: textStack)
        
        let textOverlay = ASOverlayLayoutSpec(child: videoImageOverlay, overlay: centerText)
        let spinnerBG = ASBackgroundLayoutSpec(child: textOverlay, background: spinnerCenter)
        let overlay = ASOverlayLayoutSpec(child: spinnerBG, overlay: gradientNode)
        if blockedMessageNode != nil {
            let blockedMessageNodeCenterXY = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: blockedMessageNode!)
            return ASOverlayLayoutSpec(child: overlay, overlay: blockedMessageNodeCenterXY)
        }
        return overlay
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        print("RXC: didEnterVisibleState")
        spinnerNode.startAnimating()
        guard let post = self.post else { return }
        if videoNode.asset != nil {
            self.videoNode.play()
        }
        pastelNode.animate()
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        print("RXC: didExitVisibleState")
        self.videoNode.pause()
        spinnerNode.stopAnimating()
        //videoNode.player?.replaceCurrentItem(with: nil)
        //videoNode.
        //pastelNode.pastelView.layer.speed = 0.0
    }
    
}
