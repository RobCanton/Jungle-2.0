//
//  CreateProfileViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-08-09.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Pastel
import Firebase
import SwiftMessages


class CreateProfileViewController:UIViewController {
    
    var pastelView:PastelView!
    var avatarView:UIView!
    var avatarImageView:UIImageView!
    var bannerView:UIView!
    var titleView:UIView!
    var contentView:UIView!
    
    var textContainer:UIView!
    var textBubble:UIView!
    var textField:UITextField!
    
    var submitContainer:UIView!
    var submitButton:UIButton!
    var iconView:UIImageView!
    
    var stackBottomConstraint:NSLayoutConstraint!
    
    var imagePicker:UIImagePickerController!
    var skipActivityIndicator:UIActivityIndicatorView!
    var skipButton:UIButton!
    
    var cancelButton:UIButton!
    
    var popupMode = false
    
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    
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
        view.addSubview(pastelView)
        
        bannerView = UIView()
        //bannerView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.2 + 44).isActive = true
        
        view.backgroundColor = hexColor(from: "#EFEFEF")
        
        titleView = UIView()
        bannerView.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.topAnchor.constraint(equalTo: bannerView.topAnchor).isActive = true
        titleView.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        skipButton = UIButton(type: .custom)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(UIColor.white, for: .normal)
        skipButton.titleLabel?.font = Fonts.bold(ofSize: 17.0)
        titleView.addSubview(skipButton)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -20).isActive = true
        skipButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        skipButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        
        cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.font = Fonts.medium(ofSize: 17.0)
        titleView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 20).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        
        skipActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        view.addSubview(skipActivityIndicator)
        skipActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        skipActivityIndicator.centerXAnchor.constraint(equalTo: skipButton.centerXAnchor).isActive = true
        skipActivityIndicator.centerYAnchor.constraint(equalTo: skipButton.centerYAnchor).isActive = true
        skipActivityIndicator.hidesWhenStopped = true
        skipActivityIndicator.stopAnimating()
        
        contentView = UIView()
        bannerView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor).isActive = true
        
        avatarView = UIView()
        
        contentView.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        avatarView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        avatarView.widthAnchor.constraint(equalToConstant: 96).isActive = true
        
        avatarImageView = UIImageView(image: nil)
        avatarImageView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        avatarView.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.leadingAnchor.constraint(equalTo: avatarView.leadingAnchor).isActive = true
        avatarImageView.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: avatarView.topAnchor).isActive = true
        avatarImageView.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor).isActive = true
        
        avatarImageView.layer.cornerRadius = 96 / 2
        avatarImageView.clipsToBounds = true
        
        iconView = UIImageView(image: UIImage(named: "CameraLarge"))
        
        avatarView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor).isActive = true
        iconView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        avatarView.applyShadow(radius: 6.0, opacity: 0.20, offset: CGSize(width: 0, height: 2.0), color: .black, shouldRasterize: false)
        avatarView.isUserInteractionEnabled = true
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        avatarView.addGestureRecognizer(avatarTap)
        
        submitContainer = UIView()
        view.addSubview(submitContainer)
        submitContainer.translatesAutoresizingMaskIntoConstraints = false
        submitContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
        submitContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        stackBottomConstraint = submitContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        stackBottomConstraint.isActive = true
        
        submitContainer.heightAnchor.constraint(equalToConstant: 48).isActive = true
        submitContainer.applyShadow(radius: 6.0, opacity: 0.15, offset: CGSize(width: 0, height: 3), color: .black, shouldRasterize: false)
        
        submitButton = UIButton(type: .custom)
        submitButton.setTitle("Create Profile", for: .normal)
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
        submitButton.bottomAnchor.constraint(equalTo: submitContainer.bottomAnchor).isActive = true
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        toggleSubmitButton(enabled: false)
        
        textContainer = UIView()
        view.addSubview(textContainer)
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        textContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
        textContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        textContainer.bottomAnchor.constraint(equalTo: submitContainer.topAnchor, constant: -16).isActive = true
        
        textContainer.heightAnchor.constraint(equalToConstant: 48).isActive = true
        textContainer.backgroundColor = UIColor.clear
        
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
        textField.textAlignment = .center
        textField.font = Fonts.regular(ofSize: 17.0)
        textField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 20.0),
            NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ])
        textBubble.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 8).isActive = true
        textField.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -8).isActive = true
        textField.topAnchor.constraint(equalTo: textContainer.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor).isActive = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.delegate = self
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pastelView.startStatic()
        
        if popupMode {
            skipButton.isHidden = true
            cancelButton.isHidden = false
        } else {
            skipButton.isHidden = false
            cancelButton.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        textField.becomeFirstResponder()
    }
    
    

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        print("keyboardWillShow")
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        stackBottomConstraint.constant = -(keyboardSize.height + 24.0)
        
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        print("keyboardWillHide")
        
        self.stackBottomConstraint.constant = -16
        self.view.layoutIfNeeded()
    }
    
    @objc func openImagePicker() {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleSubmit() {
        
        guard let avatar = avatarImageView.image else { return }
        guard let username = textField.text else { return }
        
        view.isUserInteractionEnabled = false
        toggleSubmitButton(enabled: false)
        submitButton.setTitle("Creating...", for: .normal)
        
        UserService.uploadProfileImage(avatar, quality: .high) { _ in
            UserService.uploadProfileImage(avatar, quality: .low) { _ in
                
                let data:[String:Any] = [
                    "username": username
                ]
                
                functions.httpsCallable("createUserProfile").call(data) { result, error in
                    if let data = result?.data as? [String:Any] {
                        print("CREATED PROFILE: \(data)")
                        UserService.currentUser?.profile = Profile.parse(data)
                        if self.popupMode {
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            appProtocol?.openMainView()
                        }
                        
                    } else {
                        self.showError(error?.localizedDescription ?? "Please try again")
                    }
                }
                
            }
        }
    }
    
    
    func showError(_ msg:String) {
        view.isUserInteractionEnabled = true
        let error = MessageView.viewFromNib(layout: .cardView)
        
        error.configureContent(title: "Error", body: msg, iconImage: Icon.errorLight.image)
        error.button?.removeFromSuperview()
        error.accessibilityPrefix = "error"
        error.configureTheme(.error, iconStyle: .default)
        error.configureDropShadow()
        error.configureTheme(backgroundColor: UIColor(white: 0.4, alpha: 1.0), foregroundColor: .white)
        var config = SwiftMessages.Config.init()
        config.presentationContext = .viewController(self)
        config.duration = .seconds(seconds: 5.0)
        
        SwiftMessages.show(config: config, view: error)
        
        toggleSubmitButton(enabled: true)
        submitButton.setTitle("Create Profile", for: .normal)
    }
    
    @objc func handleSkip() {
        print("SKIP!")
        view.isUserInteractionEnabled = false
        skipButton.isHidden = true
        skipActivityIndicator.startAnimating()
        
        functions.httpsCallable("skipCreateProfile").call { result, error in
            appProtocol?.openMainView()
        }
    }
    
    @objc func handleCancel() {
        print("CANCEL!")
        textField.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.dismiss(animated: true, completion: nil)
        })
        
    }
}


extension CreateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.iconView.isHidden = true
            self.avatarImageView.image = pickedImage
            let text = textField.text ?? ""
            toggleSubmitButton(enabled: !text.isEmpty && avatarImageView.image != nil)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension CreateProfileViewController: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField:UITextField) {
        let text = textField.text ?? ""
        toggleSubmitButton(enabled: text.count >= 6 && avatarImageView.image != nil)
    }
    
    func toggleSubmitButton(enabled: Bool) {
        self.submitButton.isEnabled = enabled
        self.submitButton.alpha = enabled ? 1.0 : 0.67
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if newLength > 20 { return false }
        let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
        
        return (string == filtered)
    }
    
}

enum ProfileImageQuality:String {
    case high = "high"
    case low = "low"
}

