//
//  CameraViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import Speech
import CoreLocation


var demoPic:UIImage?

enum CameraState {
    case initiating, running, recording, editing, stickers, writing, options
}

enum CameraMode {
    case video, photo, text
}

class CameraViewController: UIViewController, CameraHUDProtocol {
    
    var captureView:FilterCamView!
    var photoPreviewView:UIImageView!
    var hudView:CameraHUDView!
    
    var previewView:UIView!
    var videoPlayer: AVPlayer = AVPlayer()
    var playerLayer: AVPlayerLayer?
    var pageView:UIScrollView!
    
    var addVideo: ((URL)->())?
    
    var location:CLLocation?
    var region:Region?
    var cameraMode = CameraMode.video
    
    var shouldHideStatusBar = false
    override var prefersStatusBarHidden: Bool {
        get { return shouldHideStatusBar }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return .lightContent }
    }
    
    var state = CameraState.initiating
    
    func transition(toState newState:CameraState) {
        
        switch newState {
        case .initiating:
            break
        case .running:
            prevState = nil
            destroyCaptured()
            endLoopVideo()
            hudView.runningState()
            captureView.isHidden = false
            photoPreviewView.isHidden = false
            //photoPreviewView.image = nil
            videoURL = nil
            break
        case .recording:
            if state == .running {
                self.captureView.startRecording()
                self.hudView.recordingState()
            }
            break
        case .editing:
            
            videoPlayer.play()
            captureView.isHidden = true
            photoPreviewView.isHidden = false
            hudView.editingState()
            if state == .recording {
//                location = gpsService.getLastLocation()
//                region = gpsService.region
//                hudView.optionsBar.region = region
            } else if state == .writing {
                hudView.writingState(forward: false)
            } else if state == .stickers {
                hudView.closeButton.setStyle(.close, animated: true)
                hudView.toggleStickers(open: false)
            }
            break
        case .stickers:
            if state == .editing {
                videoPlayer.pause()
                hudView.closeButton.setStyle(.caretLeft, animated: true)
                hudView.toggleStickers(open: true)
            }
            break
        case .writing:
            prevState = nil
            videoPlayer.pause()
            if state == .editing {
                hudView.writingState(forward: true)
            } else if state == .running, cameraMode == .text {
                hudView.writingState(forward: true)
            } else if state == .options {
                self.hudView.optionsState(forward: false)
            }
            break
        case .options:
            prevState = state
            if state == .writing {
                self.hudView.optionsState(forward: true)
            } else if state == .running, cameraMode == .text {
                self.hudView.optionsState(forward: true)
            }
            break
        }
        
        self.state = newState
    }
    
    var prevState:CameraState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //demoPic = UIImage(named:"cooldude-pixel")!
        view.backgroundColor = UIColor.black
        captureView = FilterCamView(frame: view.bounds)
        captureView.handleEndRecording = stopRecording
        view.addSubview(captureView)
        
        captureView.translatesAutoresizingMaskIntoConstraints = false
        captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        captureView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        captureView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        previewView = UIView()
        view.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        photoPreviewView = UIImageView(image:demoPic)
        view.addSubview(photoPreviewView)
        photoPreviewView.translatesAutoresizingMaskIntoConstraints = false
        photoPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        photoPreviewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        photoPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        photoPreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        photoPreviewView.backgroundColor = UIColor.clear
        photoPreviewView.isUserInteractionEnabled = false
        photoPreviewView.contentMode = .scaleAspectFill
        
        hudView = CameraHUDView(frame: view.bounds)
        transition(toState: .running)
        view.addSubview(hudView)

        let recordTap = UITapGestureRecognizer(target: self, action: #selector(handleRecordTap))
        
        hudView.recordButton.isUserInteractionEnabled = true
        hudView.recordButton.addGestureRecognizer(recordTap)
        hudView.isUserInteractionEnabled = true
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hudView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hudView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hudView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        hudView.delegate = self
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        hudView.addGestureRecognizer(pinchGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSwitchCamera))
        tap.numberOfTapsRequired = 2
        hudView.addGestureRecognizer(tap)
        
        hudView.isUserInteractionEnabled = true
        
    }
    
    @objc func handlePinch(_ gesture:UIPinchGestureRecognizer) {
        captureView.handlePinchGesture(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        UIView.animate(withDuration: 0.45, animations: {
            self.shouldHideStatusBar = true
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
        hudView.observeKeyboard(true)
        hudView.anonSwitch.setProfileImage()
        
        let cameraAccess = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        let microphoneAccess = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        
        if cameraAccess == .authorized, microphoneAccess == .authorized {
            self.captureView.setup()
        } else {
            self.hudView.showPermissionOptions(cameraAccess, microphoneAccess)
        }
        
        regionUpdated()

        NotificationCenter.default.addObserver(self, selector: #selector(regionUpdated), name: GPSService.regionUpdatedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func willEnterForeground() {
        if state == .editing, videoURL != nil {
            videoPlayer.play()
        }
    }
    
    @objc func willResignActive() {
        stopRecording()
    }
    
    @objc func regionUpdated() {
        location = gpsService.getLastLocation()
        region = gpsService.region
        hudView.optionsBar.region = region
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hudView.textOnlyBG.startStatic()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        destroyCameraSession()
        destroyCaptured()
        hudView.observeKeyboard(false)
        
        NotificationCenter.default.removeObserver(self, name: GPSService.regionUpdatedNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: nil)
         NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    
    func destroyCameraSession() {
        captureView.destroy()
    }
    
    func destroyCaptured() {
        videoPlayer.replaceCurrentItem(with: nil)
        playerLayer?.player = nil
        playerLayer = nil
    }
    
    func handleClose() {
        print("TO THE CLOSE!")
        switch state {
        case .running:
            if cameraMode == .text, hudView.textView.isFirstResponder {
                let point = CGPoint(x: hudView.bounds.width, y: 0)
                hudView.modePagerView.setContentOffset(point, animated: true)
            } else {
               self.dismiss(animated: true, completion: nil)
            }
            
            break
        case .editing:
            transition(toState: .running)
            break
        case .stickers:
            transition(toState: .editing)
            break
        case .writing:
            transition(toState: .editing)
            break
        case .options:
            if let prevState = prevState {
                transition(toState: prevState)
            }
            break
        default:
            break
        }
    }
    
    @objc func handleSwitchCamera() {
        captureView.switchCamera()
        hudView.flashButton.isHidden = !captureView.isBackCameraActive
    }
    
    var pushTransitionManager = PushTransitionManager()
    
    func handleTorch() {
        let t = captureView.toggleTorch()
        let image = t ? UIImage(named: "flash") : UIImage(named:"flash_off")
        hudView.flashButton.setImage(image, for: .normal)
    }
    
    func handleNext() {
        switch state {
        case .editing:
            transition(toState: .writing)
            break
        default:
            break
        }
    }
    
    func handlePost() {
        
        
        if state == .running, cameraMode == .text {
            transition(toState: .options)
        } else if state == .writing {
            transition(toState: .options)
        } else if state == .options {
            hudView.startPostAnimation()
            hudView.modeScrollBar.isHidden = true
            hudView.isUserInteractionEnabled = false
            hudView.textView.resignFirstResponder()
            if !hudView.optionsBar.includeRegion {
                self.region = nil
                self.location = nil
            }
            
            let group = hudView.selectedGroup
            
            if let url = videoURL {
                self.processVideoWithWatermark(videoURL: url) { _compressedVideoURL in
                    
                    DispatchQueue.main.async {
                        if let compressedVideoURL = _compressedVideoURL {
                            UploadService.getNewPostID { postID in
                                if let postID = postID {
                                    UploadService.uploadPost(postID: postID,
                                                             text: self.hudView.textView.text,
                                                             group: group,
                                                             image: nil,
                                                             videoURL: compressedVideoURL,
                                                             gif: nil,
                                                             region:self.region,
                                                             location: self.location)
                                    
                                    let _ = Alerts.showInfoAlert(withMessage: "Uploading...")
                                    self.dismiss(animated: true, completion: nil)
                                } else {
                                    let _ = Alerts.showFailureAlert(withMessage: "Failed to upload.")
                                }
                            }
                            
                        }
                    }
                }
            } else if let image = photoPreviewView.image {
                
                var newImage = image
                if hudView.stickersOverlay.subviews.count > 0,
                    let overlayImage = hudView.stickersOverlay.snapshot(of: hudView.stickersOverlay.bounds, _isOpaque: false)?.image {
                    let size = view.bounds.size
                    UIGraphicsBeginImageContext(size)
                    
                    let areaSize = view.bounds
                    image.draw(in: areaSize)
                    
                    overlayImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
                    
                    newImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                }
                
                
                UploadService.getNewPostID { postID in
                    if let postID = postID {
                        UploadService.uploadPost(postID: postID,
                                                 text: self.hudView.textView.text,
                                                 group: group,
                                                 image: newImage,
                                                 videoURL: nil,
                                                 gif: nil,
                                                 region:self.region,
                                                 location: self.location)
                        
                        let _ = Alerts.showInfoAlert(withMessage: "Uploading...")
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let _ = Alerts.showFailureAlert(withMessage: "Failed to upload.")
                    }
                }
                
            } else {
                UploadService.getNewPostID { postID in
                    if let postID = postID {
                        UploadService.uploadPost(postID: postID,
                                                 text: self.hudView.textView.text,
                                                 group: group,
                                                 image: nil,
                                                 videoURL: nil,
                                                 gif: nil,
                                                 region:self.region,
                                                 location: self.location)
                        
                        let _ = Alerts.showInfoAlert(withMessage: "Uploading...")
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let _ = Alerts.showFailureAlert(withMessage: "Failed to upload.")
                    }
                }
                
            }
            
        }

    }
    
    @objc func handleStickers() {
        switch state {
        case .stickers:
            transition(toState: .editing)
            break
        case .editing:
            transition(toState: .stickers)
            break
        default:
            break
        }
    }
    
    func switchCameraMode(_ mode: CameraMode) {
        if mode != self.cameraMode {
            
            switch mode {
            case .text:
                hudView.textView.isUserInteractionEnabled = true
                hudView.textView.becomeFirstResponder()
                hudView.closeButton.setStyle(.caretLeft, animated: true)
                hudView.setEffectsBar(open: false)
                break
            default:
                if cameraMode == .text {
                    hudView.closeButton.setStyle(.close, animated: true)
                    hudView.textView.isUserInteractionEnabled = false
                    hudView.textView.resignFirstResponder()
                }
                break
            }
            cameraMode = mode
            
        }
    }
    
    func permissionsGranted(_ granted: Bool) {
        if granted {
            self.captureView.setup()
        }
    }
    
    func processVideoWithWatermark(videoURL: URL, completion: @escaping (_ url:URL?) -> Void) {
        
    
        let composition = AVMutableComposition()
        let asset = AVAsset(url: videoURL)
        asset.loadValuesAsynchronously(forKeys: ["playable", "tracks"]) {
            DispatchQueue.main.async {
            
            let videoTracks =  asset.tracks(withMediaType: AVMediaType.video)

            let audioTracks = asset.tracks(withMediaType: .audio)
            let videoTrack:AVAssetTrack = videoTracks[0] as AVAssetTrack
            
            let view = self.view!
            let hudView = self.hudView!
            
            let timerange = CMTimeRangeMake(kCMTimeZero, asset.duration)
            
            let compositionVideoTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())!
            
            let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
            
            do {
                try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: kCMTimeZero)
                compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
                
                try compositionAudioTrack.insertTimeRange(timerange, of: audioTracks[0], at: kCMTimeZero)
            } catch {
                print(error)
            }
            
            let size = videoTrack.naturalSize
            
            let videolayer = CALayer()
            videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            let parentlayer = CALayer()
            parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            parentlayer.addSublayer(videolayer)
            
            for i in 0..<hudView.stickersOverlay.subviews.count {
                let s = hudView.stickersOverlay.subviews[i] as! StickerView
                
                let imageView = s.imageNode!
                let watermarkImage = imageView.image!
                
                let watermark = watermarkImage.cgImage
                
                let currentTransform = s.transform
                s.transform = .identity
                let originalFrame = s.frame
                s.transform = currentTransform
                let sFrame = originalFrame
                
                let watermarklayer = CALayer()
                watermarklayer.contents = watermark
                
                let screenSize = UIScreen.main.bounds.size
                
                let m:CGFloat = size.height / screenSize.height
                let y = view.bounds.height - sFrame.origin.y - sFrame.height
                watermarklayer.frame = CGRect(x: sFrame.origin.x * m,
                                              y: y * m,
                                              width: sFrame.width * m,
                                              
                                              height: sFrame.height * m )
                
                let radians = atan2(currentTransform.b, currentTransform.a)
                let degrees:CGFloat = radians * (CGFloat(180) / CGFloat(Double.pi) )
                
                var shift = 0.0
                
                if degrees > 0 {
                    shift = -Double(degrees * 2).degreesToRadians
                } else {
                    let absDegrees = abs(degrees)
                    shift = Double(absDegrees * 2).degreesToRadians
                }
                
                
                let shiftedTransform = currentTransform.concatenating(CGAffineTransform(rotationAngle: CGFloat(shift)))
                watermarklayer.opacity = 1
                watermarklayer.setAffineTransform(shiftedTransform)
                parentlayer.addSublayer(watermarklayer)
            }
            
            let layercomposition = AVMutableVideoComposition()
            layercomposition.frameDuration = CMTimeMake(1, 30)
            layercomposition.renderSize = CGSize(width: size.width, height: size.height)
            layercomposition.renderScale = 1.0
            layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
            
            let videotrack = composition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
            let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
            layerinstruction.setTransform(videoTrack.preferredTransform, at: kCMTimeZero)
            
            instruction.layerInstructions = [layerinstruction]
            layercomposition.instructions = [instruction]
            
            let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let movieUrl = documentDirectory.appendingPathComponent("watermarktest.mp4")
            
            do {
                try fileManager.removeItem(at: movieUrl)
            } catch {
                
            }
            
            guard let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetMediumQuality) else {return}
            assetExport.videoComposition = layercomposition
            assetExport.outputFileType = AVFileType.mp4
            assetExport.outputURL = movieUrl
            assetExport.shouldOptimizeForNetworkUse = true
            
            assetExport.exportAsynchronously(completionHandler: {
                
                switch assetExport.status {
                case .completed:
                    print("success")
                    return completion(movieUrl)
                case .cancelled:
                    print("cancelled")
                    break
                case .exporting:
                    print("exporting")
                    break
                case .failed:
                    print("failed: \(assetExport.error!)")
                    break
                case .unknown:
                    print("unknown")
                    break
                case .waiting:
                    print("waiting")
                    break
                }
            })
            return completion(nil)
            }
        }
        
    }
    
    func getCurrentImage() -> CIImage? {
        if demoPic != nil {
            return CIImage(image:demoPic!)
        }
        return captureView.currentImage
    }
    
    func setCameraEffect(_ effect:String?, _ intensity:Float?) {
        captureView.effectName = effect
        captureView.intensity = intensity
    }
    
    var videoURL:URL?
    @objc func handleRecordTap(_ tap:UITapGestureRecognizer) {
        switch state {
        case .running:
            switch cameraMode {
            case .video:
                transition(toState: .recording)
                break
            case .photo:
                if demoPic != nil {
                    self.photoPreviewView.image = demoPic
                    self.transition(toState: .editing)
                } else {
                    captureView.capturePhoto { image in
                        self.photoPreviewView.image = image
                        self.transition(toState: .editing)
                    }
                }
                
                break
            case .text:
                break
            }
            break
        case .recording:
            stopRecording()
            break
        default:
            break
        }
    }
    
    @objc func stopRecording() {
        self.captureView.stopRecording() { _url in
            guard let url = _url else { return }
            self.videoURL = url
            self.videoPlayer.replaceCurrentItem(with: AVPlayerItem(url: url))
            self.playerLayer = AVPlayerLayer(player: self.videoPlayer)
            self.playerLayer!.frame = self.view.bounds
            self.previewView.layer.insertSublayer(self.playerLayer!, at: 0)
            self.playerLayer!.player?.actionAtItemEnd = .none
            self.loopVideo()
            self.transition(toState: .editing)
        }
    }

    func recordVideo() {
        hudView.recordButton.startRecording()
    }
    
    func loopVideo() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            self.playerLayer?.player?.seek(to: kCMTimeZero)
            self.playerLayer?.player?.play()
        }
    }
    
    func endLoopVideo() {
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime, name: nil, object: nil)
    }
}

