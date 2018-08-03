//
//  ProfileTitleView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-07-17.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class ProfileTitleView:JTitleView {
    var titleView:UILabel!
    
    override init(frame: CGRect, topInset: CGFloat) {
        super.init(frame: frame, topInset: topInset)
        titleView = UILabel(frame: .zero)
        addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        titleView.text = "PROFILE"
        titleView.textColor = UIColor.white
        titleView.textAlignment = .center
        titleView.font = Fonts.medium(ofSize: 13.0)
        
       
        //tabScrollView.delegate = self
        
        rightButton.setImage(UIImage(named: "Settings"), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
