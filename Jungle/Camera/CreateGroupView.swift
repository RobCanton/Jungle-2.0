//
//  CreateGroupView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-03.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import DynamicButton
import JGProgressHUD
import Firebase

class CreateGroupView:UIView, UITextViewDelegate, UITextFieldDelegate {
    
    enum State {
        case info, avatar
    }
    
    var state = State.info
    var contentView:UIView!
    
    var collectionNode:GIFCollectionNode!
    var titleView:JTitleView!
    
    var avatarView:ASNetworkImageNode!
    var headerRow:UIView!
    var descRow:UIView!
    var titleField:UITextField!
    var descTextView:UITextView!
    var descPlaceHolder:UILabel!
    var createView:UIView!
    var createButton:UIButton!
    var createBottomAnchor:NSLayoutConstraint!
    var closeHandler:(()->())?
    var createHandler:((_ group:Group)->())?
    var selectedGif:GIF?
    
    var gifCollectionNode:GIFCollectionNode!
    var dynamicButton:DynamicButton!
    
    var infoLabel:UILabel!
    
    let ACCEPTABLE_CHARACTERS = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789`~!@#$%^&*()_+-=[]{}\\|;:',.\"/"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        preservesSuperviewLayoutMargins = false
        insetsLayoutMarginsFromSafeArea = false
        translatesAutoresizingMaskIntoConstraints = false
        contentView = UIView()
        contentView.backgroundColor = UIColor.white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true
        
        contentView.layer.cornerRadius = 12.0
        contentView.clipsToBounds = true
        
        titleView = JTitleView(frame: .zero, topInset: 0)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundImage.image = nil
        titleView.backgroundColor = UIColor.clear
        contentView.addSubview(titleView)
        
        dynamicButton = DynamicButton(style: .close)
        titleView.addSubview(dynamicButton)
        dynamicButton.translatesAutoresizingMaskIntoConstraints = false
        dynamicButton.centerXAnchor.constraint(equalTo: titleView.leftButton.centerXAnchor).isActive = true
        dynamicButton.centerYAnchor.constraint(equalTo: titleView.leftButton.centerYAnchor).isActive = true
        dynamicButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        dynamicButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        dynamicButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        
        titleView.titleLabel.text = "Create a Group"
        titleView.titleLabel.font = Fonts.bold(ofSize: 16.0)
        titleView.titleLabel.textColor = UIColor.black
        titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        headerRow = UIView()
        headerRow.backgroundColor = UIColor.clear

        contentView.addSubview(headerRow)
        headerRow.translatesAutoresizingMaskIntoConstraints = false
        headerRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        headerRow.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 4.0).isActive = true
        headerRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        headerRow.heightAnchor.constraint(equalToConstant: 50).isActive = true

        titleField = UITextField()
        //titleField.textAlignment = .center

        titleField.font = Fonts.semiBold(ofSize: 22.0)
        titleField.keyboardAppearance = .dark
        titleField.attributedPlaceholder =
            NSAttributedString(string: "Enter a name...", attributes: [
                NSAttributedStringKey.foregroundColor: tertiaryColor
                ])
        titleField.textColor = UIColor.black
        headerRow.addSubview(titleField)
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.leadingAnchor.constraint(equalTo: headerRow.leadingAnchor, constant: 12).isActive = true
        titleField.trailingAnchor.constraint(equalTo: headerRow.trailingAnchor, constant: -12).isActive = true
        titleField.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor).isActive = true
        titleField.delegate = self
        
        titleField.addTarget(self, action: #selector(titleTextDidChange), for: .valueChanged)

        descRow = UIView()
        descRow.backgroundColor = UIColor.clear

        contentView.addSubview(descRow)
        descRow.translatesAutoresizingMaskIntoConstraints = false
        descRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        descRow.topAnchor.constraint(equalTo: headerRow.bottomAnchor).isActive = true
        descRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        descRow.heightAnchor.constraint(equalToConstant: 240).isActive = true

        descTextView = UITextView()
        descTextView.font = Fonts.regular(ofSize: 15.0)
        descTextView.textColor = UIColor.black
        descTextView.textContainerInset = .zero
        descTextView.keyboardAppearance = .dark
        descRow.addSubview(descTextView)
        //descTextView.textAlignment = .center
        descTextView.translatesAutoresizingMaskIntoConstraints = false
        descTextView.leadingAnchor.constraint(equalTo: descRow.leadingAnchor, constant: 8).isActive = true
        descTextView.trailingAnchor.constraint(equalTo: descRow.trailingAnchor, constant: -12).isActive = true
        descTextView.topAnchor.constraint(equalTo: descRow.topAnchor, constant: 0).isActive = true
        descTextView.bottomAnchor.constraint(equalTo: descRow.bottomAnchor, constant: -8).isActive = true
        descTextView.delegate = self

        descPlaceHolder = UILabel()
        descPlaceHolder.text = "Write a description about your group and tell users what the discussions should be focused on."
        descPlaceHolder.font = Fonts.regular(ofSize: 14.0)
        descPlaceHolder.textColor = tertiaryColor
        descPlaceHolder.numberOfLines = 0
        descRow.addSubview(descPlaceHolder)
        //descPlaceHolder.textAlignment = .center
        descPlaceHolder.translatesAutoresizingMaskIntoConstraints = false
        descPlaceHolder.leadingAnchor.constraint(equalTo: descRow.leadingAnchor, constant: 12).isActive = true
        descPlaceHolder.trailingAnchor.constraint(equalTo: descRow.trailingAnchor, constant: -12).isActive = true
        descPlaceHolder.topAnchor.constraint(equalTo: descRow.topAnchor, constant: 0).isActive = true

        createButton = UIButton(type: .custom)
        createButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16)
        createButton.setTitle("Next", for: .normal)
        createButton.setTitle("Next", for: .disabled)
        createButton.setTitleColor(UIColor.white, for: .normal)
        createButton.backgroundColor = tertiaryColor
        createButton.isEnabled = false
        createButton.sizeToFit()
        
        createButton.layer.cornerRadius = 22
        createButton.clipsToBounds = true
        createButton.setBackgroundImage(UIImage(named:"GreenBox"), for: .normal)
        createButton.setBackgroundImage(nil, for: .disabled)
        createView = UIView()
        addSubview(createView)
        createView.translatesAutoresizingMaskIntoConstraints = false
        createView.heightAnchor.constraint(equalToConstant: 44).isActive = true

        createView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.0).isActive = true
        createView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.0).isActive = true

        createBottomAnchor = createView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32)
        createBottomAnchor.isActive = true
        createView.addSubview(createButton)
        createView.applyShadow(radius: 8.0, opacity: 0.125, offset: CGSize(width:0, height: 4), color: .black, shouldRasterize: false)

        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.leadingAnchor.constraint(equalTo: createView.leadingAnchor).isActive = true
        createButton.trailingAnchor.constraint(equalTo: createView.trailingAnchor).isActive = true
        createButton.topAnchor.constraint(equalTo: createView.topAnchor).isActive = true
        createButton.bottomAnchor.constraint(equalTo: createView.bottomAnchor).isActive = true

        createButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        
        gifCollectionNode = GIFCollectionNode()
        contentView.addSubview(gifCollectionNode.view)
        gifCollectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        gifCollectionNode.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        gifCollectionNode.view.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        gifCollectionNode.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        gifCollectionNode.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        gifCollectionNode.alpha = 0.0
        gifCollectionNode.delegate = self
        
        infoLabel = UILabel()
        infoLabel.text = "Groups that are inactive for a period of time will be automatically flagged for deletion."
        infoLabel.font = Fonts.regular(ofSize: 14.0)
        infoLabel.textColor = tertiaryColor
        infoLabel.numberOfLines = 0
        addSubview(infoLabel)
        //infoLabel.textAlignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.leadingAnchor.constraint(equalTo: descRow.leadingAnchor, constant: 12).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: descRow.trailingAnchor, constant: -12).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -8).isActive = true
        self.layoutIfNeeded()
    }
    
    
    func willAppear() {
        titleField.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func checkForm() {
        let title = titleField.text ?? ""
        let desc = descTextView.text ?? ""
        
        let isComplete = !title.isEmpty && title.count >= 3 && title.count <= 30 && !desc.isEmpty
        createButton.isEnabled = isComplete
    }
    
    func checkGroup() {
        let title = titleField.text ?? ""
        let desc = descTextView.text ?? ""
        let avatar = selectedGif
        
        let isComplete = !title.isEmpty && title.count >= 3 &&
            title.count <= 30 && !desc.isEmpty && avatar != nil
        createButton.isEnabled = isComplete
    }
    
    @objc func handleNext() {
        if state == .info {
            state = .avatar
            titleView.titleLabel.text = "Select an Avatar"
            dynamicButton.setStyle(.caretLeft, animated: true)
            titleField.resignFirstResponder()
            descTextView.resignFirstResponder()
            gifCollectionNode.searchTapped(titleField.text ?? "")
            createButton.isEnabled = false
            createButton.setTitle("Create Group", for: .normal)
            createButton.setTitle("Create Group", for: .disabled)
            UIView.animate(withDuration: 0.25, animations: {
                self.titleField.alpha = 0.0
                self.descTextView.alpha = 0.0
                self.gifCollectionNode.alpha = 1.0
            })
        } else {
            //self.isUserInteractionEnabled = false
            createButton.isEnabled = false
            createButton.setTitle("Creating Group...", for: .normal)
            createButton.setTitle("Creating Group...", for: .disabled)
            gifCollectionNode.isUserInteractionEnabled = false
            dynamicButton.isUserInteractionEnabled = false
            
            guard let top = UIApplication.topViewController() else { return }
            let hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = "Creating Group..."
            hud.show(in: top.view, animated: true)
            
            let data:[String:Any] = [
                "name": titleField.text!,
                "desc": descTextView.text!,
                "avatar": [
                    "low": selectedGif!.low_url.absoluteString,
                    "high": selectedGif!.high_url.absoluteString
                    ] as [String:Any]
            ]
            
            functions.httpsCallable("createGroup").call(data) { result, error in
                if let data = result?.data as? [String:Any],
                    let success = data["success"] as? Bool, success,
                    let groupRaw = data["group"] as? [String:Any],
                    let groupID = groupRaw["id"] as? String,
                    let groupData = groupRaw["data"] as? [String:Any],
                    let group = Group.parse(id: groupID, groupData) {
                    print("DATA!: \(data)")
                    GroupsService.addMyGroup(group)
                    hud.dismiss()
                    self.createHandler?(group)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descTextView.becomeFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if newLength > 30 { return false }
        let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
        
        return (string == filtered)
    }
    
    @objc func titleTextDidChange() {
        checkForm()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        descPlaceHolder.isHidden = !textView.text.isEmpty
        checkForm()
    }
    
    @objc func handleClose() {
        if state == .info {
            closeHandler?()
        } else {
            state = .info
            titleView.titleLabel.text = "Create a Group"
            titleField.becomeFirstResponder()
            
            createButton.setTitle("Next", for: .normal)
            createButton.setTitle("Next", for: .disabled)
            checkForm()
            dynamicButton.setStyle(.close, animated: true)
            UIView.animate(withDuration: 0.25, animations: {
                self.titleField.alpha = 1.0
                self.descTextView.alpha = 1.0
                self.gifCollectionNode.alpha = 0.0
            })
        }
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        createBottomAnchor.constant = -keyboardSize.height - 16
        createButton.alpha = 1.0
        self.layoutIfNeeded()
        
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        createBottomAnchor.constant = -32
        self.layoutIfNeeded()
    }
}

extension CreateGroupView: GIFCollectionDelegate {
    func didSelect(gif: GIF?) {
        selectedGif = gif
        checkGroup()
    }
}

