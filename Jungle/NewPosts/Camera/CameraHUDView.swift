//
//  EditOverlayView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-05.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class CameraHUDView:UIView {
    
    /// must be >= 1.0
    var snapX:CGFloat = 1.0
    
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
    
    var closeButton:UIButton!
    var nextButton:UIButton!
    var recordButton:RecordButton!
    
    var stickersOverlay:UIView!
    
    var stickerButton:UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        
        
        stickersOverlay = UIView()
        addSubview(stickersOverlay)
        stickersOverlay.translatesAutoresizingMaskIntoConstraints = false
        stickersOverlay.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stickersOverlay.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stickersOverlay.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stickersOverlay.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
//        sticker = StickerView(frame: CGRect(x: 0, y: 0, width: 200, height: 162.4))
//        sticker.setupSticker(UIImage(named:"gudetama_meh")!)
//
//        stickersOverlay.addSubview(sticker)
        
        let pan = UIPanGestureRecognizer(target:self, action:#selector(handlePan))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        stickersOverlay.addGestureRecognizer(pan)
        stickersOverlay.isUserInteractionEnabled = true
        
        recordButton = RecordButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named:"Remove2"), for: .normal)
        addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        closeButton.tintColor = UIColor.white
        closeButton.applyShadow(radius: 6.0, opacity: 0.3, offset: .zero, color: .black, shouldRasterize: false)
        nextButton = UIButton(type: .custom)
        nextButton.setTitle("Use", for: .normal)
        nextButton.backgroundColor = UIColor.white
        nextButton.titleLabel?.font = Fonts.semiBold(ofSize: 15)
        nextButton.setTitleColor(UIColor.gray, for: .normal)
        addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.sizeToFit()

        nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        nextButton.layer.cornerRadius = 36/2
        nextButton.clipsToBounds = true
        nextButton.isHidden = true
        nextButton.applyShadow(radius: 6.0, opacity: 0.2, offset: .zero, color: .black, shouldRasterize: false)
        
        stickerButton = UIButton(type: .custom)
        stickerButton.setImage(UIImage(named:"sticker"), for: .normal)
        addSubview(stickerButton)
        stickerButton.translatesAutoresizingMaskIntoConstraints = false
        stickerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        stickerButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stickerButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        stickerButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        stickerButton.tintColor = UIColor.white
        stickerButton.applyShadow(radius: 6.0, opacity: 0.3, offset: .zero, color: .black, shouldRasterize: false)
                
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addSticker(_ sticker:UIImage) {
        print("ADD IT!")
        
        let dimensions = sticker.size
        let ratio = dimensions.height / dimensions.width
        let size = CGSize(width: 200 , height: 200 * ratio)
        let sFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let stickerView = StickerView(frame: sFrame)
        stickerView.setupSticker(sticker)
        stickerView.center = self.center
        
        stickersOverlay.addSubview(stickerView)
        
        stickerView.transform = CGAffineTransform(scaleX: 0.70, y: 0.70)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
            stickerView.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    
    var centerOffsetSize:CGSize = .zero
    @objc func handlePan(_ rec:UIPanGestureRecognizer) {
        //print("OMG SAUCE!")
        let p:CGPoint = rec.location(in: self)
        switch rec.state {
        case .began:
            //print("began")
            selectedView = self.hitTest(p, with: nil)
            if selectedView != nil {
                let center = selectedView!.center
                centerOffsetSize = CGSize(width: p.x - center.x , height: p.y - center.y)
                self.bringSubview(toFront: selectedView!)
                
            }
            break
        case .changed:
            if let subview = selectedView {
                if subview is StickerView {
                    subview.center.x = p.x - (p.x.truncatingRemainder(dividingBy: snapX)) - centerOffsetSize.width
                    subview.center.y = p.y - (p.y.truncatingRemainder(dividingBy: snapY)) - centerOffsetSize.height
                }
            }
            break
        case .ended:
            print("ended")
            if let subview = selectedView {
                if subview is StickerView {
                    // do whatever
                }
            }
            selectedView = nil
            break
        case .possible:
            print("possible")
            break
        case .cancelled:
            print("cancelled")
            selectedView = nil
            break
        case .failed:
            print("failed")
            selectedView = nil
            break
        }
    }
}
