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
    var post:Post?
    required init(post: Post) {
        super.init()
        self.post = post
        automaticallyManagesSubnodes = true
        
        if let videoURL = post.attachments?.video?.url {
            UploadService.retrieveVideo(withKey: post.key, url: videoURL) { vidURL, fromFile in
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
        
        spinnerNode.activityIndicatorView.activityIndicatorViewStyle = .white
        spinnerNode.startAnimating()
        //gradientNode.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spinnerCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: spinnerNode)
        let spinnerBG = ASBackgroundLayoutSpec(child: videoNode, background: spinnerCenter)
        let overlay = ASOverlayLayoutSpec(child: spinnerBG, overlay: gradientNode)
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
