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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blue
        pagerNode = ASPagerNode()
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.backgroundColor = hexColor(from: "#eff0e9")
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
        
        pagerNode.view.translatesAutoresizingMaskIntoConstraints = false
        pagerNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        pagerNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        pagerNode.view.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        pagerNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        pagerNode.view.delaysContentTouches = false
        //pagerNode.view.isScrollEnabled = false
        pagerNode.view.panGestureRecognizer.delaysTouchesBegan = false
        pagerNode.reloadData()
        
        //titleView.leftButton.addTarget(self, action: #selector(locationPicker), for: .touchUpInside)
        
        //titleView.rightButton.addTarget(self, action: #selector(openContentSettings), for: .touchUpInside)
    }

    @objc func locationPicker() {
        //print("IM SO COLD LIKE YAH")
//        let alert = UIAlertController(title: "Set Location", message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Markham", style: .default, handler: { _ in
//            //SearchService.myCoords = LatLng(lat: 43.9050531135017, lng: -79.27830310499503)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Toronto", style: .default, handler: { _ in
//            //SearchService.myCoords = LatLng(lat: 43.6532, lng: -79.3832)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "New York", style: .default, handler: { _ in
//            SearchService.myCoords = LatLng(lat: 40.7128, lng: -74.0060)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "San Francisco", style: .default, handler: { _ in
//            SearchService.myCoords = LatLng(lat: 37.7749, lng: -122.4194)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "London", style: .default, handler: { _ in
//            SearchService.myCoords = LatLng(lat: 51.5074, lng: -0.1278)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Tokyo", style: .default, handler: { _ in
//            SearchService.myCoords = LatLng(lat: 35.6895, lng: 139.6917)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Mexico City", style: .default, handler: { _ in
//            SearchService.myCoords = LatLng(lat: 19.4326, lng: 99.1332)
//        }))
//        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ContentSettings.recentlyUpdated {
            pagerNode.reloadData()
            ContentSettings.recentlyUpdated = false
        } 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if gpsService.isAuthorized() {
            gpsService.startUpdatingLocation()
            print("GPS SERVICE IS AUTHORIZED")
        } else {
            print("GPS SERVICE IS NOT AUTHORIZED")
        }
        
        print("Is User signed In : \(UserService.isSignedIn)")
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
        print("SCROLL TO: \(index)")
        pagerNode.scrollToPage(at: index, animated: true)
    }
    func scrollTo() {
//        switch header {
//        case .home:
//            pagerNode.scrollToPage(at: 0, animated: true)
//            break
//        case .popular:
//            pagerNode.scrollToPage(at: 1, animated: true)
//            break
//        case .nearby:
//            pagerNode.scrollToPage(at: 2, animated: true)
//            break
//        }
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

class ContainerCellNode:ASCellNode {
    
}
