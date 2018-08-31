//
//  UserProfileHeaderView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-08-13.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Pastel

class UserProfileHeaderView:UIView {
    
    var pastelView:PastelView!
    
    var avatarView:UIView!
    var avatarImageView:ASNetworkImageNode!
    var usernameButton:UIButton!
    
    var tabScrollView:DualScrollView!
    var titleView:JTitleView!
    var contentView:UIView!
    init(frame:CGRect, topInset:CGFloat) {
        super.init(frame: frame)
        self.preservesSuperviewLayoutMargins = false
        self.insetsLayoutMarginsFromSafeArea = false
        
        pastelView = PastelView(frame: bounds)
        pastelView.startPastelPoint = .topRight
        pastelView.endPastelPoint = .bottomLeft
        
        // Custom Duration
        pastelView.animationDuration = 10
        
        //pastelView.isUserInteractionEnabled = false
        addSubview(pastelView)
        pastelView.translatesAutoresizingMaskIntoConstraints = false
        pastelView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        pastelView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        pastelView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        pastelView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true

        let scrollTabBar = UIView()
        addSubview(scrollTabBar)
        scrollTabBar.translatesAutoresizingMaskIntoConstraints = false
        scrollTabBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollTabBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        scrollTabBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        scrollTabBar.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        tabScrollView = DualScrollView(frame: CGRect(x: 0, y: 0, width: bounds.width - 104, height: 32), title1: "POSTS", title2: "COMMENTS")
        scrollTabBar.addSubview(tabScrollView)
        tabScrollView.translatesAutoresizingMaskIntoConstraints = false
        tabScrollView.leadingAnchor.constraint(equalTo: scrollTabBar.leadingAnchor, constant: 52.0).isActive = true
        tabScrollView.trailingAnchor.constraint(equalTo: scrollTabBar.trailingAnchor, constant: -52.0).isActive = true
        tabScrollView.topAnchor.constraint(equalTo: scrollTabBar.topAnchor).isActive = true
        tabScrollView.bottomAnchor.constraint(equalTo: scrollTabBar.bottomAnchor).isActive = true
        
        contentView = UIView()
        addSubview(contentView)
        //contentView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: tabScrollView.topAnchor).isActive = true
        
        
        avatarView = UIView()
        avatarView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        contentView.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        avatarView.widthAnchor.constraint(equalToConstant: 96).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        
        avatarView.layer.cornerRadius = 96/2
        avatarView.clipsToBounds = true

        avatarImageView = ASNetworkImageNode()
        
        avatarView.addSubview(avatarImageView.view)
        avatarImageView.view.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.view.leadingAnchor.constraint(equalTo: avatarView.leadingAnchor).isActive = true
        avatarImageView.view.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor).isActive = true
        avatarImageView.view.topAnchor.constraint(equalTo: avatarView.topAnchor).isActive = true
        avatarImageView.view.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor).isActive = true

        usernameButton = UIButton(type: .custom)
        usernameButton.setTitle(nil, for: .normal)
        usernameButton.setTitleColor(UIColor.white, for: .normal)
        usernameButton.titleLabel?.font = Fonts.bold(ofSize: 16.0)

        contentView.addSubview(usernameButton)
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 0).isActive = true
        usernameButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        //usernameLabel.sizeToFit()
        usernameButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        usernameButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        self.layoutIfNeeded()
        
        titleView = JTitleView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 50), topInset: topInset)
        addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        titleView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 50 + topInset).isActive = true
        titleView.leftButton.setImage(UIImage(named:"back"), for: .normal)
        titleView.rightButton.setImage(UIImage(named:"more_white"), for: .normal)
        titleView.titleLabel.text = nil
        titleView.titleLabel.font = Fonts.semiBold(ofSize: 14.0)
        titleView.titleLabel.alpha = 0.0
        titleView.backgroundImage.isHidden = true
        titleView.backgroundColor = UIColor.clear
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        
        let startPercent = NSNumber(value: Float(topInset / UIScreen.main.bounds.height))
        let endPercent = NSNumber(value: Float((topInset + 12) / UIScreen.main.bounds.height))
        
        gradient.locations = [startPercent, endPercent]
        gradient.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: UIScreen.main.bounds.height)
        contentView.layer.mask = gradient
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setProfile(_ profile:Profile?) {
        
        if let profile = profile {
            avatarView.backgroundColor = tertiaryColor
            avatarImageView.image = nil
            UserService.retrieveUserImage(uid: profile.uid, .high) { image, _ in
                self.avatarImageView.image = image
            }
            usernameButton.setTitle(profile.username, for: .normal)
            usernameButton.alpha = 1.0
            usernameButton.clipsToBounds = true
            var colors = [UIColor]()
            for hex in profile.gradient {
                colors.append(hexColor(from:hex))
            }
            pastelView.setColors(colors)
            pastelView.startStatic()
        } else {
            avatarView.backgroundColor = hexColor(from: "#005B51")
            avatarImageView.url = nil
            avatarImageView.image = UIImage(named:"anon_switch_on_large")
            usernameButton.setTitle("ANONYMOUS", for: .normal)
            usernameButton.alpha = 0.67
            usernameButton.clipsToBounds = true
            pastelView.setColors([
                hexColor(from: "#00CA65"),
                hexColor(from: "#00937B")
            ])
            pastelView.startStatic()
        }
       
    }
    
    func setProgress(_ progress:CGFloat) {
        print("PROGRESS: \(progress)")
    }
    
}


