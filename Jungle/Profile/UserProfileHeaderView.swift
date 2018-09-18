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

class UserProfileHeaderView:UIView {
    
    var bgView:UIImageView!
    var avatarView:UIView!
    var avatarImageView:ASNetworkImageNode!
    var usernameButton:UIButton!
    
    var titleView:JTitleView!
    var contentView:UIView!
    
    var usernameCenterAnchor:NSLayoutConstraint!
    var avatarBottomAnchor:NSLayoutConstraint!
    var descLabel:UILabel!
    
    var actionsRow:UIView!
    
    var descHeight:CGFloat = 0
    var centerAdjustment:CGFloat = 0
    var topInset:CGFloat = 0
    init(frame:CGRect, topInset:CGFloat, descHeight:CGFloat) {
        super.init(frame: frame)
        self.topInset = topInset
        self.descHeight = descHeight
        self.preservesSuperviewLayoutMargins = false
        self.insetsLayoutMarginsFromSafeArea = false
        
        bgView = UIImageView(frame:bounds)
        bgView.image = UIImage(named:"GreenBox")
        bgView.contentMode = .scaleAspectFill
        self.addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bgView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        contentView = UIView()
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
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
        usernameButton.titleLabel?.font = Fonts.bold(ofSize: 20)
        contentView.addSubview(usernameButton)
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        
        let diff = (100 + 50 + topInset) - (topInset + 50 + 100 + 50 + descHeight + 44)/2
        centerAdjustment = 25 + diff
        usernameCenterAnchor = usernameButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: centerAdjustment)
        usernameCenterAnchor.isActive = true
        usernameButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        usernameButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
        descLabel.text = ""
        descLabel.textColor = UIColor.white
        contentView.addSubview(descLabel)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        descLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 50).isActive = true
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
        usernameButton.setTitle(group.name, for: .normal)
        descLabel.text = group.desc
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
        } else {
            avatarView.backgroundColor = hexColor(from: "#005B51")
            avatarImageView.url = nil
            avatarImageView.image = UIImage(named:"anon_switch_on_large")
            usernameButton.setTitle("My Account", for: .normal)
            usernameButton.alpha = 0.67
            usernameButton.clipsToBounds = true
            
        }
        
    }
    
    func setProgress(_ progress:CGFloat) {
        print("PROGRESS: \(progress)")
        
        if progress <= 1.0 {
            let scale = 0.75 + 0.25 * progress
            usernameButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            usernameCenterAnchor.constant = topInset/2 + (centerAdjustment-topInset/2) * progress
            avatarBottomAnchor.constant = 15 * (1 - progress)
            avatarView.alpha = progress
            descLabel.alpha = progress
        } else {
            usernameButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            usernameCenterAnchor.constant = topInset/2 + (centerAdjustment-topInset/2)
            avatarBottomAnchor.constant = 0
            avatarView.alpha = 1
            descLabel.alpha = 1
        }
        self.layoutIfNeeded()
    }
    
}


