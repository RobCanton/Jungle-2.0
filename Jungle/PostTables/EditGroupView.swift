//
//  EditGroupView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-11.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import DynamicButton
import JGProgressHUD
import Firebase

class EditGroupView:UIView, UITextViewDelegate, UITextFieldDelegate {
    
    enum State {
        case info, background, avatar
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
    var descHeightAnchor:NSLayoutConstraint!
    var descPlaceHolder:UILabel!
    var createView:UIView!
    var createButton:UIButton!
    var createBottomAnchor:NSLayoutConstraint!
    var closeHandler:(()->())?
    var createHandler:((_ group:Group)->())?
    var selectedGif:GIF?
    var selectedGradient:[String]?
    
    var gifCollectionNode:GIFCollectionNode!
    var dynamicButton:DynamicButton!
    
    var gradientSelectorNode:GradientSelectorNode!
    
    var descHeightMinimum:CGFloat = 0.0
    var tagsView:TagsFieldView!
    let ACCEPTABLE_CHARACTERS = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789`~!@#$%^&*()_+-=[]{}\\|;:',.\"/"
    
    var needsDisplay:Bool
    
    weak var group:Group?
    init(frame: CGRect, group:Group) {
        needsDisplay = true
        super.init(frame: frame)
        
        self.group = group
        
        preservesSuperviewLayoutMargins = false
        insetsLayoutMarginsFromSafeArea = false
        translatesAutoresizingMaskIntoConstraints = false
        contentView = UIView(frame: CGRect(x: 16, y: 12, width: frame.width - 32, height: frame.height - (12 + 24)))
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
        
        titleView.titleLabel.text = "Edit Group"
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
        titleField.font = Fonts.semiBold(ofSize: 22.0)
        titleField.attributedPlaceholder =
            NSAttributedString(string: "Enter a name...", attributes: [
                NSAttributedStringKey.foregroundColor: tertiaryColor
                ])
        titleField.textColor = UIColor.black
        titleField.autocapitalizationType = .words
        headerRow.addSubview(titleField)
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.leadingAnchor.constraint(equalTo: headerRow.leadingAnchor, constant: 12).isActive = true
        titleField.trailingAnchor.constraint(equalTo: headerRow.trailingAnchor, constant: -12).isActive = true
        titleField.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor).isActive = true
        titleField.delegate = self
        
        titleField.addTarget(self, action: #selector(titleTextDidChange), for: .valueChanged)
        
        descRow = UIView(frame:CGRect(x:0,y:0, width: contentView.bounds.width, height: 240))
        descRow.backgroundColor = UIColor.clear
        
        let descPlaceholderText = "Write a description about your group and tell users what the discussions should be focused on."
        descHeightMinimum = UILabel.size(text: descPlaceholderText, width: UIScreen.main.bounds.width - 32 - 24, font: Fonts.regular(ofSize: 16.0)).height
        
        contentView.addSubview(descRow)
        descRow.translatesAutoresizingMaskIntoConstraints = false
        descRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        descRow.topAnchor.constraint(equalTo: headerRow.bottomAnchor).isActive = true
        descRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        descHeightAnchor = descRow.heightAnchor.constraint(equalToConstant: descHeightMinimum)
        descHeightAnchor.isActive = true
        
        descTextView = UITextView()
        descTextView.font = Fonts.regular(ofSize: 16.0)
        descTextView.textColor = UIColor.black
        descTextView.textContainerInset = .zero
        
        descRow.addSubview(descTextView)
        //descTextView.textAlignment = .center
        descTextView.translatesAutoresizingMaskIntoConstraints = false
        descTextView.leadingAnchor.constraint(equalTo: descRow.leadingAnchor, constant: 8).isActive = true
        descTextView.trailingAnchor.constraint(equalTo: descRow.trailingAnchor, constant: -8).isActive = true
        descTextView.topAnchor.constraint(equalTo: descRow.topAnchor).isActive = true
        descTextView.bottomAnchor.constraint(equalTo: descRow.bottomAnchor).isActive = true
        descTextView.delegate = self
        descTextView.isScrollEnabled = false
        
        descPlaceHolder = UILabel()
        descPlaceHolder.text = descPlaceholderText
        descPlaceHolder.font = Fonts.regular(ofSize: 16.0)
        descPlaceHolder.textColor = tertiaryColor
        descPlaceHolder.numberOfLines = 0
        descRow.addSubview(descPlaceHolder)
        //descPlaceHolder.textAlignment = .center
        descPlaceHolder.translatesAutoresizingMaskIntoConstraints = false
        descPlaceHolder.leadingAnchor.constraint(equalTo: descRow.leadingAnchor, constant: 12).isActive = true
        descPlaceHolder.trailingAnchor.constraint(equalTo: descRow.trailingAnchor, constant: -12).isActive = true
        descPlaceHolder.topAnchor.constraint(equalTo: descRow.topAnchor, constant: 0).isActive = true
        
        tagsView = TagsFieldView(frame:.zero)
        
        contentView.addSubview(tagsView)
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        tagsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tagsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        tagsView.topAnchor.constraint(equalTo: descRow.bottomAnchor).isActive = true
        tagsView.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
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
        
        gradientSelectorNode = GradientSelectorNode()
        
        contentView.addSubview(gradientSelectorNode.view)
        gradientSelectorNode.view.translatesAutoresizingMaskIntoConstraints = false
        gradientSelectorNode.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        gradientSelectorNode.view.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        gradientSelectorNode.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        gradientSelectorNode.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        gradientSelectorNode.alpha = 0.0
        gradientSelectorNode.delegate = self
        
        self.layoutIfNeeded()
        
        titleField.text = group.name
        
        tagsView.tags = group.tags
        tagsView.collectionNode.reloadData()
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
    
    func checkBackground() {
        createButton.isEnabled = selectedGradient != nil
    }
    
    func checkGroup() {
        let title = titleField.text ?? ""
        let desc = descTextView.text ?? ""
        let avatar = selectedGif
        let background = selectedGradient
        
        let isComplete = !title.isEmpty && title.count >= 3 &&
            title.count <= 30 && !desc.isEmpty && background != nil && avatar != nil
        createButton.isEnabled = isComplete
    }
    
    @objc func handleClose() {
        if state == .info {
            closeHandler?()
        } else if state == .background {
            state = .info
            titleView.titleLabel.text = "Edit Group"
            titleField.becomeFirstResponder()
            
            createButton.setTitle("Next", for: .normal)
            createButton.setTitle("Next", for: .disabled)
            checkForm()
            dynamicButton.setStyle(.close, animated: true)
            UIView.animate(withDuration: 0.25, animations: {
                self.titleField.alpha = 1.0
                self.descTextView.alpha = 1.0
                self.tagsView.alpha = 1.0
                self.gradientSelectorNode.alpha = 0.0
                self.gifCollectionNode.alpha = 0.0
            })
        } else {
            state = .background
            titleView.titleLabel.text = "Select a background"
            
            createButton.setTitle("Next", for: .normal)
            createButton.setTitle("Next", for: .disabled)
            checkBackground()
            
            dynamicButton.setStyle(.caretLeft, animated: true)
            UIView.animate(withDuration: 0.25, animations: {
                self.gifCollectionNode.alpha = 0.0
                self.gradientSelectorNode.alpha = 1.0
            })
        }
        
    }
    
    @objc func handleNext() {
        if state == .info {
            state = .background
            titleView.titleLabel.text = "Select a background"
            dynamicButton.setStyle(.caretLeft, animated: true)
            titleField.resignFirstResponder()
            descTextView.resignFirstResponder()
            let _ = tagsView.resignFirstResponder()
            checkBackground()
            createButton.setTitle("Next", for: .normal)
            UIView.animate(withDuration: 0.25, animations: {
                self.titleField.alpha = 0.0
                self.descTextView.alpha = 0.0
                self.tagsView.alpha = 0.0
                self.gifCollectionNode.alpha = 0.0
                self.gradientSelectorNode.alpha = 1.0
            })
        } else if state == .background {
            state = .avatar
            titleView.titleLabel.text = "Select an Avatar"
            gifCollectionNode.searchTapped(titleField.text ?? "")
            createButton.isEnabled = false
            createButton.setTitle("Update Group", for: .normal)
            createButton.setTitle("Update Group", for: .disabled)
            UIView.animate(withDuration: 0.25, animations: {
                self.gradientSelectorNode.alpha = 0.0
                self.gifCollectionNode.alpha = 1.0
            })
        } else {
            //self.isUserInteractionEnabled = false
            createButton.isEnabled = false
            createButton.setTitle("Updating Group...", for: .normal)
            createButton.setTitle("Updating Group...", for: .disabled)
            gifCollectionNode.isUserInteractionEnabled = false
            dynamicButton.isUserInteractionEnabled = false
            
            
            guard let group = self.group else { return }
            guard let top = UIApplication.topViewController() else { return }
            let hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = "Updating Group..."
            hud.show(in: top.view, animated: true)
            
            let data:[String:Any] = [
                "groupID": group.id,
                "name": titleField.text!,
                "desc": descTextView.text!,
                "tags": tagsView.tags,
                "gradient": selectedGradient!,
                "avatar": [
                    "low": selectedGif!.low_url.absoluteString,
                    "high": selectedGif!.high_url.absoluteString
                    ] as [String:Any]
            ]
            
            functions.httpsCallable("updateGroup").call(data) { result, error in
                if let data = result?.data as? [String:Any],
                    let success = data["success"] as? Bool, success,
                    let groupRaw = data["group"] as? [String:Any],
                    let groupID = groupRaw["id"] as? String,
                    let groupData = groupRaw["data"] as? [String:Any],
                    let group = Group.parse(id: groupID, groupData) {
                    //GroupsService.addMyGroup(group)
                    hud.dismiss()
                    self.createHandler?(group)
                    print("ALL GOOD!")
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
        
        let height = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.infinity)).height
        
        if height > maxDescHeight {
            descHeightAnchor.constant = maxDescHeight
            descTextView.isScrollEnabled = true
        } else if textView.text.isEmpty {
            descHeightAnchor.constant = descHeightMinimum
            descTextView.isScrollEnabled = false
        } else {
            descHeightAnchor.constant = height
            descTextView.isScrollEnabled = false
        }
        
        self.layoutIfNeeded()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            let path = IndexPath(row: tagsView.tags.count, section: 0)
            
            tagsView.collectionNode.scrollToItem(at: path, at: .centeredHorizontally, animated: false)
            let node = tagsView.collectionNode.nodeForItem(at: path) as! GroupTagFieldCellNode
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                node.textField.becomeFirstResponder()
            })
            
            return false
        }
        
        if textView.text.count + text.count > 300 {
            return false
        }
        
        return true
    }
    
    var keyboardHeight:CGFloat = 0.0
    var maxDescHeight:CGFloat = 0.0
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        createBottomAnchor.constant = -keyboardSize.height - 16
        createButton.alpha = 1.0
        keyboardHeight = keyboardSize.height + 16 + 16 + 44
        maxDescHeight = UIScreen.main.bounds.height - 8 - 44 - 50 - 4 - 44 - keyboardHeight
        
       
        self.layoutIfNeeded()
        DispatchQueue.main.async {
            if self.needsDisplay, let group = self.group {
                self.needsDisplay = false
                self.descTextView.text = group.desc
                self.textViewDidChange(self.descTextView)
            }
        }
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        createBottomAnchor.constant = -32
        self.layoutIfNeeded()
    }
}

extension EditGroupView: GIFCollectionDelegate {
    func didSelect(gif: GIF?) {
        selectedGif = gif
        checkGroup()
    }
}


extension EditGroupView: GradientSelectorDelegate {
    func didSelect(gradient: [String]?) {
        selectedGradient = gradient
        checkBackground()
    }
}
