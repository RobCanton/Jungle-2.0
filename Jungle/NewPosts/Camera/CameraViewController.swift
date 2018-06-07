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

enum CameraState {
    case running, videoCaptured
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    
    var captureView:CaptureSessionView!
    var hudView:CameraHUDView!
    
    var previewView:UIView!
    var videoPlayer: AVPlayer = AVPlayer()
    var playerLayer: AVPlayerLayer?
    var pageView:UIScrollView!
    var state = CameraState.running
    
    var addVideo: ((URL)->())?
    
    var shouldHideStatusBar = false
    override var prefersStatusBarHidden: Bool {
        get { return shouldHideStatusBar }
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
        
        view.addSubview(hudView)
        //hudView.isHidden = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleRecordPress))
        longPress.minimumPressDuration = 0.0
        hudView.recordButton.isUserInteractionEnabled = true
        hudView.recordButton.addGestureRecognizer(longPress)
        hudView.isUserInteractionEnabled = true
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hudView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hudView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hudView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        hudView.closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        hudView.nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        hudView.stickerButton.addTarget(self, action: #selector(handleStickers), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        UIView.animate(withDuration: 0.45, animations: {
            self.shouldHideStatusBar = true
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        destroyCameraSession()
    }
    
    func destroyCameraSession() {
        captureView.destroySession()
    }
    
    func destroyCaptured() {
        playerLayer?.player = nil
        playerLayer = nil
    }
    
    @objc func handleClose() {
        switch state {
        case .running:
            self.dismiss(animated: true, completion: nil)
            break
        case .videoCaptured:
            destroyCaptured()
            endLoopVideo()
            hudView.recordButton.reset()
            hudView.recordButton.isHidden = false
            hudView.nextButton.isHidden = true
            captureView.isHidden = false
            //hudView.isHidden = true
            state = .running
            break
        }
    }
    
    @objc func handleNext() {
        guard let url = videoURL else {return}
        processVideoWithWatermark(videoURL: url) { _compressedVideoURL in
            DispatchQueue.main.async {
                if let compressedVideoURL = _compressedVideoURL {
                    self.addVideo?(compressedVideoURL)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func handleStickers() {
        print("Open stickers!")
        if let x = pulleyViewController?.drawerContentViewController as? StickerViewController {
            print("WE GOOD MAN WE GOOODD!!!")
            x.addSticker = hudView.addSticker
        }
        pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
    }
    
    func processVideoWithWatermark(videoURL: URL, completion: @escaping (_ url:URL?) -> Void) {
        
    
        let composition = AVMutableComposition()
        let asset = AVURLAsset(url: videoURL, options: nil)
        
        let track =  asset.tracks(withMediaType: AVMediaType.video)
        let videoTrack:AVAssetTrack = track[0] as AVAssetTrack
        let timerange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        
        let compositionVideoTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())!
        
        do {
            try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: kCMTimeZero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            print(error)
        }
        
        let size = videoTrack.naturalSize
        
//        watermarklayer.frame = CGRect(x: hudView.sticker.frame.origin.x * m,
//                                      y: hudView.sticker.frame.origin.y * m,
//                                      width: hudView.sticker.frame.width * m,
//                                      height: hudView.sticker.frame.height * m)
        
        
        let videolayer = CALayer()
        videolayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        
        let parentlayer = CALayer()
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.width)
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
            let m = size.height / screenSize.width
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
        layercomposition.renderSize = CGSize(width: size.height, height: size.width)
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
    
    @objc func handleCaptionBack() {
//        UIView.animate(withDuration: 0.20, delay: 0, options: .curveEaseInOut, animations: {
//            self.previewView.alpha = 1.0
//            self.pageView.contentOffset = CGPoint(x: 0.0, y: 0.0)
//        }, completion: nil)
        let controller = ConfigurePostViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleRecordPress(_ gesture:UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            print("BEGAN")
            hudView.recordButton.initiateRecordingAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.recordVideo()
            })
            //closeButton.isHidden = true
            break
        case .changed:
            break
        default:
            stopRecordingVideo()
            break
        }
    }

    func recordVideo() {
        
        let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let filePath = documentsURL.appendingPathComponent("temp.mp4")
            captureView.videoFileOutput?.startRecording(to: filePath, recordingDelegate: recordingDelegate!)
            hudView.recordButton.startRecording()
        } catch {
            print("OH DAMN")
        }
        
    }
    func stopRecordingVideo() {
        captureView.videoFileOutput?.stopRecording()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("DID START RECORDING")
        return
    }
    
    var videoURL:URL?
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        videoURL = outputFileURL
        let item = AVPlayerItem(url: outputFileURL as URL)
        videoPlayer.replaceCurrentItem(with: item)
        playerLayer = AVPlayerLayer(player: videoPlayer)
        
        playerLayer!.frame = view.bounds
        previewView.layer.insertSublayer(playerLayer!, at: 0)
        
        playerLayer!.player?.play()
        playerLayer!.player?.actionAtItemEnd = .none
        
        captureView.isHidden = true
        hudView.recordButton.isHidden = true
        hudView.closeButton.isHidden = false
        hudView.nextButton.isHidden = false
        state = .videoCaptured
        
        loopVideo()
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
