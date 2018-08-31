//
//  GlassCommentBar.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-04.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class GlassCommentBar:UIView, UITextViewDelegate {
    
    var textBox:UIView!
    var textView:UITextView!
    
    var textBoxTrailingAnchor:NSLayoutConstraint!
    var textHeightAnchor:NSLayoutConstraint!
    var sendButton:UIButton!
    
    var barHeightAnchor:NSLayoutConstraint!
    var textHeight:CGFloat = 0.0
    
    var placeHolderLabel:UILabel!
    var minimumHeight:CGFloat = 0
    
    var calculatedHeight:CGFloat {
        return textHeight + 8.0
    }
    
    var anonSwitch:AnonSwitch!
    
    weak var delegate:CommentBarDelegate?
    
    var dividerNode:UIView!
    var backView:UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
        self.insetsLayoutMarginsFromSafeArea = false
        self.preservesSuperviewLayoutMargins = false
        
        backView = UIView(frame: bounds)
        backView.backgroundColor = UIColor.white
        addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        dividerNode = UIView()
        dividerNode.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        addSubview(dividerNode)
        dividerNode.translatesAutoresizingMaskIntoConstraints = false
        dividerNode.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        dividerNode.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dividerNode.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0).isActive = true
        dividerNode.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0).isActive = true
        
        anonSwitch = AnonSwitch(frame: .zero)
        addSubview(anonSwitch)
        anonSwitch.translatesAutoresizingMaskIntoConstraints = false
        anonSwitch.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        anonSwitch.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        anonSwitch.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        anonSwitch.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        textBox = UIView()
        addSubview(textBox)
        textBox.translatesAutoresizingMaskIntoConstraints = false
        textBox.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        textBox.layer.cornerRadius = 4.0
        textBox.clipsToBounds = true
        textBox.leadingAnchor.constraint(equalTo: anonSwitch.trailingAnchor, constant: 2.0).isActive = true
        textBox.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.0).isActive = true
        
        placeHolderLabel = UILabel(frame: .zero)
        placeHolderLabel.textColor = UIColor.gray
        textBox.addSubview(placeHolderLabel)
        placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeHolderLabel.font = Fonts.regular(ofSize: 15.0)
        placeHolderLabel.text = "Reply..."
        placeHolderLabel.leadingAnchor.constraint(equalTo: textBox.leadingAnchor, constant: 9).isActive = true
        placeHolderLabel.topAnchor.constraint(equalTo: textBox.topAnchor, constant: 0).isActive = true
        placeHolderLabel.bottomAnchor.constraint(equalTo: textBox.bottomAnchor, constant: 0).isActive = true
        placeHolderLabel.trailingAnchor.constraint(equalTo: textBox.trailingAnchor, constant: 0).isActive = true
        
        textView = UITextView(frame: .zero)
        textView.backgroundColor = .clear
        textView.textColor = UIColor.black
        textView.font = Fonts.regular(ofSize: 15.0)
        textBox.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: textBox.leadingAnchor, constant: 4).isActive = true
        textView.topAnchor.constraint(equalTo: textBox.topAnchor, constant: 0).isActive = true
        textView.bottomAnchor.constraint(equalTo: textBox.bottomAnchor, constant: 0).isActive = true
        textHeightAnchor = textView.heightAnchor.constraint(equalToConstant: 42)
        textHeightAnchor.isActive = true
        textView.delegate = self
        textView.returnKeyType = .send
        textView.keyboardAppearance = .light
        textView.isScrollEnabled = false
        
        
        sendButton = UIButton(type: .custom)
        sendButton.setImage(UIImage(named:"SendSimple"), for: .normal)
        sendButton.isHidden = true
        textBox.addSubview(sendButton)
        
        barHeightAnchor = self.heightAnchor.constraint(equalToConstant: 50.0)
        barHeightAnchor.isActive = true
        prepareTextView()
        minimumHeight = calculatedHeight
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 4.0).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: textBox.bottomAnchor, constant: -2.0).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: textBox.trailingAnchor, constant: -2.0).isActive = true
        sendButton.backgroundColor = accentColor
        sendButton.heightAnchor.constraint(equalToConstant: textHeight - 4.0).isActive = true
        sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor, multiplier: 1.0).isActive = true
        sendButton.layer.cornerRadius = 4.0
        sendButton.clipsToBounds = true
        sendButton.addTarget(self, action: #selector(sendText), for: .touchUpInside) 
    }
    
    var activeColor:UIColor!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setToCaptionMode() {
        textView.keyboardAppearance = .dark
        dividerNode.backgroundColor = UIColor.white
        textBox.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.black.withAlphaComponent(0.67)
        textView.textColor = UIColor.white
        placeHolderLabel.text = "Write a caption..."
        placeHolderLabel.font = Fonts.regular(ofSize: 16.0)
        placeHolderLabel.textColor = UIColor(white: 1.0, alpha: 0.67)
        textView.font = Fonts.regular(ofSize: 16.0)
        textView.keyboardType = .twitter
        backView.isHidden = true
        //textView.returnKeyType = .done
    }
    
    
    func prepareTextView() {
        textView.text = "Hello!"
        textViewDidChange(textView)
        textView.text = ""
        textViewDidChange(textView)
        self.sendButton.backgroundColor = hexColor(from: "BEBEBE")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLabel.isHidden = textView.text.count > 0
        let height = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.infinity)).height
        self.textHeight = height
        textHeightAnchor.constant = textHeight
        barHeightAnchor.constant = calculatedHeight
        
        if textView.text.count > 0, activeColor != nil {
            UIView.animate(withDuration: 0.2, animations: {
                self.sendButton.backgroundColor = self.activeColor
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.sendButton.backgroundColor = hexColor(from: "BEBEBE")
            })
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendText(textView)
            return false
        }
        return true
    }
    
    @objc func sendText(_ sender:Any) {
        guard textView.text.count > 0 else { return }
        delegate?.commentSend(text: textView.text)
    }
    
    func setText(_ text:String) {
        textView.text = text
        textViewDidChange(textView)
    }
    
}

