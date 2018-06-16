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
import Hero
import Photos
import Pulley
import Speech

enum CameraState {
    case initiating, running, recording, endRecording, editing, writing
}

class CameraViewController: UIViewController, CameraHUDProtocol, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    
    var captureView:CaptureSessionView!
    var hudView:CameraHUDView!
    
    var previewView:UIView!
    var videoPlayer: AVPlayer = AVPlayer()
    var playerLayer: AVPlayerLayer?
    var pageView:UIScrollView!
    
    var addVideo: ((URL)->())?
    
    var shouldHideStatusBar = false
    override var prefersStatusBarHidden: Bool {
        get { return shouldHideStatusBar }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return .lightContent }
    }
    
    var state = CameraState.initiating {
        didSet {
            switch state {
            case .initiating:
                break
            case .running:
                destroyCaptured()
                endLoopVideo()
                
                hudView.closeButton.setStyle(.caretDown, animated: true)
                hudView.recordButton.reset()
                hudView.recordButton.isHidden = false
                hudView.switchCameraButton.isHidden = false
                hudView.nextButton.isHidden = true
                hudView.stickerButton.isHidden = true
                hudView.stickersOverlay.isHidden = true
                captureView.isHidden = false
                break
            case .recording:
                break
            case .endRecording:
                break
            case .editing:
                
                videoPlayer.play()
                hudView.closeButton.isHidden = false
                hudView.stickerButton.isHidden = false
                hudView.stickersOverlay.isHidden = false
                hudView.stickersOverlay.isUserInteractionEnabled = true
                hudView.closeButton.setStyle(.close, animated: true)
                captureView.isHidden = true
                hudView.recordButton.isHidden = true
                hudView.nextButton.isHidden = false
                hudView.switchCameraButton.isHidden = true
                hudView.hideCaptionBar()
                break
            case .writing:
                videoPlayer.pause()
                hudView.stickersOverlay.isUserInteractionEnabled = false
                hudView.closeButton.setStyle(.caretLeft, animated: true)
                hudView.showCaptionBar()
                break
                
            }
        }
    }
    
    func transcribeRecording(completion: @escaping ((_ transcription:String?)->())) {
        guard let videoURL = videoURL else { return }
        
        
        let audioEngine = AVAudioEngine()
        let speechRecognizer = SFSpeechRecognizer()
        let request = SFSpeechAudioBufferRecognitionRequest()
        var recognitionTask:SFSpeechRecognitionTask?
        
        
        let asset = AVAsset(url: videoURL)
        asset.loadValuesAsynchronously(forKeys: ["playable", "tracks"]) {
            DispatchQueue.main.async {
                
                let fileManager = FileManager.default
                let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let filePath = documentDirectory.appendingPathComponent("output_audio.m4a")

                do {
                    try fileManager.removeItem(at: filePath)
                } catch {
                    print("UHUH")
                }
                asset.writeAudioTrackToURL(filePath) { completed, error in
                    guard completed, error == nil else { return }
                    
                    SFSpeechRecognizer.requestAuthorization { authStatus in
                        if (authStatus == .authorized) {
                            // Get the party started and watch for results in the completion block.
                            // It gets fired every time a new word (aka transcription) gets detected.
                            let request = SFSpeechURLRecognitionRequest(url: filePath)
                            
                            speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
                                
                                if let result = result {
                                    var transcription:String?
                                    if result.isFinal {
                                        transcription = result.bestTranscription.formattedString
                                    }
                                    completion(transcription)
                                } else {
                                    print("ERROR: \(error?.localizedDescription)")
                                }
                                
                            })
                        } else {
                            print("Error: Speech-API not authorized!");
                        }
                    }
                }
            }
        }
    

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureView = CaptureSessionView(frame: view.bounds)
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
        
        hudView = CameraHUDView(frame: view.bounds)
        state = .running
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        UIView.animate(withDuration: 0.45, animations: {
            self.shouldHideStatusBar = true
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
        hudView.observeKeyboard(true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        destroyCameraSession()
        destroyCaptured()
        hudView.observeKeyboard(false)
    }
    
    
    func destroyCameraSession() {
        captureView.destroySession()
    }
    
    func destroyCaptured() {
        videoPlayer.replaceCurrentItem(with: nil)
        playerLayer?.player = nil
        playerLayer = nil
    }
    
    func handleClose() {
        switch state {
        case .running:
            self.dismiss(animated: true, completion: nil)
            break
        case .editing:
            state = .running
            break
        case .writing:
            state = .editing
            break
        default:
            break
        }
    }
    
    func handleSwitchCamera() {
        captureView.switchCamera()
    }
    
    func handleNext() {
        switch state {
        case .editing:
            state = .writing
            break
        default:
            break
        }
    }
    
    func handlePost() {
        guard let url = videoURL else {return}
        hudView.startPostAnimation()
        Alerts.showInfoAlert(withMessage: "Uploading...")
        hudView.commentBar.textView.resignFirstResponder()
        processVideoWithWatermark(videoURL: url) { _compressedVideoURL in
            self.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
                if let compressedVideoURL = _compressedVideoURL {
                    //self.addVideo?(compressedVideoURL)
                    UploadService.uploadPost(text: self.hudView.commentBar.textView.text,
                                             image: nil,
                                             videoURL: compressedVideoURL,
                                             gif: nil,
                                             includeLocation:true)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func handleStickers() {
        if let x = pulleyViewController?.drawerContentViewController as? StickerViewController {
            x.addSticker = hudView.addSticker
        }
        pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
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
            
                print("SIZE TING: \(size)")
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
                    
                    
                    //                PHPhotoLibrary.shared().performChanges({
                    //                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: movieUrl)
                    //                }) { saved, error in
                    //                    if saved {
                    //                        let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    //                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    //                        alertController.addAction(defaultAction)
                    //                        self.present(alertController, animated: true, completion: nil)
                    //                    }
                    //                }
                    
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
    
    @objc func handleCaptionBack() {
//        UIView.animate(withDuration: 0.20, delay: 0, options: .curveEaseInOut, animations: {
//            self.previewView.alpha = 1.0
//            self.pageView.contentOffset = CGPoint(x: 0.0, y: 0.0)
//        }, completion: nil)
        let controller = ConfigurePostViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleRecordTap(_ tap:UITapGestureRecognizer) {
        switch state {
        case .running:
            clipCount = 0
            clipURLs = []
            hudView.recordButton.initiateRecordingAnimation()
            UIView.animate(withDuration: 0.5, animations: {
                self.hudView.closeButton.alpha = 0.0
                self.hudView.stickerButton.alpha = 0.0
            }) { _ in
                
                DispatchQueue.main.async {
                    self.hudView.closeButton.setStyle(.close, animated: false)
                    self.hudView.closeButton.isHidden = true
                    self.hudView.stickerButton.isHidden = true
                    self.hudView.closeButton.alpha = 1.0
                    self.hudView.stickerButton.alpha = 1.0
                    self.recordVideo()
                }
            }
            break
        case .recording:
            stopRecordingVideo()
            break
        default:
            break
        }
    }
//    @objc func handleRecordPress(_ gesture:UILongPressGestureRecognizer) {
//
//
//        switch state {
//        case .running:
//            if gesture.state == .began {
//                hudView.recordButton.initiateRecordingAnimation()
//                UIView.animate(withDuration: 0.5, animations: {
//                    self.hudView.closeButton.alpha = 0.0
//                    self.hudView.stickerButton.alpha = 0.0
//                }) { _ in
//
//                    DispatchQueue.main.async {
//                        self.hudView.closeButton.setStyle(.close, animated: false)
//                        self.hudView.closeButton.isHidden = true
//                        self.hudView.stickerButton.isHidden = true
//                        self.hudView.closeButton.alpha = 1.0
//                        self.hudView.stickerButton.alpha = 1.0
//                        self.recordVideo()
//                    }
//                }
//            }
//            break
//        case .recording:
//            if gesture.state == .began {
//                stopRecordingVideo()
//            }
//            break
//        default:
//            break
//        }
//    }
    
    var clipCount = 0
    var clipURLs = [URL]()
    func setOutputPath() {
        let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let filePath = documentsURL.appendingPathComponent("captured/captureOutput_\(clipCount).mov")
            captureView.videoFileOutput?.startRecording(to: filePath, recordingDelegate: recordingDelegate!)
            
        } catch {
            print("OH DAMN")
        }
        
        clipCount += 1
    }

    func recordVideo() {
        setOutputPath()
        hudView.recordButton.startRecording()
    }
    func stopRecordingVideo() {
        self.state = .endRecording
        captureView.videoFileOutput?.stopRecording()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("DID START RECORDING")
        self.state = .recording
        return
    }
    
    var videoURL:URL?
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        clipURLs.append(outputFileURL)
        if state == .endRecording {
            videoURL = outputFileURL
            mc { outputURL in
                guard let url = outputURL else { return }
                self.videoURL = url
                
                let item = AVPlayerItem(url: self.videoURL!)
                self.videoPlayer.replaceCurrentItem(with: item)
                self.playerLayer = AVPlayerLayer(player: self.videoPlayer)
                
                self.playerLayer!.frame = self.view.bounds
                self.previewView.layer.insertSublayer(self.playerLayer!, at: 0)
                self.playerLayer!.player?.actionAtItemEnd = .none
                self.loopVideo()
                
                self.state = .editing
                
            }
            //state = .editing
            
            //loopVideo()
        } else if state == .recording {
            print("SETUP NEW RECORDING")
            recordVideo()
        }
    }
    
    func mc(completion:@escaping((_ outputURL:URL?)->())) {
        var assets = [AVAsset]()
        for clipURL in clipURLs {
            let asset = AVAsset(url: clipURL)
            assets.append(asset)
        }
        
        KVVideoManager.shared.merge(arrayVideos: assets) { (outputURL, error) in
            completion(outputURL)
        }
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
