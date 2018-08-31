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
import Pastel

protocol CameraHUDProtocol {
    func handleClose()
    func handleSwitchCamera()
    func handleTorch()
    func handleStickers()
    func handleNext()
    func handlePost()
    func getCurrentImage() -> CIImage?
    func setCameraEffect(_ effect:String?, _ intensity:Float?)
    func switchCameraMode(_ mode:CameraMode)
    func permissionsGranted(_ granted:Bool)
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
    var modeScrollBar:ModeScrollBar!
    var modePagerView:UIScrollView!
    var textViewPlaceholder:UILabel!
    var textView:UITextView!
    var textViewHeightAnchor:NSLayoutConstraint!
    var textViewLeadingAnchor:NSLayoutConstraint!
    var currentTextHeight:CGFloat = 0.0
    
    var stickerButton:UIButton!
    var closeButton:DynamicButton!
    var postButton:UIButton!
    var postWidthAnchor:NSLayoutConstraint!
    var activityIndicator:UIActivityIndicatorView!
    
    var effectsButton:UIButton!
    var effectsBar:EffectsBar!
    var effectsBarBottomAnchor:NSLayoutConstraint!
    var effectsBarIsOpen = false
    var blurAnimator:UIViewPropertyAnimator!
    
    var optionsBar:CaptionBar!
    var optionsBarBottomAnchor:NSLayoutConstraint!
    
    var stickersView:StickersView!
    var textOnlyBG:PastelView!
    var textMax:CGFloat = 0.0
    var whiteBar:UIView!
    
    var anonSwitch:AnonSwitch!
    
    var permissionsView:UIView?
    var cameraPermissionButton:UIButton?
    var microphonePermissionButton:UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        preservesSuperviewLayoutMargins = false
        
        textMax = frame.height * 0.4
        
        stickersOverlay = UIView()
        addSubview(stickersOverlay)
        stickersOverlay.translatesAutoresizingMaskIntoConstraints = false
        stickersOverlay.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stickersOverlay.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stickersOverlay.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stickersOverlay.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        blurView = UIVisualEffectView(effect: nil)
        blurView.isUserInteractionEnabled = false
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        textOnlyBG = PastelView(frame: bounds)
        // Custom Direction
        textOnlyBG.startPastelPoint = .topLeft
        textOnlyBG.endPastelPoint = .bottomRight
        
        
        // Custom Duration
        textOnlyBG.animationDuration = 12
        
        textOnlyBG.setColors([hexColor(from: "#007F4A"),
                              hexColor(from: "#00594C")])
        
        
        textOnlyBG.alpha = 0.0
        textOnlyBG.isUserInteractionEnabled = false
        addSubview(textOnlyBG)
        textOnlyBG.translatesAutoresizingMaskIntoConstraints = false
        textOnlyBG.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textOnlyBG.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textOnlyBG.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textOnlyBG.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        whiteBar = UIView()
        whiteBar.backgroundColor = UIColor.white
        addSubview(whiteBar)
        whiteBar.translatesAutoresizingMaskIntoConstraints = false
        whiteBar.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
        whiteBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20 + 32 + 6).isActive = true
        whiteBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        whiteBar.topAnchor.constraint(equalTo: topAnchor, constant: 64.0).isActive = true
        whiteBar.alpha = 0.0
        whiteBar.isHidden = true
        
        textViewPlaceholder = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 50))
        textViewPlaceholder.textColor = UIColor.white.withAlphaComponent(0.4)
        textViewPlaceholder.font = Fonts.light(ofSize: 22)
        textViewPlaceholder.text = "Write something..."
        textViewPlaceholder.alpha = 0.0
        addSubview(textViewPlaceholder)
        
        textViewPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        textViewPlaceholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24 + 32 + 6).isActive = true
        textViewPlaceholder.isUserInteractionEnabled = false
        textViewPlaceholder.topAnchor.constraint(equalTo: topAnchor, constant: 72).isActive = true
        
        stickersView = StickersView(frame: bounds)
        addSubview(stickersView)
        stickersView.translatesAutoresizingMaskIntoConstraints = false
        stickersView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stickersView.topAnchor.constraint(equalTo: topAnchor, constant: 64.0).isActive = true
        stickersView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stickersView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stickersView.alpha = 0.0
        stickersView.addSticker = addSticker

        modePagerView = UIScrollView(frame: bounds)
        modePagerView.delegate = self
        modePagerView.showsHorizontalScrollIndicator = false
        addSubview(modePagerView)

        modePagerView.contentSize = CGSize(width: bounds.width * 3, height: bounds.height)
        modePagerView.isPagingEnabled = true
        let vc1 = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        vc1.backgroundColor = UIColor.clear
        modePagerView.addSubview(vc1)
        let vc2 = UIView(frame: CGRect(x: bounds.width, y: 0, width: bounds.width, height: bounds.height))
        vc2.backgroundColor = UIColor.clear
        modePagerView.addSubview(vc2)
        
        let vc3 = UIView(frame: CGRect(x: bounds.width, y: 0, width: bounds.width * 2, height: bounds.height))
        vc3.backgroundColor = UIColor.clear
        modePagerView.addSubview(vc3)
        modePagerView.setContentOffset(CGPoint(x: bounds.width, y:0), animated: false)
        modeScrollBar = ModeScrollBar(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 52))
        
        addSubview(modeScrollBar)
        modeScrollBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        modeScrollBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        modeScrollBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        modeScrollBar.heightAnchor.constraint(equalToConstant: 52.0).isActive = true
        modeScrollBar.delegate = self
        
        textView = UITextView(frame: .zero)
        textView.backgroundColor = UIColor.clear
        textView.textContainerInset = UIEdgeInsetsMake(8, 20 + 32 + 6, 0, 20)
        textView.textColor = UIColor.white
        textView.keyboardAppearance = .dark
        textView.tintColor = UIColor.white
        textView.keyboardType = .twitter
        textView.font = Fonts.light(ofSize: 22)
        textView.delegate = self
        textView.isScrollEnabled = false
        
        addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textViewLeadingAnchor = textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        textViewLeadingAnchor.isActive = true
        textView.isUserInteractionEnabled = false
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 64.0).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textViewHeightAnchor = textView.heightAnchor.constraint(equalToConstant: 29.5)
        textViewHeightAnchor.isActive = true
        
        recordButton = RecordButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
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
        nextButton.setImage(UIImage(named:"pencil"), for: .normal)
        nextButton.backgroundColor = accentColor
        nextButton.titleLabel?.font = Fonts.semiBold(ofSize: 14)
        
        anonSwitch = AnonSwitch(frame:.zero)
        
        addSubview(anonSwitch)
        anonSwitch.translatesAutoresizingMaskIntoConstraints = false
        anonSwitch.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        anonSwitch.topAnchor.constraint(equalTo: topAnchor, constant: 64.0 + 4).isActive = true
        anonSwitch.widthAnchor.constraint(equalToConstant: 32).isActive = true
        anonSwitch.heightAnchor.constraint(equalToConstant: 32).isActive = true
        anonSwitch.layer.cornerRadius = 16
        anonSwitch.clipsToBounds = true
        anonSwitch.setAnonMode(to: UserService.anonMode)
        anonSwitch.alpha = 0.0
        
        nextButton.contentEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.sizeToFit()

        nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
        nextButton.clipsToBounds = true
        nextButton.isHidden = true
        
        nextButton.applyShadow(radius: 5.0, opacity: 0.3, offset: CGSize(width:0, height: 2), color: .black, shouldRasterize: false)
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
        postButton.titleLabel?.font = Fonts.bold(ofSize: 14)
        postButton.setTitleColor(accentColor, for: .normal)
        postButton.setTitleColor(UIColor.gray, for: .disabled)
        postButton.backgroundColor = UIColor.white
        addSubview(postButton)
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.contentEdgeInsets = UIEdgeInsetsMake(8, 14, 8, 14)
        postButton.sizeToFit()
        postButton.layer.cornerRadius = postButton.frame.height / 2
        postButton.clipsToBounds = true
        postButton.isEnabled = false
        postButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        postButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor).isActive = true
        postButton.alpha = 0.0
        postButton.applyShadow(radius: 4.0, opacity: 0.125, offset: CGSize(width: 0, height: 2.0), color: UIColor.black, shouldRasterize: false)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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
    
    var permissionStackView:UIStackView?
    var permissionBarView:UIView?
    
    func showPermissionOptions (_ cameraAccess: AVAuthorizationStatus, _ microphoneAccess: AVAuthorizationStatus) {
        var height:CGFloat = 0.0
        if cameraAccess != .authorized {
            height += 70
        }
        
        if microphoneAccess != .authorized {
            height += 70
        }
        
        
        
        permissionsView = UIImageView(image: UIImage(named:"Box2"))
        
        permissionsView!.isUserInteractionEnabled = true
        permissionsView!.backgroundColor = tagColor//UIColor.white.withAlphaComponent(0.35)
        addSubview(permissionsView!)
        permissionsView!.translatesAutoresizingMaskIntoConstraints = false
        permissionsView!.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        permissionsView!.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40).isActive = true
        permissionsView!.widthAnchor.constraint(equalToConstant: 240).isActive = true
        //permissionsView!.heightAnchor.constraint(equalToConstant: height).isActive = true
        permissionsView!.layer.cornerRadius = 12.0
        permissionsView!.clipsToBounds = true
        
        permissionStackView = UIStackView(frame: permissionsView!.bounds)
        permissionStackView!.axis = .vertical
        permissionStackView!.distribution = .fillProportionally
        permissionsView!.addSubview(permissionStackView!)
        
        permissionStackView!.translatesAutoresizingMaskIntoConstraints = false
        permissionStackView!.leadingAnchor.constraint(equalTo: permissionsView!.leadingAnchor).isActive = true
        permissionStackView!.topAnchor.constraint(equalTo: permissionsView!.topAnchor).isActive = true
        permissionStackView!.trailingAnchor.constraint(equalTo: permissionsView!.trailingAnchor).isActive = true
        permissionStackView!.bottomAnchor.constraint(equalTo: permissionsView!.bottomAnchor).isActive = true
        
        
        let buttonSelectedColor = UIColor.black.withAlphaComponent(0.25)
        
        cameraPermissionButton = UIButton(type: .custom)
        cameraPermissionButton!.setTitle("Allow Camera Access", for: .normal)
        cameraPermissionButton!.setTitleColor(UIColor.white, for: .normal)
        cameraPermissionButton!.setBackgroundColor(color: buttonSelectedColor, forState: .selected)
        cameraPermissionButton!.setBackgroundColor(color: buttonSelectedColor, forState: .highlighted)
        cameraPermissionButton!.setBackgroundColor(color: buttonSelectedColor, forState: .focused)
        cameraPermissionButton!.titleLabel?.font = Fonts.regular(ofSize: 18.0)
        cameraPermissionButton?.addTarget(self, action: #selector(handlePermissionTap), for: .touchUpInside)
        cameraPermissionButton?.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        microphonePermissionButton = UIButton(type: .custom)
        microphonePermissionButton!.setTitle("Allow Microphone Access", for: .normal)
        microphonePermissionButton!.setTitleColor(UIColor.white, for: .normal)
        microphonePermissionButton!.setBackgroundColor(color: buttonSelectedColor, forState: .selected)
        microphonePermissionButton!.setBackgroundColor(color: buttonSelectedColor, forState: .highlighted)
        microphonePermissionButton!.setBackgroundColor(color: buttonSelectedColor, forState: .focused)
        microphonePermissionButton!.titleLabel?.font = Fonts.regular(ofSize: 18.0)
        microphonePermissionButton?.heightAnchor.constraint(equalToConstant: 70).isActive = true
        microphonePermissionButton?.addTarget(self, action: #selector(handlePermissionTap), for: .touchUpInside)
        
        if cameraAccess != .authorized {
            permissionStackView!.addArrangedSubview(cameraPermissionButton!)
        }
        
        if microphoneAccess != .authorized {
            permissionStackView!.addArrangedSubview(microphonePermissionButton!)
        }
        
        if cameraAccess != .authorized, microphoneAccess != .authorized {
            permissionBarView = UIView()
            permissionBarView!.backgroundColor = UIColor.white
            permissionBarView!.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
            permissionsView!.addSubview(permissionBarView!)
            permissionBarView!.translatesAutoresizingMaskIntoConstraints = false
            permissionStackView!.insertArrangedSubview(permissionBarView!, at: 1)
        }
    }
    
    @objc func handlePermissionTap(_ target:UIButton) {
        switch target {
        case cameraPermissionButton:
            let cameraAccess = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if cameraAccess == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            self.permissionStackView?.removeArrangedSubview(self.cameraPermissionButton!)
                            self.cameraPermissionButton?.removeFromSuperview()
                            if let bar = self.permissionBarView {
                                self.permissionStackView?.removeArrangedSubview(bar)
                                bar.removeFromSuperview()
                            }
                            
                            if self.permissionStackView!.arrangedSubviews.count == 0 {
                                self.permissionsView?.removeFromSuperview()
                            }
                            
                            let microphoneGranted = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized
                            self.delegate?.permissionsGranted(microphoneGranted)
                        } else {
                            
                        }
                    }
                }
            } else if cameraAccess == .denied || cameraAccess == .restricted {
                let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(settingsUrl)
            }
            
            break
        case microphonePermissionButton:
            let microphoneAccess = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
            if microphoneAccess == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            self.permissionStackView?.removeArrangedSubview(self.microphonePermissionButton!)
                            self.microphonePermissionButton?.removeFromSuperview()
                            if let bar = self.permissionBarView {
                                self.permissionStackView?.removeArrangedSubview(bar)
                                bar.removeFromSuperview()
                            }
                            
                            if self.permissionStackView!.arrangedSubviews.count == 0 {
                                self.permissionsView?.removeFromSuperview()
                            }
                            
                            
                            let cameraGranted = AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
                            self.delegate?.permissionsGranted(cameraGranted)
                            
                            
                        } else {
                            
                        }
                    }
                }
            } else if microphoneAccess == .denied || microphoneAccess == .restricted {
                let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(settingsUrl)
            }
            
            break
        default:
            break
        }
        
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
    
    func toggleStickers(open:Bool) {
        if open {
            UIView.animate(withDuration: 0.3, animations: {
                //self.stickerButton.alpha = 0.0
                self.stickerButton.applyShadow(radius: 12.0, opacity:0.75, offset: .zero, color: .white, shouldRasterize: false)
                self.nextButton.alpha = 0.0
                self.blurView.effect = UIBlurEffect(style: .dark)
                self.stickersView.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.stickerButton.applyShadow(radius: 6.0, opacity: 0.3, offset: .zero, color: .black, shouldRasterize: false)
                self.nextButton.alpha = 1.0
                self.blurView.effect = nil
                self.stickersView.alpha = 0.0
            })
        }
        
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
        modePagerView.isHidden = false
        modeScrollBar.isHidden = false
        textView.resignFirstResponder()
        postButton.alpha = 0.0
        
        for subview in stickersOverlay.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func recordingState() {
        recordButton.initiateRecordingAnimation()
        modePagerView.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.closeButton.alpha = 0.0
            self.stickerButton.alpha = 0.0
            self.modeScrollBar.alpha = 0.0
            
        }) { _ in
            self.modeScrollBar.isHidden = true
            self.modeScrollBar.alpha = 1.0
            self.closeButton.setStyle(.close, animated: false)
            self.closeButton.isHidden = true
            self.stickerButton.isHidden = true
            self.closeButton.alpha = 1.0
            self.stickerButton.alpha = 1.0
            self.recordButton.startRecording()
        }
    }
    
    func editingState() {
        //modePagerView.isHidden = true
        closeButton.isHidden = false
        stickerButton.isHidden = false
        stickersOverlay.isHidden = false
        stickersOverlay.isUserInteractionEnabled = true
        
        stickersView.setupStickers()
        closeButton.setStyle(.close, animated: true)
        
        recordButton.isHidden = true
        nextButton.alpha = 1.0
        nextButton.isHidden = false
        switchCameraButton.isHidden = true
        flashButton.isHidden = true
        effectsButton.isHidden = true
        effectsBar.isHidden = true
        
        modePagerView.isHidden = true
        modeScrollBar.isHidden = true
        //hideCaptionBar()
    }
    
    func writingState(forward:Bool) {
        if forward {
            closeButton.setStyle(.caretLeft, animated: true)
            textView.isUserInteractionEnabled = true
            textView.becomeFirstResponder()
            
            postButton.alpha = 0.0
            
            UIView.animate(withDuration: 0.3, animations: {
                self.flashButton.alpha = 0.0
                self.stickerButton.alpha = 0.0
                self.nextButton.alpha = 0.0
                self.postButton.alpha = 1.0
                self.blurView.effect = UIBlurEffect(style: .dark)
                self.textView.alpha = 1.0
                self.anonSwitch.alpha = 1.0
                self.whiteBar.alpha = 1.0
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
                self.anonSwitch.alpha = 0.0
                self.whiteBar.alpha = 0.0
            }, completion: { _ in
            
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
        textViewDidChange(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addSticker(_ sticker:UIImage) {
        delegate?.handleClose()
        let dimensions = sticker.size
        let ratio = dimensions.height / dimensions.width
        let size = CGSize(width: 100 , height: 100 * ratio)
        let sFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let stickerView = StickerView(frame: sFrame)
        stickerView.setupSticker(sticker)
        stickerView.center = self.center
        stickerView.delegate = self
        
        stickersOverlay.addSubview(stickerView)
        
        stickerView.transform = CGAffineTransform(scaleX: 0.70, y: 0.70)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
            stickerView.transform = CGAffineTransform.identity
        }, completion: nil)
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
            self.activityIndicator.alpha = 1.0
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @objc func handleEffects() {
        setEffectsBar(open: !effectsBarIsOpen)
    }
    
    func setEffectsBar(open:Bool) {
        effectsBarIsOpen = open
        if effectsBarIsOpen {
            guard let image = delegate?.getCurrentImage() else { return }
            effectsBar.setImage(image)
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

extension CameraHUDView: StickerDelegate {
    func stickerDragBegan() {
        self.stickerButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
            self.stickerButton.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            self.stickerButton.alpha = 0.0
        } , completion: { _ in
            self.stickerButton.setImage(UIImage(named:"trash"), for: .normal)
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                self.stickerButton.transform = CGAffineTransform.identity
                self.stickerButton.alpha = 1.0
            } , completion: { _ in })
        })
        
    }
    
    func stickerDragEnded() {
        stickerButton.setImage(UIImage(named:"trash"), for: .normal)
        self.stickerButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
            self.stickerButton.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            self.stickerButton.alpha = 0.0
        } , completion: { _ in
            self.stickerButton.setImage(UIImage(named:"sticker"), for: .normal)
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                self.stickerButton.transform = CGAffineTransform.identity
                self.stickerButton.alpha = 1.0
            } , completion: { _ in })
        })
    }
    
    func stickerDidEnterTrashRange() {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
            self.stickerButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } , completion: { _ in
            
        })
    }
    
    func stickerDidLeaveTrashRange() {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
            self.stickerButton.transform = CGAffineTransform.identity
        } , completion: { _ in
            
        })
    }

}


extension CameraHUDView: KeyboardAccessoryProtocol {
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        textMax = bounds.height - 64.0 - 44.0 - keyboardSize.height - 8.0
        self.optionsBarBottomAnchor.constant = -keyboardSize.height
        self.optionsBar.alpha = 1.0
        self.textViewPlaceholder.alpha = 1.0
        self.layoutIfNeeded()
        
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        self.optionsBarBottomAnchor.constant = 0.0
        self.optionsBar.alpha = 0.0
        self.textViewPlaceholder.alpha = 0.0
        self.layoutIfNeeded()
    }
}

extension CameraHUDView: EffectsBarDelegate {
    func setEffect(_ effect: String?, _ intensity:Float?) {
        delegate?.setCameraEffect(effect, intensity)
    }
    
    
}

extension CameraHUDView:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let hasText = textView.text.count > 0
        textViewPlaceholder.isHidden = hasText
        postButton.isEnabled = hasText
        let height = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.infinity)).height
        
        textView.isUserInteractionEnabled = true
        if height != currentTextHeight {
            currentTextHeight = height
            if currentTextHeight > textMax {
                textViewHeightAnchor.constant = textMax
                textView.isScrollEnabled = true
                whiteBar.isHidden = false
            } else {
                textViewHeightAnchor.constant = currentTextHeight
                textView.isScrollEnabled = false
                whiteBar.isHidden = true
            }
            self.layoutIfNeeded()
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 600
    }
}

extension CameraHUDView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === modePagerView else { return }
        let offsetX = scrollView.contentOffset.x
        let viewWidth = bounds.width
        if offsetX < bounds.width {
            let progress = offsetX / viewWidth
            modeScrollBar?.setProgress(progress, index: 0)
            delegate?.switchCameraMode(progress > 0.5 ? .video : .photo)
            textView?.alpha = 0.0
            anonSwitch?.alpha = 0.0
            whiteBar?.alpha = 0.0
            textViewPlaceholder?.alpha = 0.0
            permissionsView?.alpha = 1.0
        } else {
            let progress = (offsetX - viewWidth) / viewWidth
            let reverseProgress = 1 - progress
            modeScrollBar?.setProgress(progress, index: 1)
            textOnlyBG?.alpha = progress
            recordButton?.alpha = reverseProgress
            permissionsView?.alpha = reverseProgress
            switchCameraButton?.alpha = reverseProgress
            flashButton?.alpha = reverseProgress
            effectsButton?.alpha = reverseProgress
            textView?.alpha = progress
            anonSwitch?.alpha = progress
            whiteBar?.alpha = progress
            textViewPlaceholder?.alpha = progress
            postButton?.alpha = progress
            delegate?.switchCameraMode(progress > 0.5 ? .text : .video)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    }
}

extension CameraHUDView: TabScrollDelegate {
    func tabScrollTo(index: Int) {
        modePagerView.setContentOffset(CGPoint(x: bounds.width * CGFloat(index), y: 0), animated: true)
    }
}
