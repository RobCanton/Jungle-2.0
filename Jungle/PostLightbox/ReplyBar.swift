//
//  ReplyBar.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-15.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class ReplyBar:UIView {
    
    var replyLabel:UILabel!
    var replyClose:UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.insetsLayoutMarginsFromSafeArea = false
        self.preservesSuperviewLayoutMargins = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = UIColor.white
        
        let replyDivider = UIView()
        replyDivider.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        addSubview(replyDivider)
        replyDivider.translatesAutoresizingMaskIntoConstraints = false
        replyDivider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        replyDivider.topAnchor.constraint(equalTo: topAnchor).isActive = true
        replyDivider.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        replyDivider.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        replyLabel = UILabel(frame: bounds)
        replyLabel.font = Fonts.semiBold(ofSize: 14.0)
        replyLabel.textColor = grayColor
        addSubview(replyLabel)
        replyLabel.translatesAutoresizingMaskIntoConstraints = false
        replyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13).isActive = true
        replyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -44).isActive = true
        replyLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        replyLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        replyClose = UIButton(type: .custom)
        replyClose.tintColor = UIColor.gray
        replyClose.setImage(UIImage(named:"Remove2"), for: .normal)
        addSubview(replyClose)
        replyClose.translatesAutoresizingMaskIntoConstraints = false
        replyClose.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        replyClose.topAnchor.constraint(equalTo: topAnchor).isActive = true
        replyClose.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setReply(_ reply:Post?) {
        if let reply = reply {
            let prefix = "Replying to "
            let name = "@\(reply.anon.displayName)"
            let text = "\(prefix)\(name)"
            replyLabel.text = "Replying to \(name)"
            let attributedText = NSMutableAttributedString(string: text, attributes: [
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: tagColor
                ])
            
            attributedText.addAttributes([
                NSAttributedStringKey.font: Fonts.semiBold(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: UIColor.gray
                ], range: NSRange(location: 0, length: prefix.count))
            replyLabel.attributedText = attributedText
            
            
        } else {
            replyLabel.attributedText = nil
            
        }
        layoutIfNeeded()
    }
}
