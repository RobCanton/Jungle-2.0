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
import JaneSliderControl
import AsyncDisplayKit

protocol CameraHUDProtocol {
    func handleClose()
    func handleSwitchCamera()
    func handleTorch()
    func handleStickers()
    func handleNext()
    func handlePost()
    func getCurrentImage() -> CIImage?
    func setCameraEffect(_ effect:String?, _ intensity:Float?)
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
    
    var blurView:UIVisualEffectView!
    var nextButton:UIButton!
    var recordButton:RecordButton!
    var recordButtonBottomAnchor:NSLayoutConstraint!
    
    var switchCameraButton:UIButton!
    var flashButton:UIButton!
    var stickersOverlay:UIView!
    
    var textView:UITextView!
    var textViewLeadingAnchor:NSLayoutConstraint!
    
    var stickerButton:UIButton!
    var closeButton:DynamicButton!
    var postButton:UIButton!
    var postWidthAnchor:NSLayoutConstraint!
    var activityIndicator:UIActivityIndicatorView!
    var dimView:UIView!
    
    var effectsButton:UIButton!
    var effectsBar:EffectsBar!
    var effectsBarBottomAnchor:NSLayoutConstraint!
    var effectsBarIsOpen = false
    var blurAnimator:UIViewPropertyAnimator!
    
    var optionsBar:CaptionBar!
    var optionsBarBottomAnchor:NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        
        blurView = UIVisualEffectView(effect: nil)
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        textView = UITextView(frame: .zero)
        textView.backgroundColor = UIColor.clear
        textView.textContainerInset = UIEdgeInsetsMake(8, 20, 0, 20)
        textView.textColor = UIColor.white
        textView.keyboardAppearance = .dark
        textView.font = Fonts.medium(ofSize: 18.0)
        addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textViewLeadingAnchor = textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        textViewLeadingAnchor.isActive = true
        textView.isUserInteractionEnabled = false
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 64.0).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        stickersOverlay = UIView()
        addSubview(stickersOverlay)
        stickersOverlay.translatesAutoresizingMaskIntoConstraints = false
        stickersOverlay.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stickersOverlay.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stickersOverlay.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stickersOverlay.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
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
//        recordButtonBottomAnchor = recordButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -72)
//        recordButtonBottomAnchor.isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        flashButton = UIButton(type: .custom)
        flashButton.setImage(UIImage(named:"flash_off"), for: .normal)
        flashButton.tintColor = UIColor.white
        addSubview(flashButton)
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        flashButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        flashButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        flashButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        flashButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        flashButton.applyShadow(radius: 6.0, opacity: 0.3, offset: .zero, color: .black, shouldRasterize: false)
        
        switchCameraButton = UIButton(type: .custom)
        switchCameraButton.setImage(UIImage(named:"SwitchCamera"), for: .normal)
        switchCameraButton.tintColor = UIColor.white
        addSubview(switchCameraButton)
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
        switchCameraButton.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -44).isActive = true
        switchCameraButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
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

        postButton = UIButton(type: .custom)
        postButton.setTitle("Post", for: .normal)
        postButton.titleLabel?.font = Fonts.semiBold(ofSize: 14)
        postButton.setTitleColor(UIColor.white, for: .normal)
        postButton.backgroundColor = accentColor
        addSubview(postButton)
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.contentEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 16)
        postButton.sizeToFit()
        postButton.layer.cornerRadius = postButton.frame.height / 2
        postButton.clipsToBounds = true
        
        postButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        postButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor).isActive = true
        postButton.isHidden = true
        postButton.applyShadow(radius: 6.0, opacity: 0.15, offset: CGSize(width: 0, height: 3.0), color: UIColor.black, shouldRasterize: false)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: postButton.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: postButton.centerYAnchor).isActive = true
        
        effectsButton = UIButton(type: .custom)
        effectsButton.setImage(UIImage(named:"effects"), for: .normal)
        addSubview(effectsButton)
        effectsButton.translatesAutoresizingMaskIntoConstraints = false
        effectsButton.tintColor = UIColor.white
        effectsButton.applyShadow(radius: 6.0, opacity: 0.3, offset: .zero, color: .black, shouldRasterize: false)
        effectsButton.addTarget(self, action: #selector(handleEffects), for: .touchUpInside)
        
        effectsButton.leadingAnchor.constraint(equalTo: recordButton.trailingAnchor, constant: 44).isActive = true
        effectsButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        effectsButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        effectsButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        effectsButton.applyShadow(radius: 6.0, opacity: 0.3, offset: .zero, color: .black, shouldRasterize: false)
        
        effectsBar = EffectsBar(frame:CGRect(x: 0, y: 0, width: bounds.width, height: 84))
        addSubview(effectsBar)
        effectsBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        effectsBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        effectsBar.barBottomAnchor = effectsBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 84 * 2)
        effectsBar.barBottomAnchor.isActive = true
        effectsBar.heightAnchor.constraint(equalToConstant: 84.0 * 2).isActive = true
        effectsBar.delegate = self
        
        recordButtonBottomAnchor = recordButton.bottomAnchor.constraint(equalTo: effectsBar.topAnchor, constant: -72)
        recordButtonBottomAnchor.isActive = true
        
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(handleSwitchCamera), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(handleTorch), for: .touchUpInside)
        stickerButton.addTarget(self, action: #selector(handleStickers), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
        
        optionsBar = CaptionBar(frame: .zero)
        optionsBar.alpha = 0.0
        addSubview(optionsBar)
        optionsBar.translatesAutoresizingMaskIntoConstraints = false
        optionsBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        optionsBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        optionsBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        optionsBarBottomAnchor = optionsBar.bottomAnchor.constraint(equalTo: bottomAnchor)
        optionsBarBottomAnchor.isActive = true
        optionsBar.handleTag = handleTag
    }
    
    var delegate:CameraHUDProtocol?
    @objc func handleClose() {
        delegate?.handleClose()
    }
    
    @objc func handleSwitchCamera() {
        delegate?.handleSwitchCamera()
    }
    
    @objc func handleTorch() {
        delegate?.handleTorch()
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
    
    func runningState() {
        closeButton.setStyle(.caretDown, animated: true)
        recordButton.reset()
        recordButton.isHidden = false
        switchCameraButton.isHidden = false
        flashButton.isHidden = false
        effectsButton.isHidden = false
        effectsBar.isHidden = false
        nextButton.isHidden = true
        stickerButton.isHidden = true
        stickersOverlay.isHidden = true
    }
    
    func recordingState() {
        recordButton.initiateRecordingAnimation()
        UIView.animate(withDuration: 0.5, animations: {
            self.closeButton.alpha = 0.0
            self.stickerButton.alpha = 0.0
        }) { _ in
            
            DispatchQueue.main.async {
                self.closeButton.setStyle(.close, animated: false)
                self.closeButton.isHidden = true
                self.stickerButton.isHidden = true
                self.closeButton.alpha = 1.0
                self.stickerButton.alpha = 1.0
                self.recordButton.startRecording()
            }
        }
    }
    
    func editingState() {
        closeButton.isHidden = false
        stickerButton.isHidden = false
        stickersOverlay.isHidden = false
        stickersOverlay.isUserInteractionEnabled = true
        closeButton.setStyle(.close, animated: true)
        
        recordButton.isHidden = true
        nextButton.isHidden = false
        switchCameraButton.isHidden = true
        flashButton.isHidden = true
        effectsButton.isHidden = true
        effectsBar.isHidden = true
        //hideCaptionBar()
    }
    
    func writingState(forward:Bool) {
        if forward {
            closeButton.setStyle(.caretLeft, animated: true)
            textView.isUserInteractionEnabled = true
            textView.becomeFirstResponder()
            
            postButton.alpha = 0.0
            postButton.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                self.stickerButton.alpha = 0.0
                self.nextButton.alpha = 0.0
                self.postButton.alpha = 1.0
                self.blurView.effect = UIBlurEffect(style: .dark)
                self.textView.alpha = 1.0
            })
        } else {
            textView.resignFirstResponder()
            textView.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.25, animations: {
                self.stickerButton.alpha = 1.0
                self.nextButton.alpha = 1.0
                self.postButton.alpha = 0.0
                self.blurView.effect = nil
                self.textView.alpha = 0.0
            }, completion: { _ in
                self.postButton.isHidden = true
            })
        }
        
    }
    
    func handleTag(_ tag:String) {
        if let last = textView.text.last {
            if last == " " {
                textView.text = textView.text + "\(tag) "
            } else {
                textView.text = textView.text + " \(tag) "
            }
        } else {
           textView.text = textView.text + "\(tag) "
        }
        //commentBar.textViewDidChange(commentBar.textView)
        
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
            //self.postButton.setTitle("Posting", for: .normal)
            //self.postButton.backgroundColor = UIColor.gray
            self.activityIndicator.alpha = 1.0
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @objc func handleEffects() {
        guard let image = delegate?.getCurrentImage() else { return }
        if !effectsBarIsOpen {
            effectsBar.setImage(image)
            self.effectsBarIsOpen = true
            let c1 = CGPoint(x: 0.23, y: 1)
            let c2 = CGPoint(x: 0.32, y: 1)
            let animator = UIViewPropertyAnimator(duration: 0.65, controlPoint1: c1, controlPoint2: c2, animations: {
                self.recordButtonBottomAnchor.constant = -36
                self.effectsBar.setBarPosition(.open_partial, animated: false)
                self.layoutIfNeeded()
            })
            animator.startAnimation()
            effectsButton.applyShadow(radius: 8.0, opacity: 0.5, offset: .zero, color: .white, shouldRasterize: false)
        } else {
            self.effectsBarIsOpen = false
            let c1 = CGPoint(x: 0.23, y: 1)
            let c2 = CGPoint(x: 0.32, y: 1)
            let animator = UIViewPropertyAnimator(duration: 0.65, controlPoint1: c1, controlPoint2: c2, animations: {
                self.recordButtonBottomAnchor.constant = -72
                self.effectsBar.setBarPosition(.closed, animated: false)
                self.layoutIfNeeded()
            })
            animator.startAnimation()
            effectsButton.applyShadow(radius: 6.0, opacity: 0.3, offset: .zero, color: .black, shouldRasterize: false)
        }
    }
}


extension CameraHUDView: KeyboardAccessoryProtocol {
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        self.optionsBarBottomAnchor.constant = -keyboardSize.height
        self.optionsBar.alpha = 1.0
        self.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        self.optionsBarBottomAnchor.constant = 0.0
        self.optionsBar.alpha = 0.0
        self.layoutIfNeeded()
    }
}

extension CameraHUDView: EffectsBarDelegate {
    func setEffect(_ effect: String?, _ intensity:Float?) {
        delegate?.setCameraEffect(effect, intensity)
    }
}
