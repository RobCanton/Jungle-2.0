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
    
    var sticker = UIImageView(image: UIImage(named:"watermark"))
    
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
        
        sticker.frame = CGRect(x: 0, y: 0, width: 200, height: 162.4)
        
        addSubview(sticker)
        
        let pan = UIPanGestureRecognizer(target:self, action:#selector(handlePan))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        self.addGestureRecognizer(pan)
    }
    
    /// must be >= 1.0
    var snapX:CGFloat = 40.0
    
    /// must be >= 1.0
    var snapY:CGFloat = 1.0
    
    /// how far to move before dragging
    var threshold:CGFloat = 0.0
    
    /// the guy we're dragging
    var selectedView:UIView?
    
    /// drag in the Y direction?
    var shouldDragY = true
    
    /// drag in the X direction?
    var shouldDragX = true
    
    @objc func handlePan(_ rec:UIPanGestureRecognizer) {
        
        let p:CGPoint = rec.location(in: self)
        var center:CGPoint = .zero
        
        switch rec.state {
        case .began:
            selectedView = self.hitTest(p, with: nil)
            if selectedView != nil {
                self.bringSubview(toFront: selectedView!)
            }
            
        case .changed:
            if let subview = selectedView {
                center = subview.center
                let distance = sqrt(pow((center.x - p.x), 2.0) + pow((center.y - p.y), 2.0))
                
                if subview is UIImageView {
                    if distance > threshold {
                        if shouldDragX {
                            subview.center.x = p.x - (p.x.truncatingRemainder(dividingBy: snapX))
                        }
                        if shouldDragY {
                            subview.center.y = p.y - (p.y.truncatingRemainder(dividingBy: snapY))
                        }
                    }
                }
            }
            
        case .ended:
            selectedView = nil
            
        case .possible:
            print("possible")
        case .cancelled:
            print("cancelled")
            selectedView = nil
        case .failed:
            print("failed")
            selectedView = nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
