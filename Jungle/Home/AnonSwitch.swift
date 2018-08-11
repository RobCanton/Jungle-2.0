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

class AnonSwitch:UIView {
    

    var avatarImageView:ASNetworkImageNode!
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
        
        if let profile = UserService.currentUser?.profile {
            avatarImageView.shouldCacheImage = true
            avatarImageView.url = profile.avatarThumbnailURL
        }
        
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
        
        self.layer.cornerRadius = 16.0
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func display(profile:Profile) {
        anonMode = false
        isUserInteractionEnabled = false
        backgroundColor = tertiaryColor
        avatarImageView.backgroundColor = UIColor.clear
        avatarImageView.imageModificationBlock = nil
        avatarImageView.shouldCacheImage = true
        avatarImageView.url = profile.avatarThumbnailURL
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
        avatarImageView.shouldCacheImage = true
        avatarImageView.url = nil
        UserService.retrieveAnonImage(withName: anon.animal.lowercased()) { image, _ in
            self.avatarImageView.image = image
        }
        backgroundColor = anon.color.withAlphaComponent(0.30)
        avatarImageView.backgroundColor = UIColor.clear
        avatarImageView.imageModificationBlock = { image in
            return image.maskWithColor(color: anon.color) ?? image
        }
        self.anonSwitchView.image = nil
        self.avatarImageView.alpha = 1.0
        
        avatarTopAnchor.constant = 4.0
        avatarLeadingAnchor.constant = 4.0
        avatarBottomAnchor.constant = -4.0
        avatarTrailingAnchor.constant = -4.0
        self.layoutIfNeeded()
    }
    
    func setAnonMode(to anon:Bool) {
        anonMode = anon
        if anon {
            self.anonSwitchView.image = UIImage(named: "anon_switch_on_animated_10")
            self.avatarImageView.alpha = 0.25
        } else {
            self.anonSwitchView.image = nil
            self.avatarImageView.alpha = 1.0
            
        }
    }
    
    @objc func handleAnonSwitch() {
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
            })
        }
        
    }
    
    func animateNextTick(imagePath:String, _ index:Int, _ last:Int, _ completion: @escaping ()->()) {
        let image = UIImage(named:"\(imagePath)\(index)")
        anonSwitchView.image = image
        let newIndex = index + 1
        if newIndex <= last {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
                self.animateNextTick(imagePath: imagePath, newIndex, last, completion)
            })
        } else {
            print("End!")
            return completion()
        }
    }

}
