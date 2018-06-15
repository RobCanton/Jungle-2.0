//
//  JCommentBar.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-15.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol CommentBarDelegate:class {
    func commentSend(
        
        text:String)
}

class JCommentBar:UIView, UITextViewDelegate {
    
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
    
    weak var delegate:CommentBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = UIColor.white
        translatesAutoresizingMaskIntoConstraints = false
        self.insetsLayoutMarginsFromSafeArea = false
        self.preservesSuperviewLayoutMargins = false
        
        textBox = UIView()
        addSubview(textBox)
        textBox.translatesAutoresizingMaskIntoConstraints = false
        textBox.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        textBox.layer.cornerRadius = 4.0
        textBox.clipsToBounds = true
        textBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4.0).isActive = true
        textBox.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.0).isActive = true
        
        placeHolderLabel = UILabel(frame: .zero)
        placeHolderLabel.textColor = UIColor.gray
        textBox.addSubview(placeHolderLabel)
        placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeHolderLabel.font = Fonts.medium(ofSize: 14.0)
        placeHolderLabel.text = "Reply"
        placeHolderLabel.leadingAnchor.constraint(equalTo: textBox.leadingAnchor, constant: 9).isActive = true
        placeHolderLabel.topAnchor.constraint(equalTo: textBox.topAnchor, constant: 0).isActive = true
        placeHolderLabel.bottomAnchor.constraint(equalTo: textBox.bottomAnchor, constant: 0).isActive = true
        placeHolderLabel.trailingAnchor.constraint(equalTo: textBox.trailingAnchor, constant: 0).isActive = true
        
        textView = UITextView(frame: .zero)
        textView.backgroundColor = .clear
        textView.font = Fonts.medium(ofSize: 14.0)
        textBox.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: textBox.leadingAnchor, constant: 4).isActive = true
        textView.topAnchor.constraint(equalTo: textBox.topAnchor, constant: 0).isActive = true
        textView.bottomAnchor.constraint(equalTo: textBox.bottomAnchor, constant: 0).isActive = true
        textHeightAnchor = textView.heightAnchor.constraint(equalToConstant: 42)
        textHeightAnchor.isActive = true
        textView.delegate = self
        textView.isScrollEnabled = false
        
        
        sendButton = UIButton(type: .custom)
        sendButton.setImage(UIImage(named:"SendSimple"), for: .normal)
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
    
    func darkMode() {
        textView.keyboardAppearance = .dark
        backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        textBox.backgroundColor = UIColor(white: 0.075, alpha: 1.0)
        textView.textColor = UIColor.white
    }
    
    func prepareTextView() {
        textView.text = "Hello!"
        textViewDidChange(textView)
        textView.text = ""
        textViewDidChange(textView)
        self.sendButton.backgroundColor = hexColor(from: "BEBEBE")
        //placeHolderTextView.isHidden = false
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
        //delegate?.commentTextDidChange(height: height)
        //placeHolderTextView.isHidden = textView.text != ""
    }
    
    @objc func sendText(_ sender:Any) {
        guard textView.text.count > 0 else { return }
        delegate?.commentSend(text: textView.text)
    }
}
