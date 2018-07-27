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
import Alamofire
import Pulley
import UICircularProgressRing
import Firebase
import UserNotifications


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
    
    struct Timeout {
        var canPost:Bool
        var progress:CGFloat
    }
    
    var progressRing:UICircularProgressRingView!
    
    var timeout = Timeout(canPost: true, progress: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainProtocol = self
        
        tabBar.barTintColor = currentTheme.tabBarColor
        let pHeight = tabBar.bounds.height * 0.80
        postButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: pHeight, height: pHeight))
        
        tabBar.addSubview(postButtonContainer)
        
        postButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        postButtonContainer.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor).isActive = true
        postButtonContainer.centerYAnchor.constraint(equalTo: tabBar.centerYAnchor).isActive = true
        postButtonWidth = postButtonContainer.widthAnchor.constraint(equalToConstant: pHeight)
        postButtonWidth.isActive = true
        postButtonHeight = postButtonContainer.heightAnchor.constraint(equalToConstant:  pHeight)
        postButtonHeight.isActive = true
        
        postButton = UIButton(frame: postButtonContainer.bounds)
        postButton.setImage(UIImage(named:"NewPost"), for: .normal)
        postButton.backgroundColor = UIColor.clear
        //postButtonContainer.alpha = 0.35
        
        postButton.layer.cornerRadius = postButton.frame.height / 2
        postButton.clipsToBounds = true
        postButton.addTarget(self, action: #selector(openNewPostVC), for: .touchUpInside)
        
        postButtonContainer.addSubview(postButton)

        progressRing = UICircularProgressRingView(frame: CGRect(x: 0, y: 0, width: pHeight, height: pHeight))
        // Change any of the properties you'd like
        self.tabBar.addSubview(progressRing)
        progressRing.translatesAutoresizingMaskIntoConstraints = false
        progressRing.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor).isActive = true
        progressRing.centerYAnchor.constraint(equalTo: tabBar.centerYAnchor).isActive = true
        progressRing.widthAnchor.constraint(equalToConstant: pHeight + 5).isActive = true
        progressRing.heightAnchor.constraint(equalToConstant:  pHeight + 5).isActive = true
        
        progressRing.maxValue = 1
        progressRing.shouldShowValueText = false
        
        progressRing.ringStyle = .gradient
        progressRing.outerRingWidth = 2.0
        progressRing.outerRingColor = UIColor(white: 0.0, alpha: 0.0)
        progressRing.innerRingWidth = 2.0
        progressRing.gradientColors = [hexColor(from: "6BE6AC"), hexColor(from: "426ED6")]
        
        progressRing.innerCapStyle = .butt
        progressRing.innerRingSpacing = 0.0
        progressRing.startAngle = -90
        //progressRing.applyShadow(radius: 2.0, opacity: 0.15, offset: .zero, color: UIColor.black, shouldRasterize: false)
        
        progressRing.setProgress(value: 0.75, animationDuration: 1.0)
        progressRing.alpha = 0.0
        self.tabBar.unselectedItemTintColor = hexColor(from: "#708078")
        SearchService.getTrendingHastags()

        StickerService.getStickerPacks { packs in
            StickerService.packs = packs
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserUpdate), name: UserService.userUpdatedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeNotificationsCount()
    }
    
    var notificationsCountHandle:UInt?
    func observeNotificationsCount() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let notificationsRef = database.child("users/notifications/\(uid)").queryOrdered(byChild: "seen").queryEqual(toValue: false)
        
        if let handle = notificationsCountHandle {
            notificationsRef.removeObserver(withHandle: handle)
        }
        
        notificationsCountHandle = notificationsRef.observe(.value, with: { snapshot in
            print("UNSEEN: \(snapshot.childrenCount)")
            let count = snapshot.childrenCount
            let tabItems = self.tabBar.items!
            tabItems[3].badgeColor = tagColor
            tabItems[3].badgeValue = count > 0 ? "\(count)" : nil
            UIApplication.shared.applicationIconBadgeNumber = Int(count)
        })
    }
    
    func updatePostTimer() {
        if timeout.canPost {
            postButton.setImage(UIImage(named:"NewPost"), for: .normal)
            postButtonContainer.alpha = 1.0
        } else {
            postButton.setImage(UIImage(named:"NewPostTimeout"), for: .normal)
            postButtonContainer.alpha = 0.5
        }
        print("PROGRESS: \(timeout.progress)")
    }
    
    @objc func openNewPostVC() {
        if UserService.isSignedIn {
            
            let controller = CameraViewController()
            let drawerVC = StickerViewController()
            let pulleyController = PulleyViewController(contentViewController: controller, drawerViewController: drawerVC)
            pulleyController.drawerBackgroundVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            self.present(pulleyController, animated: true, completion: nil)
        } else {
            openLoginView()
        }
    }
    
    @objc func handleUserUpdate() {
        guard let user = currentUser else { return }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uploadedDidComplete()
        NotificationService.authorizationStatus { _s in
            print("RECENTLY POSTED: \(UserService.recentlyPosted)")
            switch _s {
            case .authorized:
                print("AUTHORIZED")
                break
            case .denied:
                print("DENIED")
                break
            case .notDetermined:
                print("NOT DETERMINED MAN")
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
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        self.present(loginVC, animated: true, completion: nil)
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
        messageView.bodyLabel?.font = Fonts.medium(ofSize: 14.0)
        
        
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

