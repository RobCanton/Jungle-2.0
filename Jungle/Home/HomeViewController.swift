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

class HomeViewController:UIViewController, ASPagerDelegate, ASPagerDataSource, HomeTitleDelegate {
    
    var pagerNode:ASPagerNode!
    var navBar:UIView!
    var titleView:HomeTitleView!
    
    var sm = SwiftMessages()
    
    var messageWrapper = SwiftMessages()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pagerNode = ASPagerNode()
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.backgroundColor = nil
        view.addSubview(pagerNode.view)
        let layoutGuide = view.safeAreaLayoutGuide
       
        navBar = UIView(frame: CGRect(x: 0, y: 20, width: view.bounds.width, height: 44.0))
        navBar.backgroundColor = UIColor.red
        view.addSubview(navBar)
        
        titleView = UINib(nibName: "HomeTitleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HomeTitleView
        titleView.frame = navBar.bounds
        titleView.layoutIfNeeded()
        titleView.delegate = self
        titleView.backgroundColor = UIColor.red
        navBar.addSubview(titleView)
        pagerNode.view.translatesAutoresizingMaskIntoConstraints = false
        pagerNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        pagerNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        pagerNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 44).isActive = true
        pagerNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        pagerNode.view.delaysContentTouches = false
        pagerNode.reloadData()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.navigationBar.tintColor = UIColor.gray
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named:"Back"), style: .plain, target: nil, action: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if gpsService.isAuthorized() {
            gpsService.startUpdatingLocation()
        } else {
            authorizeGPS()
        }
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.frame = pagerNode.bounds
        cellNode.backgroundColor = index % 2 == 0 ? UIColor.blue : UIColor.yellow
        
        var type:PostsTableType!
        switch index {
        case 0:
            type = .newest
            break
        case 1:
            type = .popular
            break
        case 2:
            type = .nearby
            break
        default:
            return cellNode
        }
        let controller = PostsTableViewController(type: type)
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
        let progress = scrollView.contentOffset.x / scrollView.contentSize.width
        titleView.setProgress(progress)
    }
    
    func scrollTo(header: HomeHeader) {
        switch header {
        case .home:
            pagerNode.scrollToPage(at: 0, animated: true)
            break
        case .popular:
            pagerNode.scrollToPage(at: 1, animated: true)
            break
        case .nearby:
            pagerNode.scrollToPage(at: 2, animated: true)
            break
        }
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
}

