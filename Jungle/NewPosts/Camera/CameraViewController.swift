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

enum CameraState {
    case running, videoCaptured
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    
    var captureView:CaptureSessionView!
    var hudView:UIView!
    var closeButton:UIButton!
    var nextButton:UIButton!
    
    var recordButton:RecordButton!
    
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
        
        pageView = UIScrollView(frame: view.bounds)
        pageView.contentSize = CGSize(width: view.bounds.width * 2, height: view.bounds.height)
        pageView.isPagingEnabled = true
        pageView.showsHorizontalScrollIndicator = false
        view.addSubview(pageView)
        
        hudView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        pageView.addSubview(hudView)
        
        let captionView = CaptionView(frame: CGRect(x: view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height))
        captionView.backButton.addTarget(self, action: #selector(handleCaptionBack), for: .touchUpInside)
        pageView.addSubview(captionView)
        
        closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named:"Remove2"), for: .normal)
        hudView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: hudView.leadingAnchor, constant: 0).isActive = true
        closeButton.topAnchor.constraint(equalTo: hudView.topAnchor, constant: 0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        closeButton.tintColor = UIColor.white
        
        nextButton = UIButton(type: .custom)
        nextButton.setTitle("Use", for: .normal)
        nextButton.backgroundColor = UIColor.white
        nextButton.titleLabel?.font = Fonts.semiBold(ofSize: 15)
        nextButton.setTitleColor(UIColor.gray, for: .normal)
        hudView.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.sizeToFit()
        
        nextButton.trailingAnchor.constraint(equalTo: hudView.trailingAnchor, constant: -24).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: hudView.bottomAnchor, constant: -24).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        nextButton.layer.cornerRadius = 36/2
        nextButton.clipsToBounds = true
        nextButton.isHidden = true
        nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        
        recordButton = RecordButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        hudView.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.centerXAnchor.constraint(equalTo: hudView.centerXAnchor).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: hudView.bottomAnchor, constant: -60).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleRecordPress))
        recordButton.isUserInteractionEnabled = true
        recordButton.addGestureRecognizer(longPress)
        
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
            recordButton.reset()
            recordButton.isHidden = false
            nextButton.isHidden = true
            captureView.isHidden = false
            state = .running
            break
        }
    }
    
    @objc func handleNext() {
        guard let url = videoURL else {return}
        addVideo?(url)
        self.dismiss(animated: true, completion: nil)
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
            recordButton.initiateRecordingAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.recordVideo()
            })
            closeButton.isHidden = true
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
            recordButton.startRecording()
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
        recordButton.isHidden = true
        closeButton.isHidden = false
        nextButton.isHidden = false
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
