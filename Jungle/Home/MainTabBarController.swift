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

protocol UploadProgressDelegate {
    func uploadedDidComplete()
}

class MainTabBarController:UITabBarController, UploadProgressDelegate, PushTransitionSourceDelegate {
    
    var messageWrapper = SwiftMessages()
    var postButtonContainer:UIView!
    var postButton:UIButton!
    
    var popupBottomAnchor:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.bounds.height * 0.80, height: tabBar.bounds.height * 0.80))
        postButtonContainer.center = CGPoint(x: tabBar.bounds.width / 2, y: tabBar.bounds.height / 2)
        tabBar.addSubview(postButtonContainer)
        
        postButton = UIButton(frame: postButtonContainer.bounds)
        postButton.setImage(UIImage(named:"NewPost"), for: .normal)
        postButton.backgroundColor = UIColor.clear
        
        postButton.layer.cornerRadius = postButton.frame.height / 2
        postButton.clipsToBounds = true
        postButton.addTarget(self, action: #selector(openNewPostVC), for: .touchUpInside)
        
        postButtonContainer.addSubview(postButton)
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        
//        let divider = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 0.5))
//        divider.backgroundColor = hexColor(from: "708078").withAlphaComponent(0.25)
//        tabBar.addSubview(divider)
        
        self.tabBar.unselectedItemTintColor = hexColor(from: "#708078")
        
    }
    
    @objc func openNewPostVC() {
        if UserService.isSignedIn {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewPostNavController")
            self.present(controller, animated: true, completion: nil)
        } else {
            openLoginView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uploadedDidComplete()
        
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
}

