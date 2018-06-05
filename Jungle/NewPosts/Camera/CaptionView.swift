//
//  CaptionViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class CaptionView:UIView {
    
    var backButton:UIButton!
    var titleLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named:"back"), for: .normal)
        backButton.tintColor = UIColor.white
        backButton.tintColorDidChange()
        addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        backButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 64.0).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 64.0))
        titleLabel.text = "Write a Caption"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
