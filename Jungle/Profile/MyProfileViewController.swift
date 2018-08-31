//
//  MyProfileViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-08-14.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import MXParallaxHeader
import SwiftMessages
import Firebase
import JGProgressHUD


class MyProfileViewController:UserProfileViewController {

    var pushTransition = PushTransitionManager()
    var imagePicker:UIImagePickerController!
    var gradientActivityIndicator:UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        gradientActivityIndicator.hidesWhenStopped = true
        gradientActivityIndicator.stopAnimating()
        headerView.titleView.addSubview(gradientActivityIndicator)
        gradientActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        gradientActivityIndicator.centerXAnchor.constraint(equalTo: headerView.titleView.leftButton.centerXAnchor).isActive = true
        gradientActivityIndicator.centerYAnchor.constraint(equalTo: headerView.titleView.leftButton.centerYAnchor).isActive = true
        
        
        headerView.titleView.leftButton.setImage(UIImage(named:"changeGradient"), for: .normal)
        headerView.titleView.leftButton.addTarget(self, action: #selector(changeGradient), for: .touchUpInside)
        
        headerView.titleView.rightButton.setImage(UIImage(named: "Settings"), for: .normal)
        headerView.titleView.rightButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        headerView.avatarImageView.addTarget(self, action: #selector(handleCreateProfile), forControlEvents: .touchUpInside)
        headerView.usernameButton.addTarget(self, action: #selector(handleCreateProfile), for: .touchUpInside)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _profile = UserService.currentUser?.profile {
            if self.profile == nil {
                pagerNode.reloadData()
            }
            profile = _profile
        }
        headerView.titleView.leftButton.isHidden = profile == nil
        super.viewWillAppear(animated)
    }
    
    @objc func openSettings() {
        let controller = SettingsViewController()
        pushTransition.navBarHeight = nil
        controller.interactor = pushTransition.interactor
        controller.transitioningDelegate = pushTransition
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func handleCreateProfile() {
        if let profile = profile {
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            showCreateProfilePrompt()
        }

    }
    
    func showCreateProfilePrompt() {
        let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
        messageView.configureBackgroundView(width: 250)
        messageView.configureContent(title: "You are anonymous", body: "To set your own username and avatar create a public profile. You can go back to being anonymous at anytime.", iconImage: UIImage(named:"anon_switch_on_animated_10"), iconText: "", buttonImage: nil, buttonTitle: "Create a Profile") { _ in
            
            SwiftMessages.hide()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                let controller = CreateProfileViewController()
                controller.popupMode = true
                self.present(controller, animated: true, completion: nil)
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
    
    @objc func changeGradient() {
        print("changeGradient")
        gradientActivityIndicator.startAnimating()
        headerView.titleView.leftButton.isHidden = true
        functions.httpsCallable("randomizeUserGradient").call { result, error in
            if let data = result?.data as? [String:Any],
                let gradient = data["gradient"] as? [String] {
                print("DATA: \(data)")
                UserService.currentUser?.profile?.gradient = gradient
                var colors = [UIColor]()
                for hex in gradient {
                    colors.append(hexColor(from:hex))
                }
                self.headerView.pastelView.stop()
                self.headerView.pastelView.setColors(colors)
                self.headerView.pastelView.startStatic()
                
                self.gradientActivityIndicator.stopAnimating()
                self.headerView.titleView.leftButton.isHidden = false
            }
        }
    }
    
    override func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        
        let cellNode = ASCellNode()
        
        cellNode.frame = pagerNode.bounds
        cellNode.backgroundColor = hexColor(from: "#EFEFEF")
        var controller:PostsTableViewController!
        switch index {
        case 0:
            controller = MyPostsTableViewController()
            break
        case 1:
            controller = MyCommentsTableViewController()
            break
        default:
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
}

extension MyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            let hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = "Uploading..."
            hud.show(in: self.view, animated: true)
            
        
            UserService.uploadProfileImage(pickedImage, quality: .high) { _ in
                UserService.uploadProfileImage(pickedImage, quality: .low) { _ in
                    self.headerView.avatarImageView.image = pickedImage
                    if let uid = Auth.auth().currentUser?.uid {
                        UserService.userImageCache.removeObject(forKey: NSString(string: "\(uid)-low"))
                        UserService.userImageCache.removeObject(forKey: NSString(string: "\(uid)-high"))
                    }
                    
                    hud.dismiss()
                }
            }

        }
    
    }
    

}
