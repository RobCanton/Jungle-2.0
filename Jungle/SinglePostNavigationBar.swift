//
//  SinglePostNavigationBar.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-12.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit


class SinglePostNavigationBar:UIView {
    
    var contentBox:UIView!
    var backButton:UIButton!
    var avatarImageView:UIImageView!
    var nameLabel:UILabel!
    var subtitleLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        self.insetsLayoutMarginsFromSafeArea = false
        self.preservesSuperviewLayoutMargins = false
        
        
        
        contentBox = UIView()
        addSubview(contentBox)
        contentBox.translatesAutoresizingMaskIntoConstraints = false
        contentBox.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentBox.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        contentBox.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentBox.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named:"back"), for: .normal)
        backButton.tintColor = UIColor.white
        contentBox.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.centerYAnchor.constraint(equalTo: contentBox.centerYAnchor).isActive = true
        backButton.leadingAnchor.constraint(equalTo: contentBox.leadingAnchor, constant: 8).isActive = true
        
        avatarImageView = UIImageView(frame: .zero)
        avatarImageView.backgroundColor = UIColor.black
        contentBox.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 2).isActive = true
        avatarImageView.centerYAnchor.constraint(equalTo: contentBox.centerYAnchor).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor, multiplier: 1.0).isActive = true
        avatarImageView.layer.cornerRadius = 32.0 / 2
        avatarImageView.clipsToBounds = true
        
        nameLabel = UILabel(frame:.zero)
        nameLabel.text = "FriendlyGorilla"
        nameLabel.font = Fonts.semiBold(ofSize: 14.0)
        nameLabel.textColor = UIColor.white
        contentBox.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10.0).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentBox.topAnchor, constant: 8.0).isActive = true
        
        subtitleLabel = UILabel(frame:.zero)
        subtitleLabel.text = "23m   Markham, CA"
        subtitleLabel.font = Fonts.regular(ofSize: 13.0)
        subtitleLabel.textColor = UIColor.white
        contentBox.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10.0).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 1.0).isActive = true
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPost(_ post:Post) {
        backgroundColor = post.anon.color
        backButton.tintColor = UIColor.white//post.anon.color
        avatarImageView.backgroundColor = UIColor.white//post.anon.color
        
        nameLabel.text = post.anon.displayName
        
        var locationStr = ""
        if let location = post.location {
            locationStr = " · \(location.locationStr)"
        }
        
        subtitleLabel.text = "\(post.createdAt.timeSinceNow())\(locationStr)"
        self.clipsToBounds = false
        self.applyShadow(radius: 5.0, opacity: 0.25, offset: CGSize(width:0,height:5.0), color: post.anon.color, shouldRasterize: false)
    }
}
