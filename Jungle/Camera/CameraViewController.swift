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

enum CameraState {
    case initiating, running, recording, editing, stickers, writing
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
            destroyCaptured()
            endLoopVideo()
            hudView.runningState()
            captureView.isHidden = false
            photoPreviewView.isHidden = true
            photoPreviewView.image = nil
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
            videoPlayer.pause()
            if state == .editing {
                hudView.writingState(forward: true)
            } else if state == .running, cameraMode == .text {
                hudView.writingState(forward: true)
            }
            break
        }
        self.state = newState
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureView = FilterCamView(frame: view.bounds)
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
        
        photoPreviewView = UIImageView(image:nil)
        view.addSubview(photoPreviewView)
        photoPreviewView.translatesAutoresizingMaskIntoConstraints = false
        photoPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        photoPreviewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        photoPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        photoPreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        photoPreviewView.backgroundColor = UIColor.clear
        photoPreviewView.isUserInteractionEnabled = false
        
        hudView = CameraHUDView(frame: view.bounds)
        transition(toState: .running)
        view.addSubview(hudView)
        //hudView.isHidden = true
        
        //let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleRecordPress))
        let recordTap = UITapGestureRecognizer(target: self, action: #selector(handleRecordTap))
        //longPress.minimumPressDuration = 0.0
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
        
        self.captureView.setup()
        
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
        default:
            break
        }
    }
    
    func handleSwitchCamera() {
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
        hudView.startPostAnimation()
        hudView.textView.resignFirstResponder()
        if !hudView.optionsBar.includeRegion {
            self.region = nil
            self.location = nil
        }
        
        if let url = videoURL {
            self.processVideoWithWatermark(videoURL: url) { _compressedVideoURL in
                
                DispatchQueue.main.async {
                    
                    //alert.configureContent(body: "Uploading...")
                    
                    if let compressedVideoURL = _compressedVideoURL {
                        UploadService.uploadPost(text: self.hudView.textView.text,
                                                 image: nil,
                                                 videoURL: compressedVideoURL,
                                                 gif: nil,
                                                 region:self.region,
                                                 location: self.location)
                        UserService.recentlyPosted = true
                        let _ = Alerts.showInfoAlert(withMessage: "Uploading...")
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else if let image = photoPreviewView.image {
            UploadService.uploadPost(text: self.hudView.textView.text,
                                     image: image,
                                     videoURL: nil,
                                     gif: nil,
                                     region:self.region,
                                     location: self.location)
            UserService.recentlyPosted = true
            let _ = Alerts.showInfoAlert(withMessage: "Uploading...")
            self.dismiss(animated: true, completion: nil)
        } else {
            print("POSTING WITHOUT ATTACHMENTS!")
            UploadService.uploadPost(text: self.hudView.textView.text,
                                     image: nil,
                                     videoURL: nil,
                                     gif: nil,
                                     region:self.region,
                                     location: self.location)
            UserService.recentlyPosted = true
            let _ = Alerts.showInfoAlert(withMessage: "Uploading...")
            self.dismiss(animated: true, completion: nil)
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
    
    func processVideoWithWatermark(videoURL: URL, completion: @escaping (_ url:URL?) -> Void) {
        
    
        let composition = AVMutableComposition()
        let asset = AVAsset(url: videoURL)
        asset.loadValuesAsynchronously(forKeys: ["playable", "tracks"]) {
            DispatchQueue.main.async {
                
            
            let videoTracks =  asset.tracks(withMediaType: AVMediaType.video)
            //print("TRACK!: \(track)")
            let audioTracks = asset.tracks(withMediaType: .audio)
            print("VIDEO TRACKS: \(videoTracks)")
            print("AUDIO TRACKS: \(audioTracks)")
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
                //let sFrame = s.frame
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
                print("RXC - ss:\(screenSize) | vs: \(size)")
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
                    
                    break
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
        return captureView.currentImage
    }
    
    func setCameraEffect(_ effect:String?, _ intensity:Float?) {
        captureView.effectName = effect
        captureView.intensity = intensity
    }
    
    @objc func handleCaptionBack() {
        let controller = ConfigurePostViewController()
        self.navigationController?.pushViewController(controller, animated: true)
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
                captureView.capturePhoto { image in
                    self.photoPreviewView.image = image
                    self.transition(toState: .editing)
                }
                break
            case .text:
                break
            }
            break
        case .recording:
            
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
            break
        default:
            break
        }
    }

    func recordVideo() {
        hudView.recordButton.startRecording()
    }
    
    func stopRecordingVideo() {
        //self.state = .endRecording
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
//
//
//func transcribeRecording(completion: @escaping ((_ transcription:String?)->())) {
//    //guard let videoURL = videoURL else { return }
//    
//    
//    let audioEngine = AVAudioEngine()
//    let speechRecognizer = SFSpeechRecognizer()
//    let request = SFSpeechAudioBufferRecognitionRequest()
//    var recognitionTask:SFSpeechRecognitionTask?
//    
//    
//    let asset = AVAsset(url: videoURL)
//    asset.loadValuesAsynchronously(forKeys: ["playable", "tracks"]) {
//        DispatchQueue.main.async {
//            
//            let fileManager = FileManager.default
//            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let filePath = documentDirectory.appendingPathComponent("output_audio.m4a")
//            
//            do {
//                try fileManager.removeItem(at: filePath)
//            } catch {
//                print("UHUH")
//            }
//            asset.writeAudioTrackToURL(filePath) { completed, error in
//                guard completed, error == nil else { return }
//                
//                SFSpeechRecognizer.requestAuthorization { authStatus in
//                    if (authStatus == .authorized) {
//                        // Get the party started and watch for results in the completion block.
//                        // It gets fired every time a new word (aka transcription) gets detected.
//                        let request = SFSpeechURLRecognitionRequest(url: filePath)
//                        
//                        speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
//                            
//                            if let result = result {
//                                var transcription:String?
//                                if result.isFinal {
//                                    transcription = result.bestTranscription.formattedString
//                                }
//                                completion(transcription)
//                            } else {
//                                print("ERROR: \(error?.localizedDescription)")
//                            }
//                            
//                        })
//                    } else {
//                        print("Error: Speech-API not authorized!");
//                    }
//                }
//            }
//        }
//    }
//    
//    
//}
