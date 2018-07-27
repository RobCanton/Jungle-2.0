//
//  RecordButton.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import UICircularProgressRing

class RecordButton:UIView {
    
    var centerView:UIView!
    var blurView:UIVisualEffectView!
    var progressRing:UICircularProgressRingView!
    
    var centerViewWidthAnchor:NSLayoutConstraint!
    var blurViewWidthAnchor:NSLayoutConstraint!
    var progressRingWidthAnchor:NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        blurView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        blurViewWidthAnchor = blurView.widthAnchor.constraint(equalToConstant: 80)
        blurViewWidthAnchor.isActive = true
        blurView.heightAnchor.constraint(equalTo: blurView.widthAnchor, multiplier: 1.0).isActive = true
        blurView.layer.cornerRadius = 40
        blurView.clipsToBounds = true
        
        centerView = UIView()
        centerView.backgroundColor = UIColor.white
        addSubview(centerView)
        centerView.translatesAutoresizingMaskIntoConstraints = false
        centerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        centerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        centerViewWidthAnchor = centerView.widthAnchor.constraint(equalToConstant: 50)
        centerViewWidthAnchor.isActive = true
        centerView.heightAnchor.constraint(equalTo: centerView.widthAnchor, multiplier: 1.0).isActive = true
        centerView.layer.cornerRadius = 25
        centerView.clipsToBounds = true
        
        progressRing = UICircularProgressRingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        // Change any of the properties you'd like
        addSubview(progressRing)
        
        progressRing.translatesAutoresizingMaskIntoConstraints = false
        progressRing.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        progressRing.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        progressRingWidthAnchor = progressRing.widthAnchor.constraint(equalToConstant: 80)
        progressRingWidthAnchor.isActive = true
        progressRing.heightAnchor.constraint(equalTo: progressRing.widthAnchor, multiplier: 1.0).isActive = true
        
        progressRing.maxValue = 1
        progressRing.shouldShowValueText = false
        progressRing.ringStyle = .gradient
        
        progressRing.outerRingWidth = 5.0
        progressRing.outerRingColor = UIColor.clear
        progressRing.innerRingWidth = 5.0
        progressRing.innerCapStyle = .butt
        let lightColor = hexColor(from: "a4e178")
        let darkColor = hexColor(from: "82d993")
        progressRing.gradientColors = [lightColor, darkColor]
        progressRing.gradientStartPosition = .top
        progressRing.gradientColorLocations = [0.0, 1.0]
        progressRing.gradientEndPosition = .bottom
        progressRing.innerRingSpacing = 0.0
        progressRing.applyShadow(radius: 5.0, opacity: 0.5, offset: .zero, color: accentColor, shouldRasterize: false)
        
        progressRing.startAngle = -90
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    
    }
    
    func reset() {
        self.progressRing.setProgress(value: 0.0, animationDuration: 0.0)
        self.progressRingWidthAnchor.constant = 80
        self.blurViewWidthAnchor.constant = 80
        self.blurView.layer.cornerRadius = 40
        self.centerViewWidthAnchor.constant = 50
        self.centerView.layer.cornerRadius = 25
        self.layoutIfNeeded()
    }
    
    func initiateRecordingAnimation() {
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: [.curveEaseInOut], animations: {
            self.progressRingWidthAnchor.constant = 100.0
            self.blurViewWidthAnchor.constant = 100.0
            self.blurView.layer.cornerRadius = 50
            
            
            self.layoutIfNeeded()
        }, completion: { _ in
            //self.startRecording()
        })
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.centerViewWidthAnchor.constant = 32
            self.centerView.layer.cornerRadius = 8.0
            self.layoutIfNeeded()
        }, completion: nil)
        
        
    }
    
    func startRecording() {
        progressRing.setProgress(value: 1.0, animationDuration: 30) {
            print("Done animating!")
            // Do anything your heart desires...
        }
    }
    
}
