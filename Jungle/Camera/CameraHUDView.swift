//
//  EditOverlayView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-05.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import DynamicButton

protocol CameraHUDProtocol {
    func handleClose()
    func handleSwitchCamera()
    func handleStickers()
    func handleNext()
    func handlePost()
}

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
    
    var nextButton:UIButton!
    var recordButton:RecordButton!
    
    var switchCameraButton:UIButton!
    var stickersOverlay:UIView!
    var commentBar:GlassCommentBar!
    var captionBarBottomAnchor:NSLayoutConstraint!
    var captionBar:CaptionBar!
    
    var stickerButton:UIButton!
    var closeButton:DynamicButton!
    var postButton:UIButton!
    var postWidthAnchor:NSLayoutConstraint!
    var activityIndicator:UIActivityIndicatorView!
    var dimView:UIView!
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
        
        dimView = UIView(frame: bounds)
        dimView.backgroundColor = UIColor.black
        dimView.alpha = 0.0
        dimView.isUserInteractionEnabled = false
        addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dimView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        recordButton = RecordButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        switchCameraButton = UIButton(type: .custom)
        switchCameraButton.setImage(UIImage(named:"SwitchCamera"), for: .normal)
        switchCameraButton.tintColor = UIColor.white
        addSubview(switchCameraButton)
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
        switchCameraButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        switchCameraButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        switchCameraButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        switchCameraButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        switchCameraButton.applyShadow(radius: 6.0, opacity: 0.3, offset: .zero, color: .black, shouldRasterize: false)
        
        closeButton = DynamicButton(style: .caretDown)
        closeButton.highlightStokeColor = UIColor.white
        closeButton.strokeColor = UIColor.white
        addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24).isActive = true
        closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 24).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.tintColor = UIColor.white
        closeButton.applyShadow(radius: 6.0, opacity: 0.3, offset: .zero, color: .black, shouldRasterize: false)
        nextButton = UIButton(type: .custom)
        nextButton.setTitle("Next", for: .normal)
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
        //nextButton.addTarget(self, action: #selector(showCaptionBar), for: .touchUpInside)
        
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
        
        captionBar = CaptionBar(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 50))
        
        addSubview(captionBar)
        captionBar.translatesAutoresizingMaskIntoConstraints = false
        captionBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        captionBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        captionBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        captionBarBottomAnchor = captionBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        captionBarBottomAnchor?.isActive = true
        captionBar.isHidden = true
        captionBar.handleTag = handleTag
        
        commentBar = GlassCommentBar(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 50))
        
        addSubview(commentBar)
        commentBar.translatesAutoresizingMaskIntoConstraints = false
        commentBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        commentBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        commentBar.bottomAnchor.constraint(equalTo: captionBar.topAnchor, constant: 0).isActive = true
        commentBar.prepareTextView()
        commentBar.setToCaptionMode()
        commentBar.isHidden = true
        commentBar.delegate = self
        
        postButton = UIButton(type: .custom)
        postButton.setTitle("Post", for: .normal)
        postButton.backgroundColor = accentColor
        postButton.titleLabel?.font = Fonts.semiBold(ofSize: 15)
        postButton.setTitleColor(UIColor.white, for: .normal)
        addSubview(postButton)
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.sizeToFit()
        
        postButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true
        postButton.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        postWidthAnchor = postButton.widthAnchor.constraint(equalToConstant: 90)
        postWidthAnchor.isActive = true
        postButton.layer.cornerRadius = 36/2
        postButton.clipsToBounds = true
        postButton.isHidden = true
        postButton.applyShadow(radius: 6.0, opacity: 0.3, offset: .zero, color: accentColor, shouldRasterize: false)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: postButton.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: postButton.centerYAnchor).isActive = true
        
        
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(handleSwitchCamera), for: .touchUpInside)
        stickerButton.addTarget(self, action: #selector(handleStickers), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
    }
    
    var delegate:CameraHUDProtocol?
    @objc func handleClose() {
        delegate?.handleClose()
    }
    
    @objc func handleSwitchCamera() {
        delegate?.handleSwitchCamera()
    }
    
    @objc func handleStickers() {
        delegate?.handleStickers()
    }
    
    @objc func handleNext() {
        delegate?.handleNext()
    }
    
    @objc func handlePost() {
        delegate?.handlePost()
    }
    
    
    func handleTag(_ tag:String) {
        if let last = commentBar.textView.text.last {
            if last == " " {
                commentBar.textView.text = commentBar.textView.text + "\(tag) "
            } else {
                commentBar.textView.text = commentBar.textView.text + " \(tag) "
            }
        } else {
           commentBar.textView.text = commentBar.textView.text + "\(tag) "
        }
        commentBar.textViewDidChange(commentBar.textView)
        
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
    
    func hideCaptionBar() {
        commentBar.textView.resignFirstResponder()
        UIView.animate(withDuration: 0.25, animations: {
            self.dimView.alpha = 0.0
            self.commentBar.alpha = 0.0
            self.captionBar.alpha = 0.0
            self.stickerButton.alpha = 1.0
            self.nextButton.alpha = 1.0
            self.postButton.alpha = 0.0
        }, completion: { _ in
            self.commentBar.isHidden = true
            self.captionBar.isHidden = true
            self.postButton.isHidden = true
        })
    }
    
    func showCaptionBar() {
        captionBar.alpha = 1.0
        commentBar.alpha = 1.0
        commentBar.textView.becomeFirstResponder()
        commentBar.isHidden = false
        captionBar.isHidden = false
        postButton.alpha = 0.0
        postButton.isHidden = false

        UIView.animate(withDuration: 0.3, animations: {
            self.dimView.alpha = 0.5
            self.stickerButton.alpha = 0.0
            self.nextButton.alpha = 0.0
            self.postButton.alpha = 1.0
        })
    }
    
    func observeKeyboard(_ observe:Bool) {
        if observe {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    
    func startPostAnimation() {
        self.activityIndicator.alpha = 0.0
        self.activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.25, options: .curveEaseOut, animations: {
            self.postButton.setTitleColor(UIColor.clear, for: .normal)
            self.postWidthAnchor.constant = 40
            self.activityIndicator.alpha = 1.0
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
}

extension CameraHUDView: CommentBarDelegate {
    func commentSend(text: String) {
//        commentBar.textView.resignFirstResponder()
//        
//        UIView.animate(withDuration: 0.3, animations: {
//            self.commentBar.dividerNode.alpha = 0.0
//        })
    }
}

extension CameraHUDView: KeyboardAccessoryProtocol {
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        
        self.captionBarBottomAnchor?.constant = -keyboardSize.height
        self.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        self.captionBarBottomAnchor?.constant = 0.0
        self.layoutIfNeeded()
    }
}
