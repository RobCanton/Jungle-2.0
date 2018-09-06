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
    
    var usernameCenterAnchor:NSLayoutConstraint!
    var avatarBottomAnchor:NSLayoutConstraint!
    var descLabel:UILabel!
    
    var actionsRow:UIView!
    
    var descHeight:CGFloat = 0
    var centerAdjustment:CGFloat = 0
    var topInset:CGFloat = 0
    init(frame:CGRect, topInset:CGFloat, nameHeight:CGFloat, descHeight:CGFloat, includeAvatar:Bool) {
        super.init(frame: frame)
        self.topInset = topInset
        self.descHeight = descHeight
        self.preservesSuperviewLayoutMargins = false
        self.insetsLayoutMarginsFromSafeArea = false
        
        pastelView = PastelView(frame: bounds)
        pastelView.startPastelPoint = .topRight
        pastelView.endPastelPoint = .bottomLeft
        
        pastelView.animationDuration = 10
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
        
        avatarView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.layer.borderWidth = 1.5
        avatarView.layer.cornerRadius = 50
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
        
        let diff = (100 + 50 + topInset) - (topInset + 50 + 100 + (nameHeight - 10) + descHeight + 44)/2
        centerAdjustment = includeAvatar ? nameHeight/2 + diff : diff
        usernameCenterAnchor = usernameButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: centerAdjustment)
        usernameCenterAnchor.isActive = true
        usernameButton.titleLabel?.lineBreakMode = .byTruncatingTail
        usernameButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 44).isActive = true
        usernameButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -44).isActive = true
        usernameButton.heightAnchor.constraint(equalToConstant: nameHeight).isActive = true
        
        avatarBottomAnchor = avatarView.bottomAnchor.constraint(equalTo: usernameButton.topAnchor, constant: 0)
        avatarBottomAnchor.isActive = true
        
        titleView = JTitleView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 50), topInset: topInset)
        //
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
        
        descLabel = UILabel()
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        descLabel.font = Fonts.light(ofSize: 14.0)
        descLabel.text = "Melrose has school on Monday Wednesday Thursday Saturday and all of these days. She can't make it to Wonderland because of her busy schedule."
        descLabel.textColor = UIColor.white
        contentView.addSubview(descLabel)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        descLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 40).isActive = true
        descLabel.heightAnchor.constraint(equalToConstant: descHeight).isActive = true
        
        actionsRow = UIView()
        contentView.addSubview(actionsRow)
        actionsRow.translatesAutoresizingMaskIntoConstraints = false
        actionsRow.heightAnchor.constraint(equalToConstant: 44).isActive = true
        actionsRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        actionsRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        actionsRow.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 0).isActive = true
        
        self.layoutIfNeeded()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setGroup(_ group:Group) {
        avatarView.isHidden = true
        usernameButton.setTitle(group.name, for: .normal)
        usernameButton.titleLabel?.font = Fonts.bold(ofSize: 20)
        descLabel.text = group.desc
        avatarImageView.image = nil
        avatarImageView.url = nil
        let bg = ASNetworkImageNode()
        insertSubview(bg.view, at: 0)
        bg.view.translatesAutoresizingMaskIntoConstraints = false
        bg.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bg.view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bg.view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bg.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bg.url =  group.avatar_high
        bg.alpha = 0.72
        backgroundColor = UIColor.black
        pastelView.isHidden = true
    }
    
    func setProfile(_ profile:Profile?) {
        
        if let profile = profile {
            avatarView.backgroundColor = tertiaryColor
            avatarImageView.image = nil
            UserService.retrieveUserImage(uid: profile.uid, .high) { image, _ in
                self.avatarImageView.image = image
            }
            usernameButton.setTitle(profile.username.lowercased(), for: .normal)
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
        
        if progress <= 1.0 {
            usernameCenterAnchor.constant = topInset/2 + (centerAdjustment-topInset/2) * progress
            avatarBottomAnchor.constant = 15 * (1 - progress)
            avatarView.alpha = progress
            descLabel.alpha = progress
            self.layoutIfNeeded()
        }
    }
    
}


