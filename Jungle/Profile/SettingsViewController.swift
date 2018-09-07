//
//  SettingsViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-07-17.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase
import JGProgressHUD


class SettingsViewController:UIViewController, ASTableDelegate, ASTableDataSource {
    
    var titleView:JTitleView!
    var interactor:Interactor? = nil
    var tableNode = ASTableNode()
    var dimView:UIView!
    
    enum OptionKey:String {
        case locationServices = "LOCATION SERVICES"
        case pushNotifications = "PUSH NOTIFICATIONS"
        case contentMode = "CONTENT MODE"
        case termsOfService = "TERMS OF SERVICE"
        case privacyPolicy = "PRIVACY POLICY"
        case logout = "LOGOUT"
        case signUp = "SIGN UP"
    }
    
    enum OptionType {
        case toggle, button, boldButton
    }
    
    struct Option {
        let title:OptionKey
        let description:String
        let type:OptionType
    }

    var options:[Int:[Option]] = [
        0: [
            Option(title: OptionKey.pushNotifications, description: "You will receive alerts when users interact with your posts and posts you are subscribed to.", type: .toggle),
            Option(title: OptionKey.contentMode, description: "Posts that contain potentially abusive and/or inappropriate content content will be blocked.", type: .toggle)
        ],
        1 : [],
        2 : [
            Option(title: OptionKey.privacyPolicy, description: "", type: .button),
            Option(title: OptionKey.termsOfService, description: "", type: .button),
            Option(title: OptionKey.logout, description: "", type: .boldButton)
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = hexColor(from: "#EFEFEF")
        let topInset = UIApplication.deviceInsets.top
        let titleViewHeight = 50 + topInset
        
        titleView = JTitleView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: titleViewHeight), topInset: topInset)
        view.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: titleViewHeight).isActive = true
        titleView.leftButton.setImage(UIImage(named:"back"), for: .normal)
        titleView.leftButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        titleView.titleLabel.text = "SETTINGS"
        //titleView.backgroundImage.image = UIImage(named: "NavBarGradient2")
        
        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan))
        edgeSwipe.edges = .left
        view.addGestureRecognizer(edgeSwipe)
        view.isUserInteractionEnabled = true
        
        view.addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        tableNode.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        tableNode.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableNode.view.contentInsetAdjustmentBehavior = .never
       
        //tableNode.view.separatorStyle = .none
        tableNode.view.showsVerticalScrollIndicator = true
        tableNode.view.delaysContentTouches = false
        tableNode.view.backgroundColor = hexColor(from: "#EFEFEF")
        tableNode.view.tableFooterView = UIView()
        tableNode.delegate = self
        tableNode.dataSource = self
        
        tableNode.isHidden = true
        
        let o:[Int:[Option]] = options
        var indexes = [IndexPath]()
        for (section, rows) in o {
            if rows.count > 0 {
                for i in 0..<rows.count {
                    indexes.append(IndexPath(row: i, section: section))
                }
            } else {
                indexes.append(IndexPath(row: 0, section: section))
            }
        }
        
        tableNode.performBatch(animated: false, updates: {
            self.tableNode.insertRows(at: indexes, with: .none)
        }, completion: { _ in
            self.tableNode.isHidden = false
        })
        
        dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        dimView.alpha = 0.0
        view.addSubview(dimView)
        
        print("VIEW DID LOAD MAN!")
    }
    
    var isAuthenticated = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSettingsUpdate), name: UserService.userSettingsUpdatedNotification, object: nil)
    }
    
    @objc func handleSettingsUpdate() {
        print("SETTINGS UPDATED!")
        
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        let percentThreshold:CGFloat = 0.3
        let verticalMovement = translation.x / view.bounds.width
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.shouldFinish = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return .lightContent }
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return options.count
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if let count = options[section]?.count {
            if count > 0 {
                return count
            }
        }
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if options[indexPath.section]!.count > 0 {
            let option = options[indexPath.section]![indexPath.row]
            switch option.type {
            case .button:
                let cell = SettingsButtonCellNode(option: option)
                return cell
            case .boldButton:
                let cell = SettingsButtonCellNode(option: option, bold: true)
                return cell
            case .toggle:
                let cell = SettingsDetailCellNode(option: option)
                cell.selectionStyle = .none
                return cell
            }
        } else {
            let gapCell = ASCellNode()
            gapCell.style.height = ASDimension(unit: .points, value: 12.0)
            gapCell.backgroundColor = hexColor(from: "#EFEFEF")
            gapCell.selectionStyle = .none
            return gapCell
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let node = tableNode.nodeForRow(at: indexPath) as? SettingsButtonCellNode
        node?.setHighlighted(true)
        
        if options[indexPath.section]!.count > 0 {
            let option = options[indexPath.section]![indexPath.row]
            switch option.title {
            case .termsOfService:
                if let url = URL(string: "https://jungle-anonymous.firebaseapp.com/tos.html") {
                    UIApplication.shared.open(url, options: [:])
                }
                break
            case .privacyPolicy:
                if let url = URL(string: "https://jungle-anonymous.firebaseapp.com/privacypolicy.html") {
                    UIApplication.shared.open(url, options: [:])
                }
                break
            case .logout:
                showLogoutOptions()
                break
            default:
                break
            }
        }
        
        tableNode.deselectRow(at: indexPath, animated: true)
        
    }
    

    
    func tableNode(_ tableNode: ASTableNode, didDeselectRowAt indexPath: IndexPath) {
        let node = tableNode.nodeForRow(at: indexPath) as? SettingsButtonCellNode
        node?.setHighlighted(false)
    }
    
    func tableNode(_ tableNode: ASTableNode, didHighlightRowAt indexPath: IndexPath) {
         let node = tableNode.nodeForRow(at: indexPath) as? SettingsButtonCellNode
        node?.setHighlighted(true)
    }
    
    func tableNode(_ tableNode: ASTableNode, didUnhighlightRowAt indexPath: IndexPath) {
         let node = tableNode.nodeForRow(at: indexPath) as? SettingsButtonCellNode
        node?.setHighlighted(false)
    }
    
    func showLogoutOptions() {
        
        let alert = UIAlertController(title: "Are you sure you want to logout?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = "Logging out..."
            hud.show(in: self.view, animated: true)
            
            let tokenRef = database.child("users/fcmToken/\(uid)")
            tokenRef.removeValue { _, _ in
                nService.clear()
                UserService.currentUser = nil
                UserService.lastPostedAt = nil
                do {
                    try Auth.auth().signOut()
                } catch {
                    print("ERROR: \(error.localizedDescription)")
                }
                hud.dismiss()
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

class SettingsDetailCellNode: ASCellNode {
    var titleNode = ASTextNode()
    var subtitleNode = ASTextNode()
    var switchNode = SwitchNode()
    var option:SettingsViewController.Option?
    required init(option: SettingsViewController.Option) {
        super.init()
        self.option = option
        backgroundColor = UIColor.white
        automaticallyManagesSubnodes = true
        titleNode.maximumNumberOfLines = 1
        titleNode.attributedText = NSAttributedString(string: option.title.rawValue, attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: UIColor.black
            ])
        subtitleNode.maximumNumberOfLines = 0
        subtitleNode.attributedText = NSAttributedString(string: option.description, attributes: [
            NSAttributedStringKey.font: Fonts.light(ofSize: 13.0),
            NSAttributedStringKey.foregroundColor: UIColor.black
            ])
        let settings = UserService.currentUserSettings
        switch option.title {
        case .locationServices:
            switchNode.switchView.setOn(settings.locationServices, animated: false)
            break
        case .pushNotifications:
            switchNode.switchView.isEnabled = false
            NotificationService.authorizationStatus { status in
                if status == .authorized {
                    self.switchNode.switchView.isEnabled = true
                    self.switchNode.switchView.setOn(settings.pushNotifications, animated: false)
                }
            }
            
            
            break
        case .contentMode:
            switchNode.switchView.setOn(settings.safeContentMode, animated: false)
            break
        default:
            break
        }
    }
    
    override func didLoad() {
        super.didLoad()
        switchNode.switchView.addTarget(self, action: #selector(handleSwitch), for: .valueChanged)
    }
    
    @objc func handleSwitch(_ target:UISwitch) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let option = self.option else { return }
        let settingsRef = database.child("users/settings/\(uid)")
        switch option.title {
        case .locationServices:
            settingsRef.child("locationServices").setValue(target.isOn)
            break
        case .pushNotifications:
            settingsRef.child("pushNotifications").setValue(target.isOn)
            break
        case .contentMode:
            settingsRef.child("safeContentMode").setValue(target.isOn)
            break
        default:
            break
        }
        print("HANDLE SWITCH! \(target.isOn)")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        subtitleNode.style.flexShrink = 1.0
        switchNode.style.flexGrow = 1.0
        switchNode.style.width = ASDimension(unit: .points, value: 51)
        let horizontalStack = ASStackLayoutSpec.horizontal()
        horizontalStack.children = [subtitleNode, switchNode]
        horizontalStack.spacing = 16
        
        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.children = [titleNode, horizontalStack]
        verticalStack.spacing = 4.0
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(16, 16, 16, 16), child: verticalStack)
    }
    
    
}

class SettingsButtonCellNode: ASCellNode {
    var titleNode = ASTextNode()
    required init(option: SettingsViewController.Option, bold:Bool?=nil) {
        super.init()
        backgroundColor = UIColor.white
        automaticallyManagesSubnodes = true
        titleNode.maximumNumberOfLines = 1
        
        if let bold = bold, bold {
            let color = option.title == .logout ? UIColor(rgb: (255, 102, 102)) : tagColor
            titleNode.attributedText = NSAttributedString(string: option.title.rawValue, attributes: [
                NSAttributedStringKey.font: Fonts.bold(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: color
                ])
        } else {
            titleNode.attributedText = NSAttributedString(string: option.title.rawValue, attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
                NSAttributedStringKey.foregroundColor: UIColor.black
                ])
        }
        
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(16, 16, 16, 16), child: titleNode)
    }
    
    func setHighlighted(_ highlighted:Bool) {
        backgroundColor = highlighted ? UIColor(white: 0.92, alpha: 1.0) : UIColor.white
    }
}




