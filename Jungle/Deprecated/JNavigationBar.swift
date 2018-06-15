//
//  JNavigationBar.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit


class JNavigationBar:UIView {
    
    var leftButton:UIButton!
    var divider:UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        translatesAutoresizingMaskIntoConstraints = false
        leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44.0, height: 44.0))
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftButton)
        
        let layoutGuide = safeAreaLayoutGuide
        leftButton.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        leftButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 0).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        leftButton.heightAnchor.constraint(equalTo: leftButton.widthAnchor, multiplier: 1.0/1.0).isActive = true
        leftButton.setImage(UIImage(named:"back"), for: .normal)
        
//        divider = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 0.5))
//        addSubview(divider)
//        divider.translatesAutoresizingMaskIntoConstraints = false
//        divider.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
//        divider.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
//        divider.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
//        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
//        divider.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
