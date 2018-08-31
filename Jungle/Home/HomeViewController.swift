//
//  HomeViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase
import SwiftMessages
import Popover

class JViewController:UIViewController {
    var shouldHideStatusBar:Bool = false
    
    override var prefersStatusBarHidden: Bool {
        get { return shouldHideStatusBar }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldHideStatusBar {
            self.setNeedsStatusBarAppearanceUpdate()
            
            UIView.animate(withDuration: 0.25, animations: {
                self.shouldHideStatusBar = false
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
}

class HomeViewController:JViewController, ASPagerDelegate, ASPagerDataSource, UIGestureRecognizerDelegate, TabScrollDelegate {
    
    var pagerNode:ASPagerNode!
    var navBar:UIView!
    
    var sm = SwiftMessages()
    
    var titleView:HomeTitleView!
    var messageWrapper = SwiftMessages()
    
    var anonSwitch:AnonSwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        pagerNode = ASPagerNode()
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.backgroundColor = hexColor(from: "#EFEFEF")
        view.addSubview(pagerNode.view)
        
        let layoutGuide = view.safeAreaLayoutGuide
        let topInset = UIApplication.deviceInsets.top
        let titleViewHeight = 50 + topInset
        
        titleView = HomeTitleView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: titleViewHeight), topInset: topInset)
        view.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: titleViewHeight).isActive = true
        titleView.tabScrollView.delegate = self
        
        
        let contentView = titleView.contentView!
        
        anonSwitch = AnonSwitch(frame: .zero)
        contentView.addSubview(anonSwitch)
        anonSwitch.translatesAutoresizingMaskIntoConstraints = false
        anonSwitch.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true
        anonSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        anonSwitch.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        anonSwitch.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        pagerNode.view.translatesAutoresizingMaskIntoConstraints = false
        pagerNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        pagerNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        pagerNode.view.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        pagerNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        pagerNode.view.delaysContentTouches = false
        pagerNode.view.panGestureRecognizer.delaysTouchesBegan = false
        pagerNode.reloadData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        anonSwitch.setProfileImage()
        anonSwitch.setAnonMode(to: UserService.anonMode)
        
        if ContentSettings.recentlyUpdated {
            pagerNode.reloadData()
            ContentSettings.recentlyUpdated = false
        }
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if gpsService.isAuthorized() {
            gpsService.startUpdatingLocation()
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        
        let promptRef = database.child("users/prompts/\(uid)/anonSwitch1")
        let topInset = UIApplication.deviceInsets.top
        promptRef.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                let text = "Tap here to toggle anonymous mode."
                let size = UILabel.size(text: text, height: 44, font: Fonts.medium(ofSize: 14.0)).width
                let height = UILabel.size(text: "Hey", width: self.view.bounds.width, font: Fonts.medium(ofSize: 14.0)).height
                let anonSwitch = self.anonSwitch!
                let startPoint = CGPoint(x: anonSwitch.center.x, y: anonSwitch.center.y + topInset + anonSwitch.bounds.width / 2)
                let aView = UIView(frame: CGRect(x: 0, y: 0, width: size + 16, height: height + 24))
               
                let label = UILabel(frame: .zero)
                label.text = text
                label.font = Fonts.medium(ofSize: 14.0)
                aView.addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                
                label.leadingAnchor.constraint(equalTo: aView.leadingAnchor, constant: 8).isActive = true
                label.trailingAnchor.constraint(equalTo: aView.trailingAnchor, constant: -8).isActive = true
                label.centerYAnchor.constraint(equalTo: aView.centerYAnchor, constant: 4).isActive = true
                
                aView.layoutIfNeeded()
                
                let popover = Popover()
                popover.show(aView, point: startPoint)
                
                promptRef.setValue(true)
            }
        })
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.frame = pagerNode.bounds
        cellNode.backgroundColor = index % 2 == 0 ? UIColor.blue : UIColor.yellow
        var controller:PostsTableViewController!
        switch index {
        case 0:
            controller = PopularPostsTableViewController()
            break
        case 1:
            controller = RecentPostsTableViewController()
            break
        default:
            controller = NearbyPostsTableViewController()
            break
        }
        controller.willMove(toParentViewController: self)
        self.addChildViewController(controller)
        controller.view.frame = cellNode.bounds
        cellNode.addSubnode(controller.node)
        let layoutGuide = cellNode.view.safeAreaLayoutGuide
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        return cellNode
    }
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 3
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == pagerNode.view else { return }
        let offsetX = scrollView.contentOffset.x
        let viewWidth = view.bounds.width
        if offsetX < viewWidth {
            let progress = offsetX / viewWidth
            titleView.tabScrollView.setProgress(progress, index: 0)
        } else {
            let progress = (offsetX - viewWidth) / viewWidth
            titleView.tabScrollView.setProgress(progress, index: 1)
        }
    }
    
    func tabScrollTo(index: Int) {
        pagerNode.scrollToPage(at: index, animated: true)
    }
    
    func authorizeGPS() {
        let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
        messageView.configureBackgroundView(width: 250)
        messageView.configureContent(title: "Enable location services", body: "Your location will be used to show you nearby posts and let you share posts with people near you.", iconImage: nil, iconText: "🌎", buttonImage: nil, buttonTitle: "Enable Location") { _ in
            self.enableLocationTapped()
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
    
    func enableLocationTapped() {
        
        let status = gpsService.authorizationStatus()
        switch status {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        case .denied:
            if #available(iOS 10.0, *) {
                let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)! as URL
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            } else {
                let alert = UIAlertController(title: "Go to Settings", message: "Please minimize Jungle and go to your settings to enable location services.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            break
        case .notDetermined:
            gpsService.requestAuthorization()
            break
        case .restricted:
            break
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


