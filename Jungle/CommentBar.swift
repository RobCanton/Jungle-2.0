//
//  CommentBar.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-21.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

protocol CommentBarDelegate:class {
    func commentTextDidChange(height:CGFloat)
    func commentSend(text:String)
}

class CommentBar:UIView, UITextViewDelegate {
    var topView: UIView!
    var midView: UIView!
    var botView: UIView!
    var stackView: UIStackView!
    
    var textBubble:UIView!
    var textView: UITextView!
    var placeHolderTextView: UITextView!
    
    var sendButton:UIButton!
    
    static let topHeight:CGFloat = 22.0
    static let botHeight:CGFloat = 44.0
    static let textMarginHeight:CGFloat = 8.0
    
    var topHeightAnchor:NSLayoutConstraint?
    var botHeightAnchor:NSLayoutConstraint?
    
    weak var delegate:CommentBarDelegate?
    
    var replyLabel:ActiveTextNode!
    
    
    
    var divider:UIView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        stackView = UIStackView(frame:bounds)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.backgroundColor = nil
        addSubview(stackView)
        let layoutGuide = safeAreaLayoutGuide
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        topView = UIView(frame: CGRect(x: 0, y: 0, width: stackView.bounds.width, height: CommentBar.topHeight))
        topView.backgroundColor = UIColor.white
        topView.translatesAutoresizingMaskIntoConstraints = false
        topHeightAnchor = topView.heightAnchor.constraint(equalToConstant: CommentBar.topHeight)
        topHeightAnchor?.isActive = true
        stackView.addArrangedSubview(topView)
        
        let topLayoutGuide = topView.safeAreaLayoutGuide
        
        replyLabel = ActiveTextNode()
        topView.addSubview(replyLabel.view)
        replyLabel.view.translatesAutoresizingMaskIntoConstraints = false
        replyLabel.view.leadingAnchor.constraint(equalTo: topLayoutGuide.leadingAnchor, constant: 24.0).isActive = true
        replyLabel.view.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor, constant: 5.0).isActive = true
        replyLabel.view.trailingAnchor.constraint(equalTo: topLayoutGuide.trailingAnchor).isActive = true
        replyLabel.view.bottomAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        setReply("Replying to @Drizzy")
        
        midView = UIView(frame: CGRect(x: 0, y: 0, width: stackView.bounds.width, height: stackView.bounds.height - CommentBar.topHeight - CommentBar.botHeight))
        midView.backgroundColor = UIColor.white
        midView.autoresizingMask = [ .flexibleWidth, .flexibleHeight]
        stackView.addArrangedSubview(midView)
        
        let midLayoutGuide = midView.safeAreaLayoutGuide
        textBubble = UIView(frame: midView.bounds)
        midView.addSubview(textBubble)
        textBubble.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        textBubble.translatesAutoresizingMaskIntoConstraints = false
        textBubble.leadingAnchor.constraint(equalTo: midLayoutGuide.leadingAnchor, constant: 12.0).isActive = true
        textBubble.topAnchor.constraint(equalTo: midLayoutGuide.topAnchor, constant: 4.0).isActive = true
        textBubble.trailingAnchor.constraint(equalTo: midLayoutGuide.trailingAnchor, constant: -12.0).isActive = true
        textBubble.bottomAnchor.constraint(equalTo: midLayoutGuide.bottomAnchor, constant: -4.0).isActive = true
        
        
        let bubbleLayoutGuide = textBubble.safeAreaLayoutGuide
        placeHolderTextView = UITextView(frame: textBubble.bounds)
        placeHolderTextView.backgroundColor = nil
        placeHolderTextView.font = Fonts.medium(ofSize: 14.0)
        placeHolderTextView.textColor = UIColor.gray
        placeHolderTextView.isEditable = false
        placeHolderTextView.isSelectable = false
        placeHolderTextView.isScrollEnabled = false
        textBubble.addSubview(placeHolderTextView)
        placeHolderTextView.translatesAutoresizingMaskIntoConstraints = false
        placeHolderTextView.leadingAnchor.constraint(equalTo: bubbleLayoutGuide.leadingAnchor, constant: 8.0).isActive = true
        placeHolderTextView.topAnchor.constraint(equalTo: bubbleLayoutGuide.topAnchor, constant: 0.0).isActive = true
        placeHolderTextView.trailingAnchor.constraint(equalTo: bubbleLayoutGuide.trailingAnchor, constant: -8.0).isActive = true
        placeHolderTextView.bottomAnchor.constraint(equalTo: bubbleLayoutGuide.bottomAnchor, constant: 0.0).isActive = true
        placeHolderTextView.text = "Add your reply"
        
        textView = UITextView(frame: textBubble.bounds)
        textView.backgroundColor = nil
        textView.font = Fonts.medium(ofSize: 15.0)
        textView.textColor = UIColor.black
        textView.delegate = self
        textView.isScrollEnabled = false
        textBubble.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: bubbleLayoutGuide.leadingAnchor, constant: 8.0).isActive = true
        textView.topAnchor.constraint(equalTo: bubbleLayoutGuide.topAnchor, constant: 0.0).isActive = true
        textView.trailingAnchor.constraint(equalTo: bubbleLayoutGuide.trailingAnchor, constant: -8.0).isActive = true
        textView.bottomAnchor.constraint(equalTo: bubbleLayoutGuide.bottomAnchor, constant: 0.0).isActive = true
        textView.keyboardType = .twitter
        
        botView = UIView(frame: CGRect(x: 0, y: 0, width: stackView.bounds.width, height: CommentBar.botHeight))
        botView.backgroundColor = UIColor.white
        stackView.addArrangedSubview(botView)
        botView.translatesAutoresizingMaskIntoConstraints = false
        botHeightAnchor = botView.heightAnchor.constraint(equalToConstant: CommentBar.botHeight)
        botHeightAnchor?.isActive = true
        
        let botLayoutGuide = botView.safeAreaLayoutGuide
        
        sendButton = UIButton(frame: CGRect(x: 0, y: 0, width: CommentBar.botHeight, height: CommentBar.botHeight))

        sendButton.setAttributedTitle(NSAttributedString(string: "Reply", attributes: [
            NSAttributedStringKey.font: Fonts.semiBold(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ]), for: .normal)
        botView.addSubview(sendButton)
        sendButton.backgroundColor = accentColor
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.trailingAnchor.constraint(equalTo: botLayoutGuide.trailingAnchor, constant: -12.0).isActive = true
        sendButton.topAnchor.constraint(equalTo: botLayoutGuide.topAnchor, constant: 2.0).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: botLayoutGuide.bottomAnchor, constant: -6.0).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: CommentBar.botHeight + 24.0).isActive = true
        
        sendButton.layer.cornerRadius = (CommentBar.botHeight - 8.0) / 2
        sendButton.clipsToBounds = true
        sendButton.addTarget(self, action: #selector(sendText), for: .touchUpInside)
        
        divider = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 0.5))
        divider.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        divider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(divider)
        divider.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        divider.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    
    fileprivate func setReply(_ text:String) {
        replyLabel.setText(text: text, withFont: Fonts.medium(ofSize: 12.0), normalColor: UIColor.gray, activeColor: accentColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setComposeMode(_ compose:Bool) {
        if compose {
            stackView.insertArrangedSubview(topView, at: 0)
            stackView.addArrangedSubview(botView)
        } else {
            textView.text = ""
            textViewDidChange(textView)
            stackView.removeArrangedSubview(topView)
            topView.removeFromSuperview()
            stackView.removeArrangedSubview(botView)
            botView.removeFromSuperview()
        }
    }
    
    var nonTextHeight:CGFloat {
        get {
            let botHeight = botView.superview != nil ? CommentBar.botHeight : 0
            let topHeight = topView.superview != nil ? CommentBar.topHeight : 0
            return CommentBar.textMarginHeight + botHeight + topHeight
        }
    }
    
    func prepareTextView() {
        textView.text = "Hello!"
        textViewDidChange(textView)
        textView.text = ""
        placeHolderTextView.isHidden = false
        textBubble.layer.cornerRadius = textBubble.bounds.height / 2
        textBubble.clipsToBounds = true
    }

    var textHeight:CGFloat = 0.0
    func textViewDidChange(_ textView: UITextView) {
        let height = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.infinity)).height
        self.textHeight = height
        delegate?.commentTextDidChange(height: height)
        placeHolderTextView.isHidden = textView.text != ""
    }
    
    @objc func sendText(_ sender:Any) {
        delegate?.commentSend(text: textView.text)
    }
    
    func setReply(_ reply:Reply) {
        setReply("Replying to @\(reply.anon.displayName)")
        textView.becomeFirstResponder()
    }
}
