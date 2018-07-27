//
//  PostButton.swift
//  Jungle
//
//  Created by Robert Canton on 2018-07-03.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import UICircularProgressRing

class PostButton: UIView {
    
    var container:UIView!
    var button:UIButton!
    var progressRing:UICircularProgressRingView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        preservesSuperviewLayoutMargins = false
        insetsLayoutMarginsFromSafeArea = false
        translatesAutoresizingMaskIntoConstraints = false
        
        progressRing = UICircularProgressRingView(frame: CGRect(x: -bounds.width/2, y: -bounds.height/2, width: bounds.width, height: bounds.height))
        // Change any of the properties you'd like
        self.addSubview(progressRing)
        
        progressRing.maxValue = 1
        progressRing.shouldShowValueText = false
        progressRing.ringStyle = .ontop
        progressRing.outerRingWidth = 5.0
        progressRing.outerRingColor = UIColor.clear
        progressRing.innerRingWidth = 5.0
        progressRing.innerRingColor = accentColor
        progressRing.innerCapStyle = .butt
        progressRing.innerRingSpacing = 0.0
        progressRing.startAngle = -90
        
        progressRing.setProgress(value: 0.75, animationDuration: 1.0)
        
        
        container = UIView(frame: bounds)
        self.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        container.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
        container.heightAnchor.constraint(equalTo: container.widthAnchor).isActive = true
        
        button = UIButton(type: .custom)
        button.setImage(UIImage(named:"NewPost"), for: .normal)
        button.backgroundColor = UIColor.clear
        
        button.layer.cornerRadius = frame.height / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleNewPostButton), for: .touchUpInside)
        
        container.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleNewPostButton() {
        print("OKAY!")
    }
}
