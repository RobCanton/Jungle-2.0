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

class PostContentNode:ASDisplayNode {
    var videoNode = ASVideoNode()
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
        automaticallyManagesSubnodes = true
        if let _ = post.blockedMessage {
            videoNode.muted = true
            videoNode.isHidden = true
            spinnerNode.alpha = 0.0
            blockedMessageNode = ASDisplayNode()
            
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
            setupVideo(post)
        }
    }
    
    func setupVideo(_ post:Post) {
        videoNode.isHidden = false
        videoNode.muted = false
        spinnerNode.isHidden = false
        
        
        UploadService.retrieveVideo(withKey: post.key) { vidURL, fromFile in
            if let url = vidURL {
                print("WE GOT THE VIDEO DATA")
                DispatchQueue.main.async {
                    
                    self.videoNode.shouldAutoplay = true
                    self.videoNode.shouldAutorepeat = true
                    self.videoNode.muted = false
                    
                    self.videoNode.asset = AVAsset(url: url)
                    self.videoNode.play()
                    
                    self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                }
                
            } else{
                print("NO VIDEO DATA")
            }
        }
        
    }
    
    override func didLoad() {
        super.didLoad()
        let gradient = CAGradientLayer()
        gradient.frame = UIScreen.main.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor(white: 0.0, alpha: 0.25).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientNode.view.layer.addSublayer(gradient)
        
        spinnerNode.activityIndicatorView.activityIndicatorViewStyle = .white
        spinnerNode.startAnimating()
    }
    
    func temporaryUnblock() {
        guard let post = self.post else { return }
        self.blockedMessageNode?.isHidden = true
        self.spinnerNode.alpha = 1.0
        self.setupVideo(post)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spinnerCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: spinnerNode)
        let spinnerBG = ASBackgroundLayoutSpec(child: videoNode, background: spinnerCenter)
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
        
        
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        print("RXC: didExitVisibleState")
        self.videoNode.pause()
        spinnerNode.stopAnimating()
        //videoNode.player?.replaceCurrentItem(with: nil)
        //videoNode.
    }
}
