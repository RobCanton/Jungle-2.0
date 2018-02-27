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

class MainTabBarController:UITabBarController, UploadProgressDelegate {
    
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
        
    }
    
    @objc func openNewPostVC() {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewPostNavController")
        self.present(controller, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uploadedDidComplete()
        
    }

    
    func uploadedDidComplete() {

    }
    
}
