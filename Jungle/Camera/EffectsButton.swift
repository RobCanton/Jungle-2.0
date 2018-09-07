//
//  EffectsButton.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-26.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class EffectsButton:UIView {
    
    var blurView:UIVisualEffectView!
    var button:UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        preservesSuperviewLayoutMargins = false
        insetsLayoutMarginsFromSafeArea = false
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        blurView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        blurView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        button = UIButton(type: .custom)
        button.setTitle("Effects", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = Fonts.semiBold(ofSize: 14.0)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
