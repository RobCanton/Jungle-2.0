//
//  CommentActionsRow.swift
//  Jungle
//
//  Created by Robert Canton on 2018-07-03.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import WCLShineButton


class CommentActionsRow: UIView {
    var likeButton:WCLShineButton!
    var likeLabel:UILabel!
    
    var replyButton:UIButton!
    var moreButton:UIButton!
    
    weak var delegate:PostActionsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = UIColor.blue.withAlphaComponent(0.0)
        
        var param1 = WCLShineParams()
        param1.allowRandomColor = true
        param1.animDuration = 1
        param1.enableFlashing = false
        param1.shineDistanceMultiple = 0.9
        param1.colorRandom =  [UIColor(rgb: (255, 204, 204)),
                               UIColor(rgb: (255, 102, 102)),
                               UIColor(rgb: (255, 102, 102))]
        param1.shineSize = 4
        
        likeButton = WCLShineButton(frame: .init(x: 0, y: 0, width: 32, height: 32), params: param1)
        likeButton.color = hexColor(from: "BEBEBE")
        likeButton.fillColor = UIColor(rgb: (255, 102, 102))
        likeButton.image = WCLShineImage.custom(UIImage(named:"like")!)
        addSubview(likeButton)
        
        
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        likeButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        likeButton.heightAnchor.constraint(equalTo: likeButton.widthAnchor, multiplier: 1.0).isActive = true
        likeButton.addTarget(self, action: #selector(handleLike), for: .valueChanged)
        likeLabel = UILabel(frame: .zero)
        likeLabel.text = "0"
        likeLabel.textColor = hexColor(from: "BEBEBE")
        likeLabel.font = Fonts.semiBold(ofSize: 14.0)
        addSubview(likeLabel)
        likeLabel.translatesAutoresizingMaskIntoConstraints = false
        likeLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 2.0).isActive = true
        likeLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor).isActive = true
        
        moreButton = UIButton(type: .custom)
        moreButton.setImage(UIImage(named:"more"), for: .normal)
        addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        moreButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        moreButton.heightAnchor.constraint(equalTo: moreButton.widthAnchor, multiplier: 1.0).isActive = true
        moreButton.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
        
        replyButton = UIButton(type: .custom)
        replyButton.setImage(UIImage(named:"reply"), for: .normal)
        replyButton.setTitle("Reply", for: .normal)
        replyButton.setTitleColor(tertiaryColor, for: .normal)
        replyButton.titleLabel?.font = Fonts.semiBold(ofSize: 14.0)
        addSubview(replyButton)
        replyButton.translatesAutoresizingMaskIntoConstraints = false
        replyButton.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -12).isActive = true
        replyButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        replyButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        replyButton.addTarget(self, action: #selector(handleReply), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleLike() {
        delegate?.handleLikeButton()
    }
    
    @objc func handleReply() {
        delegate?.handleCommentButton()
    }
    
    @objc func handleMore() {
        delegate?.handleMoreButton()
    }
    
    
    func setLiked(_ liked:Bool, animated:Bool) {
        if liked {
            likeButton.setClicked(true, animated: animated)
        } else {
            likeButton.setClicked(false, animated: animated)
        }
    }
    
    func setNumLikes(_ numLikes:Int) {
        likeLabel.text = "\(numLikes)"
    }
}
