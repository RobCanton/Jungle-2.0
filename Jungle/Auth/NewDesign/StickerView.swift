//
//  StickerView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-05.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
class StickerView:UIView, UIGestureRecognizerDelegate {
    var imageNode:ASNetworkImageNode!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageNode = ASNetworkImageNode()
        insetsLayoutMarginsFromSafeArea = false
        
        let imageView = imageNode.view
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        pinch.delegate = self
        self.addGestureRecognizer(pinch)
        self.isUserInteractionEnabled = true
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        rotate.delegate = self
        self.addGestureRecognizer(rotate)
    }
    
    func setupSticker(_ sticker:UIImage) {
        isUserInteractionEnabled = true
        imageNode.image = sticker
    }
    
    var pinchInitialFrame:CGRect = .zero
    
    @objc func handlePinch(pinch: UIPinchGestureRecognizer) {
        
        if let view = pinch.view {
            view.transform = view.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1
        }
    }
    
    @objc func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
            let radians = atan2(view.transform.b, view.transform.a)
            let degrees:CGFloat = radians * (CGFloat(180) / CGFloat(M_PI) )
            let r = Double(degrees).degreesToRadians
            print("Degrees: \(degrees) R: \(r)")
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
