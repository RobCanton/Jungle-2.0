//
//  AnonSwitch.swift
//  Jungle
//
//  Created by Robert Canton on 2018-08-09.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import SwiftMessages
import Firebase

protocol AnonSwitchDelegate:class {
    func anonDidSwitch()
}

class AnonSwitch:UIView {
    
    weak var delegate:AnonSwitchDelegate?
    var avatarImageView:ASImageNode!
    var anonSwitchView:UIImageView!
    var anonButton:UIButton!
    
    var anonMode = true
    
    var avatarTopAnchor:NSLayoutConstraint!
    var avatarLeadingAnchor:NSLayoutConstraint!
    var avatarBottomAnchor:NSLayoutConstraint!
    var avatarTrailingAnchor:NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.preservesSuperviewLayoutMargins = false
        self.insetsLayoutMarginsFromSafeArea = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = hexColor(from: "#005B51")
        
        avatarImageView = ASNetworkImageNode()
        self.addSubview(avatarImageView.view)
        avatarImageView.view.translatesAutoresizingMaskIntoConstraints = false
        avatarLeadingAnchor = avatarImageView.view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        avatarTopAnchor = avatarImageView.view.topAnchor.constraint(equalTo: self.topAnchor)
        avatarTrailingAnchor = avatarImageView.view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        avatarBottomAnchor = avatarImageView.view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        
        avatarLeadingAnchor.isActive = true
        avatarTopAnchor.isActive = true
        avatarTrailingAnchor.isActive = true
        avatarBottomAnchor.isActive = true
        
        avatarImageView.view.clipsToBounds = true
        
        anonSwitchView = UIImageView(image: nil)
        self.addSubview(anonSwitchView)
        anonSwitchView.translatesAutoresizingMaskIntoConstraints = false
        anonSwitchView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        anonSwitchView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        anonSwitchView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        anonSwitchView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        anonButton = UIButton(type: .custom)
        self.addSubview(anonButton)
        anonButton.translatesAutoresizingMaskIntoConstraints = false
        anonButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        anonButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        anonButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        anonButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        anonButton.addTarget(self, action: #selector(handleAnonSwitch), for: .touchUpInside)
        
        self.layer.borderWidth = 1.0
        
        self.layer.cornerRadius = 16.0
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProfileImage() {
        if let profile = UserService.currentUser?.profile {
            UserService.retrieveUserImage(uid: profile.uid, .low) { image, _ in
                self.avatarImageView.image = image
            }
        }
    }
    
    func display(profile:Profile) {
        anonMode = false
        isUserInteractionEnabled = false
        backgroundColor = tertiaryColor
        avatarImageView.backgroundColor = UIColor.clear
        avatarImageView.imageModificationBlock = nil
        
        UserService.retrieveUserImage(uid: profile.uid, .low) { image, _ in
            self.avatarImageView.image = image
        }
        self.anonSwitchView.image = nil
        self.avatarImageView.alpha = 1.0
        
        avatarTopAnchor.constant = 0.0
        avatarLeadingAnchor.constant = 0.0
        avatarBottomAnchor.constant = 0.0
        avatarTrailingAnchor.constant = 0.0
        
        self.layoutIfNeeded()
    }
    func display(anon:Anon) {
        anonMode = true
        isUserInteractionEnabled = false
        UserService.retrieveAnonImage(withName: anon.animal.lowercased()) { image, _ in
            self.avatarImageView.image = image
        }
        backgroundColor = anon.color
        avatarImageView.backgroundColor = UIColor.clear
        avatarImageView.imageModificationBlock = { image in
            return image.maskWithColor(color: UIColor(white: 1.0, alpha: 0.75)) ?? image
        }
        self.anonSwitchView.image = nil
        self.avatarImageView.alpha = 1.0
        
        avatarTopAnchor.constant = 5.0
        avatarLeadingAnchor.constant = 5.0
        avatarBottomAnchor.constant = -5.0
        avatarTrailingAnchor.constant = -5.0
        self.layoutIfNeeded()
    }
    
    func setAnonMode(to anon:Bool) {
        anonMode = anon
        if anon {
            self.anonSwitchView.image = UIImage(named: "anon_switch_on_animated_10")
            self.avatarImageView.alpha = 0.25
            self.layer.borderColor = UIColor.white.cgColor
        } else {
            self.anonSwitchView.image = nil
            self.avatarImageView.alpha = 1.0
            self.layer.borderColor = UIColor.clear.cgColor
            
        }
    }
    
    @objc func handleAnonSwitch() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if UserService.currentUser?.profile == nil {
            print("CANT SWITCH!")
            showCreateProfilePrompt()
            return
        }
        self.anonButton.isEnabled = false
        UserService.anonMode = !UserService.anonMode
        anonMode = UserService.anonMode
        if UserService.anonMode {
            let _ = Alerts.showAnonAlert(withMessage: "Switched to anonymous mode.")
            animateNextTick(imagePath:"anon_switch_on_animated_", 0,10) {
                self.anonButton.isEnabled = true
            }
            UIView.animate(withDuration: 0.4, animations: {
                self.avatarImageView.alpha = 0.20
                self.layer.borderColor = UIColor.white.cgColor
            })
            
        } else {
            if let profile = UserService.currentUser?.profile {
                let _ = Alerts.showAnonAlert(withMessage: "Switched to @\(profile.username).")
            }
            animateNextTick(imagePath:"anon_switch_off_animated_", 0,4) {
                self.anonButton.isEnabled = true
            }
            UIView.animate(withDuration: 0.4, animations: {
                self.avatarImageView.alpha = 1.0
                self.layer.borderColor = UIColor.clear.cgColor
            })
            
        }
        
        let settingsRef = database.child("users/settings/\(uid)/anonMode")
        settingsRef.setValue(UserService.anonMode)
        
        delegate?.anonDidSwitch()
    }
    
    func animateNextTick(imagePath:String, _ index:Int, _ last:Int, _ completion: @escaping ()->()) {
        let image = UIImage(named:"\(imagePath)\(index)")
        anonSwitchView.image = image
        let newIndex = index + 1
        if newIndex <= last {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.035, execute: {
                self.animateNextTick(imagePath: imagePath, newIndex, last, completion)
            })
        } else {
            print("End!")
            return completion()
        }
    }

    func showCreateProfilePrompt() {
        let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
        messageView.configureBackgroundView(width: 250)
        messageView.configureContent(title: "You are anonymous", body: "To set your own username and avatar create a public profile. You can still go back into hiding anytime!", iconImage: UIImage(named:"anon_switch_on_animated_10"), iconText: "", buttonImage: nil, buttonTitle: "Create a Profile") { _ in
            
            SwiftMessages.hide()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                let controller = CreateProfileViewController()
                controller.popupMode = true
                let top = UIApplication.topViewController()
                top?.present(controller, animated: true, completion: nil)
            })
        }
        messageView.titleLabel?.font = Fonts.semiBold(ofSize: 17.0)
        messageView.bodyLabel?.font = Fonts.regular(ofSize: 14.0)
        
        messageView.iconImageView?.backgroundColor = hexColor(from: "#005B51")
        messageView.iconImageView?.layer.cornerRadius = messageView.iconImageView!.bounds.width / 2
        
        let button = messageView.button!
        button.backgroundColor = accentColor
        button.titleLabel!.font = Fonts.semiBold(ofSize: 16.0)
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 12.0, right: 16.0)
        button.sizeToFit()
        button.layer.cornerRadius = messageView.button!.bounds.height / 2
        button.clipsToBounds = true
        
        messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
        messageView.backgroundView.layer.cornerRadius = 12
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.duration = .forever
        config.dimMode = .gray(interactive: true)
        SwiftMessages.show(config: config, view: messageView)
    }
}
