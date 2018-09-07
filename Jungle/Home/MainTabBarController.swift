//
//  MainTabBarController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages
import Pulley
import Firebase
import UserNotifications
import Crashlytics

protocol UploadProgressDelegate {
    func uploadedDidComplete()
}

protocol MainProtocol {
    func openLoginView()
}

var mainProtocol:MainProtocol!
var nService = NotificationObserver()

class MainTabBarController:UITabBarController, UploadProgressDelegate, PushTransitionSourceDelegate, MainProtocol {
    
    var messageWrapper = SwiftMessages()
    var postButtonContainer:UIView!
    var postButton:UIButton!
    var postButtonWidth:NSLayoutConstraint!
    var postButtonHeight:NSLayoutConstraint!
    
    var popupBottomAnchor:NSLayoutConstraint?
    
    var progressView:ACRCircleView!
    
    var notificationsRef:DatabaseReference?
    var notificationsCountHandle:UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainProtocol = self
        
        tabBar.barTintColor = currentTheme.tabBarColor
        let gapHeight = tabBar.bounds.height * 0.10
        let pHeight = tabBar.bounds.height - gapHeight * 2
        postButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: pHeight, height: pHeight))
        
        tabBar.addSubview(postButtonContainer)
        tabBar.tintColor = accentColor
        tabBar.unselectedItemTintColor = accentColor
        //postButtonContainer.backgroundColor = accentColor
        postButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        postButtonContainer.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor).isActive = true
        postButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -gapHeight).isActive = true
        postButtonWidth = postButtonContainer.widthAnchor.constraint(equalToConstant: pHeight)
        postButtonWidth.isActive = true
        postButtonHeight = postButtonContainer.heightAnchor.constraint(equalToConstant:  pHeight)
        postButtonHeight.isActive = true
        
        postButtonContainer.layer.cornerRadius = postButtonContainer.bounds.height / 2
        postButtonContainer.clipsToBounds = true
        
        postButton = UIButton(frame: postButtonContainer.bounds)
        postButton.setImage(UIImage(named:"NewPost"), for: .normal)
        
        postButton.layer.cornerRadius = postButton.frame.height / 2
        postButton.clipsToBounds = true
        postButton.addTarget(self, action: #selector(openNewPostVC), for: .touchUpInside)
        postButtonContainer.addSubview(postButton)
        
        progressView = ACRCircleView(frame: postButtonContainer.bounds)
        progressView.baseColor = UIColor.clear
        progressView.tintColor = UIColor.white
        progressView.strokeWidth = 10
        progressView.transform = CGAffineTransform(scaleX: -1, y: 1)
        postButtonContainer.addSubview(progressView)
        
        progressView.strokeWidth = progressView.bounds.width / 2
        progressView.progress = 0.25
        progressView.alpha = 0.75
        progressView.isUserInteractionEnabled = false
        
        updatePostTimer()
        
        self.tabBar.unselectedItemTintColor = hexColor(from: "#708078")
        SearchService.getTrendingHastags()

        StickerService.getStickerPacks { packs in
            StickerService.packs = packs
        }
        
        tabBar.items?[2].isEnabled = false
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeNotificationsCount()
        
        tabBar.items?[4].isEnabled = true
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let timeoutRef = database.child("users/timeout/\(uid)")
        timeoutRef.observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String:Any] {
                UserService.timeout = UserService.parseTimeout(data)
                self.updatePostTimer()
            }
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let handle = notificationsCountHandle {
            notificationsRef?.removeObserver(withHandle: handle)
        }
    }
    
    func observeNotificationsCount() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        notificationsRef = database.child("users/notifications/\(uid)")
        
        if let handle = notificationsCountHandle {
            notificationsRef?.removeObserver(withHandle: handle)
        }
        
        let query = notificationsRef?.queryOrdered(byChild: "seen").queryEqual(toValue: false)
        notificationsCountHandle = query?.observe(.value, with: { snapshot in
            let count = snapshot.childrenCount
            let tabItems = self.tabBar.items!
            tabItems[3].badgeColor = tagColor
            tabItems[3].badgeValue = count > 0 ? "\(count)" : nil
            UIApplication.shared.applicationIconBadgeNumber = Int(count)
        })
    }
    
    func updatePostTimer() {
        self.progressView.progress =  UserService.timeout.progress
    }
    
    @objc func openNewPostVC() {
        let timeout = UserService.timeout
        if timeout.canPost {
            let controller = CameraViewController()
            self.present(controller, animated: true, completion: nil)
        } else {
            
            
            let error = MessageView.viewFromNib(layout: .cardView)
            var minutes:String
            if timeout.minsLeft == 0 {
                minutes = "less than a minute."
            } else if timeout.minsLeft == 1 {
                minutes = "1 minute."
            } else {
                minutes = "\(timeout.minsLeft) minutes."
            }
            
            error.configureContent(title: "Hold on!", body: "You can post again in \(minutes)", iconImage: Icon.errorLight.image)
            error.button?.removeFromSuperview()
            error.configureTheme(.error, iconStyle: .default)
            error.configureDropShadow()
            error.configureTheme(backgroundColor: tagColor, foregroundColor: .white)
            var config = SwiftMessages.Config.init()
            config.presentationContext = .viewController(self)
            config.duration = .seconds(seconds: 4.0)
            config.presentationStyle = .bottom
            
            messageWrapper.show(config: config, view: error)
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let ref = database.child("users/timeout/\(uid)/notifyOnComplete")
            ref.setValue(true)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uploadedDidComplete()
        NotificationService.authorizationStatus { _s in
            switch _s {
            case .authorized:
                break
            case .denied:
                break
            case .notDetermined:
                if UserService.currentUserSettings.pushNotifications {
                    NotificationService.showRequestAlert(self.messageWrapper)
                } else if UserService.recentlyPosted, !UserService.currentUserSettings.pushNotifications {
                    let message = "Would you like to be notified when users interact with your posts and comments?"
                    NotificationService.showRequestAlert(self.messageWrapper, message: message)
                }
                break
            }
            UserService.recentlyPosted = false
        }
    }
    
    func uploadedDidComplete() {

    }
    
    func staticTopView() -> UIImageView? {
        return view.snapshot(of: CGRect(x: 0, y: 0, width: view.bounds.width, height: 64.0))
    }
    
    
    func openLoginView() {
        let controller = EmailViewController()
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func handleUnseenNotification() {
    }
    
    func authorizePushNotifications() {
        let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
        messageView.configureBackgroundView(width: 250)
        messageView.configureContent(title: "Enable Push Notifications", body: "You will receive push notifications when users interact with your posts and comments.", iconImage: nil, iconText: "🔔", buttonImage: nil, buttonTitle: "Enable Notifications") { _ in
            self.messageWrapper.hide()
        }
        messageView.titleLabel?.font = Fonts.semiBold(ofSize: 16.0)
        messageView.bodyLabel?.font = Fonts.semiBold(ofSize: 14.0)
        
        
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
        config.dimMode = .color(color: UIColor(white: 0.25, alpha: 1.0), interactive: true)
        self.messageWrapper.show(config: config, view: messageView)
    }
    
}

