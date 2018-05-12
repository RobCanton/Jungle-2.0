//
//  RCSearchBarView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-04-13.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol RCSearchBarDelegate:class {
    func handleLeftButton()
    func searchTextDidChange(_ text: String?)
    func searchDidBegin()
    func searchDidEnd()
    func searchTapped(_ text:String)
}

class RCSearchBarView:UIView, UITextFieldDelegate {
    
    var textFieldContainer:UIView!
    var textBubble:UIView!
    var textField:UITextField!
    var leftButtonItem:UIButton!
    var rightButtonItem:UIButton!
    var cancelButton:UIButton!
    
    var containerLeadingAnchor:NSLayoutConstraint!
    var containerTrailingAnchor:NSLayoutConstraint!
    var textFieldLeadingAnchor:NSLayoutConstraint!
    
    weak var delegate:RCSearchBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        let layoutGuide = safeAreaLayoutGuide
        
        leftButtonItem = UIButton(type: .custom)
        leftButtonItem.tintColor = UIColor.black
        addSubview(leftButtonItem)
        leftButtonItem.translatesAutoresizingMaskIntoConstraints = false
        leftButtonItem.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        leftButtonItem.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        leftButtonItem.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        leftButtonItem.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        leftButtonItem.addTarget(self, action: #selector(handleLeftButton), for: .touchUpInside)
        
        cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        cancelButton.titleLabel?.font = Fonts.medium(ofSize: 16.0)
        addSubview(cancelButton)
        cancelButton.sizeToFit()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -12.0).isActive = true
        cancelButton.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
        cancelButton.alpha = 0.0
        
        textFieldContainer = UIView()
        addSubview(textFieldContainer)
        textFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        containerLeadingAnchor = textFieldContainer.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 44.0)
        containerLeadingAnchor.isActive = true
        
        containerTrailingAnchor = textFieldContainer.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -44.0)
        containerTrailingAnchor.isActive = true
        
        textFieldContainer.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        textFieldContainer.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        
        textBubble = UIView()
        textFieldContainer.addSubview(textBubble)
        
        let containerLayout = textFieldContainer.safeAreaLayoutGuide
        
        textBubble.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        textBubble.translatesAutoresizingMaskIntoConstraints = false
        textBubble.leadingAnchor.constraint(equalTo: containerLayout.leadingAnchor, constant: 0.0).isActive = true
        textBubble.trailingAnchor.constraint(equalTo: containerLayout.trailingAnchor, constant: 0.0).isActive = true
        textBubble.topAnchor.constraint(equalTo: containerLayout.topAnchor, constant: 4.0).isActive = true
        textBubble.bottomAnchor.constraint(equalTo: containerLayout.bottomAnchor, constant: -4.0).isActive = true
        
        textField = UITextField(frame: .zero)
        textBubble.addSubview(textField)
        
        let bubbleLayout = textBubble.safeAreaLayoutGuide
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textFieldLeadingAnchor = textField.leadingAnchor.constraint(equalTo: bubbleLayout.leadingAnchor, constant: 12.0)
        textFieldLeadingAnchor.isActive = true
        textField.trailingAnchor.constraint(equalTo: bubbleLayout.trailingAnchor, constant: -12.0).isActive = true
        textField.topAnchor.constraint(equalTo: bubbleLayout.topAnchor, constant: 0.0).isActive = true
        textField.bottomAnchor.constraint(equalTo: bubbleLayout.bottomAnchor, constant: 0.0).isActive = true
        
        
    }
    
    var defaultTextLeadingConstant:CGFloat = 0.0
    
    func setup(withDelegate delegate:RCSearchBarDelegate) {
        self.delegate = delegate
        textBubble.layer.cornerRadius = textBubble.bounds.height / 2
        textBubble.clipsToBounds = true
        textField.font = Fonts.regular(ofSize: 16.0)
        textField.delegate = self
        textField.placeholder = "Search"
        textField.text = "Search"
        let width = textWidth
        
        var leadingConstant:CGFloat = 12.0
        let bubbleWidth = textBubble.bounds.width - 24.0
        if width < bubbleWidth {
            leadingConstant += (bubbleWidth - width) / 2
        }
        defaultTextLeadingConstant = leadingConstant
        textFieldLeadingAnchor.constant = defaultTextLeadingConstant
        textField.text = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func handleLeftButton() {
        delegate?.handleLeftButton()
    }
    
    @objc func handleCancelButton(_ sender: Any) {
        self.textField.text = ""
        self.textField.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.searchDidBegin()
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.containerLeadingAnchor.constant = 12.0
            self.containerTrailingAnchor.constant = -80.0
            self.textFieldLeadingAnchor.constant = 12.0
            self.layoutIfNeeded()
            self.cancelButton.alpha = 1.0
        }, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.searchDidEnd()
        let width = textWidth
        var leadingConstant:CGFloat = 12.0
        if width == 0.0 {
            leadingConstant = defaultTextLeadingConstant
        } else {
            let bubbleWidth = textBubble.bounds.width - 24.0
            if width < bubbleWidth {
                leadingConstant += (bubbleWidth - width) / 2
            }
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.containerLeadingAnchor.constant = 44.0
            self.containerTrailingAnchor.constant = -44.0
            self.textFieldLeadingAnchor.constant = leadingConstant
            self.layoutIfNeeded()
            self.cancelButton.alpha = 0.0
        }, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        delegate?.searchTapped(textField.text ?? "")
        return true
    }
    
    var textWidth:CGFloat {
        return UILabel.size(text: textField.text ?? "", height: 44.0, font: textField.font!).width
    }
}

