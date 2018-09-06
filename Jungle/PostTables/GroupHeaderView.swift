//
//  GroupHeaderView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-04.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Pastel
import Firebase

class GroupHeaderView:UIView {
    
    var pastelView:PastelView!
    
    var avatarView:UIView!
    var avatarImageView:ASNetworkImageNode!
    var nameTitle:UILabel!
    var joinButton:UIButton!
    var joinSpinner:UIActivityIndicatorView!
    
    var titleView:JTitleView!
    var contentView:UIView!
    
    var usernameCenterAnchor:NSLayoutConstraint!
    var avatarBottomAnchor:NSLayoutConstraint!
    var descLabel:UILabel!
    var infoLabel:UILabel!
    var infoRow:UIView!
    
    var actionsRow:UIView!
    
    var descHeight:CGFloat = 0
    var centerAdjustment:CGFloat = 0
    var topInset:CGFloat = 0
    
    var bg:ASNetworkImageNode!
    
    weak var group:Group?
    
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
        
        nameTitle = UILabel()
        nameTitle.text = ""
        nameTitle.textColor = UIColor.white
        nameTitle.font = Fonts.bold(ofSize: 20)
        contentView.addSubview(nameTitle)
        nameTitle.translatesAutoresizingMaskIntoConstraints = false
        
        centerAdjustment = (100 + 50 + topInset) - (topInset + 50 + 100 + (nameHeight - 10) + descHeight + 44 + 32 - 8)/2 - 25
        usernameCenterAnchor = nameTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: centerAdjustment)
        usernameCenterAnchor.isActive = true
        nameTitle.numberOfLines = 2
        nameTitle.textAlignment = .center
        nameTitle.lineBreakMode = .byTruncatingTail
        nameTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 44).isActive = true
        nameTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -44).isActive = true
        nameTitle.heightAnchor.constraint(equalToConstant: nameHeight).isActive = true
        
        avatarBottomAnchor = avatarView.bottomAnchor.constraint(equalTo: nameTitle.topAnchor, constant: 0)
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
        
        infoRow = UIView()
        contentView.addSubview(infoRow)
        infoRow.translatesAutoresizingMaskIntoConstraints = false
        infoRow.heightAnchor.constraint(equalToConstant: 44).isActive = true
        infoRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        infoRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        infoRow.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: nameHeight - 10).isActive = true
        infoRow.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        infoLabel = UILabel()
        infoLabel.numberOfLines = 1
        infoLabel.textAlignment = .center
        infoLabel.font = Fonts.medium(ofSize: 14.0)
        
        infoLabel.textColor = UIColor.white
        infoRow.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.centerXAnchor.constraint(equalTo: infoRow.centerXAnchor).isActive = true
        infoLabel.centerYAnchor.constraint(equalTo: infoRow.centerYAnchor).isActive = true
        
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
        descLabel.topAnchor.constraint(equalTo: infoRow.bottomAnchor, constant: -8).isActive = true
        descLabel.heightAnchor.constraint(equalToConstant: descHeight).isActive = true
        
        joinButton = UIButton(type: .custom)
        joinButton.setTitle("Join Group", for: .normal)
        joinButton.titleLabel?.font = Fonts.semiBold(ofSize: 16.0)
        joinButton.setTitleColor(UIColor.white, for: .normal)
        joinButton.layer.cornerRadius = 32/2
        joinButton.layer.borderColor = UIColor.white.cgColor
        joinButton.layer.borderWidth = 1.5
        joinButton.clipsToBounds = true
        joinButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12)
        
        actionsRow = UIView()
        contentView.addSubview(actionsRow)
        actionsRow.translatesAutoresizingMaskIntoConstraints = false
        actionsRow.heightAnchor.constraint(equalToConstant: 44).isActive = true
        actionsRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        actionsRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        actionsRow.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 0).isActive = true
        
        actionsRow.addSubview(joinButton)
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.centerXAnchor.constraint(equalTo: actionsRow.centerXAnchor).isActive = true
        joinButton.centerYAnchor.constraint(equalTo: actionsRow.centerYAnchor).isActive = true
        joinButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        joinButton.addTarget(self, action: #selector(toggleJoin), for: .touchUpInside)
        
        joinSpinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        actionsRow.addSubview(joinSpinner)
        joinSpinner.translatesAutoresizingMaskIntoConstraints = false
        joinSpinner.centerXAnchor.constraint(equalTo: joinButton.centerXAnchor).isActive = true
        joinSpinner.centerYAnchor.constraint(equalTo: joinButton.centerYAnchor).isActive = true
        joinSpinner.hidesWhenStopped = true
        joinSpinner.stopAnimating()
        
        bg = ASNetworkImageNode()
        insertSubview(bg.view, at: 0)
        bg.view.translatesAutoresizingMaskIntoConstraints = false
        bg.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bg.view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bg.view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bg.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bg.alpha = 0.7
        self.layoutIfNeeded()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setGroup(_ group:Group) {
        self.group = group
        avatarView.isHidden = true
        nameTitle.text = group.name
        nameTitle.font = Fonts.bold(ofSize: 20)
        descLabel.text = group.desc
        avatarImageView.image = nil
        avatarImageView.url = nil
        
        bg.url =  group.avatar_high
        backgroundColor = UIColor.black
        pastelView.isHidden = true
        
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
        
        infoLabel.text = "\(membersStr) · \(postsStr)"
        
        refreshJoinButton()
    }
    
    @objc func toggleJoin() {
        guard let group = self.group else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let memberRef = database.child("users/groups/\(uid)/\(group.id)")
        joinButton.isEnabled = false
        joinButton.setTitleColor(UIColor.clear, for: .normal)
        joinButton.backgroundColor = UIColor.clear
        joinSpinner.startAnimating()
        
        if GroupsService.myGroupKeys[group.id] != nil {
            
            GroupsService.leaveGroup(id: group.id) { _ in
                self.refreshJoinButton()
            }
            
        } else {
            
            GroupsService.joinGroup(id: group.id) { _ in
                self.refreshJoinButton()
            }
        }
        
    }
    
    func refreshJoinButton() {
        guard let group = self.group else { return }
        joinSpinner.stopAnimating()
        joinButton.isEnabled = true
        if GroupsService.myGroupKeys[group.id] == true {
            joinButton.setTitle("Joined ✓", for: .normal)
            joinButton.setTitleColor(UIColor(white: 0.15, alpha: 1.0), for: .normal)
            joinButton.backgroundColor = UIColor.white
        } else {
            joinButton.setTitle("Join Group", for: .normal)
            joinButton.setTitleColor(UIColor.white, for: .normal)
            joinButton.backgroundColor = UIColor.clear
        }
    }
    
    func setProgress(_ progress:CGFloat) {
        print("PROGRESS: \(progress)")
        
        if progress <= 1.0 {
            let scale = 0.75 + 0.25 * progress
            nameTitle.transform = CGAffineTransform(scaleX: scale, y: scale)
            usernameCenterAnchor.constant = topInset/2 + (centerAdjustment-topInset/2) * progress
            //avatarBottomAnchor.constant = 15 * (1 - progress)
            let alphaProgress = progress * progress
            avatarView.alpha = alphaProgress
            descLabel.alpha = alphaProgress
            joinButton.alpha = alphaProgress
            infoLabel.alpha = alphaProgress
            bg.alpha = 0.3 + 0.4 * progress
            self.layoutIfNeeded()
        }
    }
    
}


