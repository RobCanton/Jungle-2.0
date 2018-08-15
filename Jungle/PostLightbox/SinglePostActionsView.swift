//
//  SinglePostActionsView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-07.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import WCLShineButton

protocol PostActionsDelegate:class {
    func handleLikeButton()
    func handleCommentButton()
    func handleMoreButton()
    func handleLocationButton()
    func openTag(_ tag:String)
    func postOpen(profile:Profile)
}

class SinglePostActionsView:UIView {
    
    var likeButton:WCLShineButton!
    var likeLabel:UILabel!
    var likeHitButton:UIButton!
    var likeButtonBackDrop:UIView!
    
    var commentButton:UIImageView!
    var commentLabel:UILabel!
    var commentHitButton:UIButton!
    var commentButtonBackDrop:UIView!
    
    var locationButton:UIButton!
    
    weak var delegate:PostActionsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        insetsLayoutMarginsFromSafeArea = false
        
        likeButtonBackDrop = UIView()
        likeButtonBackDrop.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(likeButtonBackDrop)
        likeButtonBackDrop.translatesAutoresizingMaskIntoConstraints = false
        likeButtonBackDrop.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        likeButtonBackDrop.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.0).isActive = true
        likeButtonBackDrop.widthAnchor.constraint(equalToConstant: 32).isActive = true
        likeButtonBackDrop.heightAnchor.constraint(equalToConstant: 32).isActive = true
        likeButtonBackDrop.layer.cornerRadius = 16.0
        likeButtonBackDrop.clipsToBounds = true
        
        
        var param1 = WCLShineParams()
        param1.allowRandomColor = true
        param1.animDuration = 1
        param1.enableFlashing = true
        param1.shineDistanceMultiple = 1.2
        param1.colorRandom =  [UIColor(rgb: (255, 255, 153)),
                               UIColor(rgb: (255, 204, 204)),
                               UIColor(rgb: (255, 102, 102)),
                               UIColor(rgb: (255, 255, 102)),
                               UIColor(rgb: (102, 102, 102)),
                               UIColor(rgb: (117, 206, 255)),
                               UIColor(rgb: (117, 255, 193))]
        //param1.shineSize = 5
        
        likeButton = WCLShineButton(frame: .init(x: 0, y: 0, width: 32, height: 32), params: param1)
        likeButton.color = UIColor.white
        likeButton.fillColor = UIColor.white
        likeButton.image = WCLShineImage.custom(UIImage(named:"like_outline")!)
        
        
        likeButton.addTarget(self, action: #selector(action), for: .valueChanged)
        self.addSubview(likeButton)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        likeButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -16.0).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        likeButton.isUserInteractionEnabled = false
        likeLabel = UILabel(frame: .zero)
        likeLabel.textColor = UIColor.white
        likeLabel.font = Fonts.semiBold(ofSize: 12.0)
        likeLabel.text = "-"
        likeLabel.sizeToFit()
        self.addSubview(likeLabel)
        likeLabel.translatesAutoresizingMaskIntoConstraints = false
        likeLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 8).isActive = true
        likeLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        likeLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        likeHitButton = UIButton(type: .custom)
        addSubview(likeHitButton)
        likeHitButton.translatesAutoresizingMaskIntoConstraints = false
        likeHitButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        likeHitButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        likeHitButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        likeHitButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        likeHitButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        
        commentButtonBackDrop = UIView()
        commentButtonBackDrop.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(commentButtonBackDrop)
        commentButtonBackDrop.translatesAutoresizingMaskIntoConstraints = false
        commentButtonBackDrop.leadingAnchor.constraint(equalTo: likeLabel.trailingAnchor, constant: 12 + 8).isActive = true
        commentButtonBackDrop.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.0).isActive = true
        commentButtonBackDrop.widthAnchor.constraint(equalToConstant: 32).isActive = true
        commentButtonBackDrop.heightAnchor.constraint(equalToConstant: 32).isActive = true
        commentButtonBackDrop.layer.cornerRadius = 16.0
        commentButtonBackDrop.clipsToBounds = true
        
        commentButton = UIImageView()
        addSubview(commentButton)
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.leadingAnchor.constraint(equalTo: likeLabel.trailingAnchor, constant: 12 + 8).isActive = true
        commentButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.0).isActive = true
        commentButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        commentButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        commentButton.image = UIImage(named: "comment_outline")
        
        commentLabel = UILabel(frame: .zero)
        commentLabel.textColor = UIColor.white
        commentLabel.font = Fonts.semiBold(ofSize: 12.0)
        commentLabel.text = "-"
        commentLabel.sizeToFit()
        self.addSubview(commentLabel)
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 8).isActive = true
        commentLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        commentLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        commentHitButton = UIButton(type: .custom)
        //commentHitButton.backgroundColor = UIColor.blue.withAlphaComponent(0.25)
        addSubview(commentHitButton)
        commentHitButton.translatesAutoresizingMaskIntoConstraints = false
        commentHitButton.leadingAnchor.constraint(equalTo: likeLabel.trailingAnchor, constant: 8).isActive = true
        commentHitButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        commentHitButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        commentHitButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        commentHitButton.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        
        locationButton = UIButton(type: .custom)
        locationButton.tintColor = UIColor.white
        //locationButton.setTitle(pair.locationShortStr, for: .normal)
        locationButton.setTitleColor(UIColor.white, for: .normal)
        locationButton.setImage(UIImage(named:"Pin"), for: .normal)
        locationButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        locationButton.contentHorizontalAlignment = .center
        locationButton.titleLabel?.font = Fonts.semiBold(ofSize: 12.0)
        
        addSubview(locationButton)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        locationButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.0).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        locationButton.layer.cornerRadius = 16.0
        locationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 12)
        locationButton.sizeToFit()
        locationButton.addTarget(self, action: #selector(handleLocation), for: .touchUpInside)
        
    }
    
    @objc func handleLike() {
        delegate?.handleLikeButton()
    }
    
    func setLiked(_ liked:Bool, animated:Bool) {
        if liked {
            likeButtonBackDrop.backgroundColor = UIColor(rgb: (255, 102, 102))
            likeButton.setClicked(true, animated: animated)
            likeButton.image = WCLShineImage.custom(UIImage(named:"like")!)
        } else {
            likeButtonBackDrop.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            likeButton.setClicked(false, animated: animated)
            likeButton.image = WCLShineImage.custom(UIImage(named:"like_outline")!)
        }
    }
    
    @objc func handleComment() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.commentButtonBackDrop.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            self.commentButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.commentButtonBackDrop.transform = CGAffineTransform.identity
                self.commentButton.transform = CGAffineTransform.identity
            }, completion: nil)
        })
        delegate?.handleCommentButton()
    }
    
    @objc func handleLocation() {
        delegate?.handleLocationButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBlocked(_ isBlocked:Bool) {
        self.alpha = isBlocked ? 0.5 : 1.0
        self.commentHitButton.isUserInteractionEnabled = !isBlocked
        self.likeHitButton.isUserInteractionEnabled = !isBlocked
        self.locationButton.isUserInteractionEnabled = !isBlocked
    }
}
