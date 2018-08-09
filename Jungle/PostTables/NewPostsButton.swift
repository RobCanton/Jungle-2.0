//
//  NewPostsButton.swift
//  Jungle
//
//  Created by Robert Canton on 2018-08-05.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class NewPostsButton:UIView {
    var button:UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.preservesSuperviewLayoutMargins = false
        self.preservesSuperviewLayoutMargins = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        button = UIButton(type: .custom)
        button.backgroundColor = hexColor(from: "00937B")
        button.setTitle("See new posts", for: .normal)
        button.contentEdgeInsets = UIEdgeInsetsMake(6, 12, 6, 12)
        button.titleLabel?.font = Fonts.regular(ofSize: 14.0)
        button.sizeToFit()
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        button.layer.cornerRadius = button.bounds.height / 2
        button.clipsToBounds = true
        
        self.applyShadow(radius: 6.0, opacity: 0.2, offset: CGSize(width:0,height:2), color: .black, shouldRasterize: false)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
