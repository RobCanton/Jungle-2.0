//
//  EmailViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-08-06.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Pastel
import Firebase
import SwiftMessages

class EmailViewController:UIViewController {
    
    var pastelView:PastelView!
    
    enum State {
        case enter
        case enterEmail
        case linkSent
    }
    
    var state = State.enter
    
    var textContainer:UIView!
    var textBubble:UIView!
    var textField:UITextField!
    
    var submitContainer:UIView!
    var submitButton:UIButton!
    
    var stackBottomConstraint:NSLayoutConstraint!
    var imageView:UIImageView!
    var iconView:UIImageView!
    var sentTitleLabel:UILabel!
    var sentDescLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = hexColor(from: "#EFEFEF")
        pastelView = PastelView(frame:view.bounds)
        pastelView.startPastelPoint = .top
        pastelView.endPastelPoint = .bottom
        
        // Custom Duration
        pastelView.animationDuration = 12
        pastelView.setColors([hexColor(from: "00CA65"),
                              hexColor(from: "00937B")])
        pastelView.isUserInteractionEnabled = false
        pastelView.isHidden = false
        view.insertSubview(pastelView, at: 0)
        //view.backgroundColor = UIColor.white
        
        let topInset = UIApplication.deviceInsets.top
        let titleViewHeight = 50 + topInset
        
        let titleView = JTitleView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: titleViewHeight), topInset: topInset)
        titleView.backgroundColor = nil
        titleView.backgroundImage.image = nil
        view.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: titleViewHeight).isActive = true
        
        imageView = UIImageView(image: UIImage(named:"logo_alpha"))
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 0.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 192).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 192).isActive = true
        imageView.alpha = 1.0
        
        iconView = UIImageView(image: UIImage(named:"mail-1"))
        view.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        iconView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -24.0).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 96).isActive = true
        iconView.alpha = 0.0
        
        sentTitleLabel = UILabel(frame: .zero)
        sentTitleLabel.numberOfLines = 0
        sentTitleLabel.text = "Check your inbox!"
        sentTitleLabel.textColor = UIColor.white
        sentTitleLabel.textAlignment = .center
        sentTitleLabel.font = Fonts.bold(ofSize: 18.0)
        sentTitleLabel.alpha = 0.0
        view.addSubview(sentTitleLabel)
        sentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sentTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sentTitleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 0).isActive = true
        sentTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0).isActive = true
        sentTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0).isActive = true
        
        sentDescLabel = UILabel(frame: .zero)
        sentDescLabel.numberOfLines = 0
        sentDescLabel.text = "We've sent you a link to login with."
        sentDescLabel.textColor = UIColor.white
        sentDescLabel.textAlignment = .center
        sentDescLabel.font = Fonts.regular(ofSize: 18.0)
        sentDescLabel.alpha = 0.0
        view.addSubview(sentDescLabel)
        sentDescLabel.translatesAutoresizingMaskIntoConstraints = false
        sentDescLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sentDescLabel.topAnchor.constraint(equalTo: sentTitleLabel.bottomAnchor, constant: 0.0).isActive = true
        sentDescLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0).isActive = true
        sentDescLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0).isActive = true
        
        submitContainer = UIView()
        view.addSubview(submitContainer)
        submitContainer.translatesAutoresizingMaskIntoConstraints = false
        submitContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
        submitContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        stackBottomConstraint = submitContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        stackBottomConstraint.isActive = true
        
        submitContainer.heightAnchor.constraint(equalToConstant: 54.0).isActive = true
        submitContainer.applyShadow(radius: 6.0, opacity: 0.15, offset: CGSize(width: 0, height: 3), color: .black, shouldRasterize: false)
        
        submitButton = UIButton(type: .custom)
        submitButton.setTitle("Enter", for: .normal)
        submitButton.setTitleColor(accentColor, for: .normal)
        submitButton.titleLabel?.font = Fonts.semiBold(ofSize: 18)
        submitButton.backgroundColor = UIColor.white//hexColor(from:"C0FFE8")
        submitButton.layer.cornerRadius = 4.0
        submitButton.clipsToBounds = true
        
        
        submitContainer.addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.leadingAnchor.constraint(equalTo: submitContainer.leadingAnchor).isActive = true
        submitButton.trailingAnchor.constraint(equalTo: submitContainer.trailingAnchor).isActive = true
        submitButton.topAnchor.constraint(equalTo: submitContainer.topAnchor).isActive = true
        
        submitButton.heightAnchor.constraint(equalToConstant: 54.0).isActive = true
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        textContainer = UIView()
        view.addSubview(textContainer)
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        textContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
        textContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        textContainer.bottomAnchor.constraint(equalTo: submitContainer.topAnchor, constant: -16).isActive = true
        
        textContainer.heightAnchor.constraint(equalToConstant: 54.0).isActive = true
        textContainer.backgroundColor = UIColor.clear
        textContainer.alpha = 0.0
        
        textBubble = UIView()
        textContainer.addSubview(textBubble)
        textBubble.translatesAutoresizingMaskIntoConstraints = false
        textBubble.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor).isActive = true
        textBubble.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor).isActive = true
        textBubble.topAnchor.constraint(equalTo: textContainer.topAnchor).isActive = true
        textBubble.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor).isActive = true
        textBubble.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        textBubble.layer.cornerRadius = 4.0
        textBubble.clipsToBounds = true
        
        textContainer.applyShadow(radius: 6.0, opacity: 0.20, offset: CGSize(width: 0, height: 3), color: .black, shouldRasterize: false)
        
        textField = UITextField(frame: .zero)
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.textColor = UIColor.white
        textField.font = Fonts.regular(ofSize: 18.0)
        textField.placeholder = "Email Address"
        textField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 20.0),
            NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ])
        textBubble.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 8).isActive = true
        textField.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -8).isActive = true
        textField.topAnchor.constraint(equalTo: textContainer.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor).isActive = true
        self.view.layoutIfNeeded()
    }
    
    @objc func handleDismiss() {
        textField.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.dismiss(animated: true, completion: nil)
        })
        
    }
    
    @objc func handleSubmit() {
        if state == .enter {
            state = .enterEmail
            textField.becomeFirstResponder()
            return
        }
        guard let email = textField.text else { return }
        let actionCodeSettings = ActionCodeSettings()

        self.submitButton.isEnabled = false
        self.submitButton.setTitle("Sending...", for: .normal)
        self.submitButton.alpha = 0.67
        actionCodeSettings.url = URL(string: "https://www.example.com")
        // The sign-in operation has to always be completed in the app.
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        actionCodeSettings.setAndroidPackageName("com.example.android",
                                                 installIfNotAvailable: false, minimumVersion: "12")

        Auth.auth().sendSignInLink(toEmail:email,
                                   actionCodeSettings: actionCodeSettings) { error in
                                    // ...
                                    if let error = error {
                                        //self.showMessagePrompt(error.localizedDescription)
                                        self.reset(withError: error.localizedDescription)
                                        return
                                    }
                                    // The link was successfully sent. Inform the user.
                                    // Save the email locally so you don't need to ask the user for it again
                                    // if they open the link on the same device.
                                    UserDefaults.standard.set(email, forKey: "Email")
                                    print("EMAIL TINGS ALL GOOD")
                                    self.proceed()
                                    // ...
        }
    }
    
    func reset(withError msg:String) {
        state = .linkSent
        submitButton.isEnabled = true
        submitButton.setTitle("Send Email Link", for: .normal)
        submitButton.alpha = 1.0
        
        let error = MessageView.viewFromNib(layout: .cardView)
        
        error.configureContent(title: "Error", body: msg, iconImage: Icon.errorLight.image)
        error.button?.removeFromSuperview()
        error.accessibilityPrefix = "error"
        error.configureTheme(.error, iconStyle: .default)
        error.configureDropShadow()
        error.configureTheme(backgroundColor: UIColor(white: 0.4, alpha: 1.0), foregroundColor: .white)
        var config = SwiftMessages.Config.init()
        config.presentationContext = .viewController(self)
        config.duration = .seconds(seconds: 4.0)
        
        SwiftMessages.show(config: config, view: error)
    }
    func proceed() {
        textField.resignFirstResponder()
        submitButton.setTitle("Sent!", for: .normal)
        UIView.animate(withDuration: 0.25, animations: {
            self.iconView.alpha = 1.0
            self.sentTitleLabel.alpha = 1.0
            self.sentDescLabel.alpha = 1.0
        })
    }
    
    @objc func handleEnterLink() {
        guard let link = textField.text else { return }
    }
    
    var hideStatusBar = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pastelView.startStatic()
        
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseOut, animations: {
            self.hideStatusBar = true
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //textField.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        print("keyboardWillShow")
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        if state == .linkSent {
            state = .enterEmail
        }
        if state == .enterEmail {
            textContainer.alpha = 1.0
            textContainer.alpha = 1.0
            submitContainer.alpha = 1.0
            iconView.alpha = 0.0
            sentTitleLabel.alpha = 0.0
            sentDescLabel.alpha = 0.0
            submitButton.setTitle("Send Login Link", for: .normal)
            stackBottomConstraint.constant = -(keyboardSize.height + 24.0)
            submitButton.isEnabled = true
            submitButton.alpha = 1.0
        } else {
            print("WHAT!")
            textContainer.alpha = 0.5
            self.stackBottomConstraint.constant = -16
        }
        
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        print("keyboardWillHide")

        self.textContainer.alpha = 0.5
        self.submitContainer.alpha = 0.5
        
        self.stackBottomConstraint.constant = -16
        self.view.layoutIfNeeded()
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
