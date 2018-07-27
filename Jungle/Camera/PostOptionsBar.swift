//
//  PostOptionsBar.swift
//  Jungle
//
//  Created by Robert Canton on 2018-07-27.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class PostOptionsBar:UIView {
    var locationButton:UIButton!
    var sfwButton:UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.preservesSuperviewLayoutMargins = false
        self.insetsLayoutMarginsFromSafeArea = false
        translatesAutoresizingMaskIntoConstraints = false
        locationButton = UIButton(type: .custom)
        addSubview(locationButton)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        locationButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        locationButton.titleLabel?.font = Fonts.medium(ofSize: 14.0)
        locationButton.setTitle("Markham, CA", for: .normal)
        locationButton.setImage(UIImage(named:"PinLarge"), for: .normal)
        locationButton.contentHorizontalAlignment = .leading
        
        locationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 8)
        locationButton.backgroundColor = accentColor//UIColor.black.withAlphaComponent(0.5)
        locationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        locationButton.sizeToFit()
        locationButton.layer.cornerRadius = 4.0
        locationButton.clipsToBounds = true
        
        sfwButton = UIButton(type: .custom)
        addSubview(sfwButton)
        sfwButton.translatesAutoresizingMaskIntoConstraints = false
        sfwButton.leadingAnchor.constraint(equalTo: locationButton.trailingAnchor, constant: 12).isActive = true
        sfwButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sfwButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        sfwButton.titleLabel?.font = Fonts.semiBold(ofSize: 12)
        sfwButton.setTitle("NSFW", for: .normal)
        sfwButton.contentHorizontalAlignment = .leading
        sfwButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8)
        sfwButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        sfwButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sfwButton.sizeToFit()
        sfwButton.layer.cornerRadius = 4.0
        sfwButton.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
