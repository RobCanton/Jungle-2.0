//
//  GroupCardView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-05.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Koloda

class GroupCardView:UIView {
    
    var imageNode:ASNetworkImageNode!
    var titleLabel:UILabel!
    var bottomBar:UIView!
    var blurView:UIVisualEffectView!
    var descLabel:UILabel!
    var infoLabel:UILabel!
    var dimView:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.preservesSuperviewLayoutMargins = false
        self.insetsLayoutMarginsFromSafeArea = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
        self.layer.cornerRadius = 12.0
        self.clipsToBounds = true
        
        imageNode = ASNetworkImageNode()
        let imageView = imageNode.view
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        self.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dimView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        bottomBar = UIView()
        bottomBar.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        bottomBar.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.topAnchor.constraint(equalTo: bottomBar.topAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor).isActive = true
        
        infoLabel = UILabel()
        infoLabel.font = Fonts.semiBold(ofSize: 14.0)
        infoLabel.textColor = UIColor.white
        infoLabel.numberOfLines = 1
        
        bottomBar.addSubview(infoLabel)
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 16).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16).isActive = true
        
        descLabel = UILabel()
        descLabel.font = Fonts.light(ofSize: 16.0)
        descLabel.textColor = UIColor.white
        descLabel.numberOfLines = 3
        
        bottomBar.addSubview(descLabel)
        
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8).isActive = true
        descLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16).isActive = true
        descLabel.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -16).isActive = true
        descLabel.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16).isActive = true
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        //titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 3
        titleLabel.font = Fonts.extraBold(ofSize: 32)
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: -16).isActive = true
    }
    
    func setup(withGroup group:Group) {
        imageNode.url = group.avatar_low
        titleLabel.text = group.name
        descLabel.text = group.desc
        
        var membersStr:String
        if group.numMembers == 1 {
            membersStr = "1 member"
        } else {
            membersStr = "\(group.numMembers) members"
        }
        
        var postsStr:String
        if group.numPosts == 1 {
            postsStr = "1 post"
        } else {
            postsStr = "\(group.numPosts) posts"
        }
        
        infoLabel.text = "\(membersStr)   \(postsStr)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

import Koloda

class CardOverlayView: OverlayView {
    
    var imageView:UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        imageView = UIImageView(frame: bounds)
        imageView.image = nil
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                imageView.image = UIImage(named:"SkipOverlay")
                backgroundColor = UIColor.black.withAlphaComponent(0.5)
            case .right? :
                imageView.image = UIImage(named:"JoinOverlay")
                backgroundColor = accentColor.withAlphaComponent(0.5)
            default:
                imageView.image = nil
                backgroundColor = UIColor.clear
            }
        }
    }
}


