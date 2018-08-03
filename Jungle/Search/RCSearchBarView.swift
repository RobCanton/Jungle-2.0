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

class RCSearchBarView:JTitleView, UITextFieldDelegate {
    
    var textFieldContainer:UIView!
    var textBubble:UIView!
    var textField:UITextField!
    
    var containerLeadingAnchor:NSLayoutConstraint!
    var containerTrailingAnchor:NSLayoutConstraint!
    var textFieldLeadingAnchor:NSLayoutConstraint!
    
    var clearButton:UIButton!
    
    weak var delegate:RCSearchBarDelegate?
    
    override init(frame: CGRect, topInset: CGFloat) {
        super.init(frame: frame, topInset: topInset)
        backgroundColor = UIColor.clear
        backgroundImage.image = nil
        leftButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        leftButton.addTarget(self, action: #selector(handleLeftButton), for: .touchUpInside)
        
        rightButton.setTitle("Cancel", for: .normal)
        rightButton.alpha = 0.0
        rightButton.setTitleColor(UIColor.white, for: .normal)
        rightButton.titleLabel?.font = Fonts.medium(ofSize: 16.0)
        rightButton.sizeToFit()
        rightButton.alpha = 0.0
        rightButton.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
        
        textFieldContainer = UIView()
        addSubview(textFieldContainer)
        textFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        containerLeadingAnchor = textFieldContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 44.0)
        containerLeadingAnchor.isActive = true
        
        containerTrailingAnchor = textFieldContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -44.0)
        containerTrailingAnchor.isActive = true
        
        textFieldContainer.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textFieldContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        textBubble = UIView()
        textBubble.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        textFieldContainer.addSubview(textBubble)
        textFieldContainer.clipsToBounds = false
        textFieldContainer.applyShadow(radius: 4.0, opacity: 0.05, offset: CGSize(width: 0, height: 4), color: UIColor.black, shouldRasterize: false)
        
        let containerLayout = textFieldContainer.safeAreaLayoutGuide
        
        textBubble.translatesAutoresizingMaskIntoConstraints = false
        textBubble.leadingAnchor.constraint(equalTo: containerLayout.leadingAnchor, constant: 0.0).isActive = true
        textBubble.trailingAnchor.constraint(equalTo: containerLayout.trailingAnchor, constant: 0.0).isActive = true
        textBubble.topAnchor.constraint(equalTo: containerLayout.topAnchor, constant: 8.0).isActive = true
        textBubble.bottomAnchor.constraint(equalTo: containerLayout.bottomAnchor, constant: -8.0).isActive = true
        
        textField = UITextField(frame: .zero)
        textBubble.addSubview(textField)
        
        let bubbleLayout = textBubble.safeAreaLayoutGuide
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textFieldLeadingAnchor = textField.leadingAnchor.constraint(equalTo: bubbleLayout.leadingAnchor, constant: 12.0)
        textFieldLeadingAnchor.isActive = true
        textField.trailingAnchor.constraint(equalTo: bubbleLayout.trailingAnchor, constant: -44.0).isActive = true
        textField.topAnchor.constraint(equalTo: bubbleLayout.topAnchor, constant: 0.0).isActive = true
        textField.bottomAnchor.constraint(equalTo: bubbleLayout.bottomAnchor, constant: 0.0).isActive = true
        
        
        textBubble.isUserInteractionEnabled = true
        
        let bubbleTap = UITapGestureRecognizer(target: self, action: #selector(beginEditing))
        textBubble.addGestureRecognizer(bubbleTap)
        
        clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(named:"CloseSmall"), for: .normal)
        clearButton.tintColor = UIColor.black
        clearButton.alpha = 0.0
        textBubble.addSubview(clearButton)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.centerYAnchor.constraint(equalTo: textBubble.centerYAnchor).isActive = true
        clearButton.trailingAnchor.constraint(equalTo: textBubble.trailingAnchor, constant: -8).isActive = true
        clearButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        clearButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        clearButton.addTarget(self, action: #selector(handleClearButton), for: .touchUpInside)
    }
    
    
    var gradient:CAGradientLayer?
    
    func addGradient() {
        //gradient?.frame = self.bounds
    }
    
    @objc func beginEditing() {
        
        if !textField.isFirstResponder {
            print("BECOME FIRST RESPONDER")
            textField.becomeFirstResponder()
        }
    }
    
    var defaultTextLeadingConstant:CGFloat = 0.0
    
    func setup(withDelegate delegate:RCSearchBarDelegate) {
        self.delegate = delegate
        textBubble.layer.cornerRadius = 4
        textBubble.clipsToBounds = true
        textField.font = Fonts.medium(ofSize: 16.0)
        textField.textColor = UIColor.white
        textField.delegate = self
        textField.text = "Search"
        textField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 16.0),
            NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ])
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
        //self.textField.text = ""
        self.textField.endEditing(true)
    }
    
    @objc func handleClearButton() {
        self.textField.text = ""
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.searchDidBegin()
        print("textFieldDidBeginEditing")
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.containerLeadingAnchor.constant = 12.0
            self.containerTrailingAnchor.constant = -80.0
            self.textFieldLeadingAnchor.constant = 12.0
            self.layoutIfNeeded()
            self.rightButton.alpha = 1.0
            self.leftButton.alpha = 0.0
            self.clearButton.alpha = 0.75
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
            self.rightButton.alpha = 0.0
            self.clearButton.alpha = 0.0
            self.leftButton.alpha = 1.0
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
    
    func setText(_ text:String) {
        self.textField.text = text
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
        
        self.containerLeadingAnchor.constant = 44.0
        self.containerTrailingAnchor.constant = -44.0
        self.textFieldLeadingAnchor.constant = leadingConstant
        self.layoutIfNeeded()
        self.rightButton.alpha = 0.0
        self.leftButton.alpha = 1.0
    }
}

