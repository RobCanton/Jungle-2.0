//
//  FilterCamView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-25.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import GLKit
import Photos

class FilterCamView:UIView {
    
    var effectName:String?
    var intensity:Float?
    var currentImage:CIImage?
    
    
    // MARK: Video Preview Objects
    private var videoPreviewView: GLKView?
    private var ciContext: CIContext?
    private var glContext: EAGLContext?
    private var videoPreviewViewBounds: CGRect?
    
    // MARK: Camera Input and Outputs Objects
    private var frontCameraDeviceInput: AVCaptureDeviceInput?
    private var backCameraDeviceInput: AVCaptureDeviceInput?
    private var audioDeviceInput: AVCaptureDeviceInput?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    
    // MARK: Session Objects
    private var captureSession: AVCaptureSession?
    private var videoWriter: VideoWriter?
    
    //MARK: helper recording
    private var cvPixelBuffer: CVPixelBuffer?
    private var isCapturing = false
    private(set) var isBackCameraActive = true
    private var orientation = UIInterfaceOrientation.portrait
    private var deviceZoomFactor: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.insetsLayoutMarginsFromSafeArea = false
        self.preservesSuperviewLayoutMargins = false
        self.backgroundColor = UIColor.black
        
    }
    
    
    
    var cameraPermissionButton:UIButton!
    var microphonePermissionButton:UIButton!
    
    func setup() {
        
        self.setupVideoPreviewView()
        self.setupCaptureSession()
    }
    
    @objc func handleCameraPermission() {
        print("ASDWE!")
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func destroy() {
        videoPreviewView?.removeFromSuperview()
        captureSession?.stopRunning()
        captureSession = nil
        videoDataOutput = nil
        videoWriter = nil
    }
    
    func setupVideoPreviewView() {
        glContext = EAGLContext(api: .openGLES2)
        if let eaglContext = glContext {
            videoPreviewView = GLKView(frame: self.bounds, context: eaglContext)
            ciContext = CIContext(eaglContext: eaglContext)
        }
        if let videoPreviewView = videoPreviewView {
            videoPreviewView.enableSetNeedsDisplay = false
            videoPreviewView.frame = self.bounds
            videoPreviewView.isUserInteractionEnabled = false
            
            self.addSubview(videoPreviewView)
            self.sendSubview(toBack: videoPreviewView)
        }
        
        resizePreviewView()
    }
    
    // MARK: Update
    func resizePreviewView() {
        guard let videoPreviewView =  videoPreviewView else {
            print("can't resize preview vide")
            return
        }
        
        videoPreviewView.frame = self.bounds
        videoPreviewView.bindDrawable()
        videoPreviewViewBounds = CGRect.zero
        videoPreviewViewBounds?.size.width = self.bounds.width * videoPreviewView.contentScaleFactor
        videoPreviewViewBounds?.size.height = self.bounds.height * videoPreviewView.contentScaleFactor
    }
    
    // MARK: Setup
    func setupCaptureSession() {
        // fetch camera device inputs
        guard let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Can't fetch front camera device")
            return
        }
        
        guard let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Can't fetch back camera device")
            return
        }
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            print("Can't getch audio device")
            return
        }
        
        do {
            frontCameraDeviceInput = try AVCaptureDeviceInput(device: frontCameraDevice)
            backCameraDeviceInput = try AVCaptureDeviceInput(device: backCameraDevice)
        } catch {
            print("Unable to obtain video device input")
            return
        }
        
        audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice)
        
        // create the capture session
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        
        // CoreImage wants BGRA pixel format
        let outputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        // create and configure video data output
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput?.videoSettings = outputSettings
        let videoSessionQueue = DispatchQueue(label: Constants.QueueLabels.VideoSessionQueue)
        videoDataOutput?.setSampleBufferDelegate(self, queue: videoSessionQueue)
        videoDataOutput?.alwaysDiscardsLateVideoFrames = true
        
        // create and configure audio data output
        let audioDataOutput = AVCaptureAudioDataOutput()
        let audioSessionQueue = DispatchQueue(label: Constants.QueueLabels.AudioSessionQueue)
        audioDataOutput.setSampleBufferDelegate(self, queue: audioSessionQueue)
        
        // begin configure capture session
        captureSession?.beginConfiguration()
        
        // connect the video device input and video data output
        captureSession?.addInput(backCameraDeviceInput!)
        captureSession?.addOutput(videoDataOutput!)
        if let audioDeviceInput = audioDeviceInput {
            captureSession?.addInput(audioDeviceInput)
            captureSession?.addOutput(audioDataOutput)
        }
        
        captureSession?.commitConfiguration()
        
        // then start everything
        captureSession?.startRunning()
    }
    
    
    // get video file path
    private func videoURL() -> URL {
        let documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let filePath = documentsURL.appendingPathComponent("captured/captureOutput.mov")
        return filePath
    }
    
    //MARK: private methods
    func startRecording() {
        if isCapturing == true {
            print("Can't start recording, already recording!")
            return
        }
        
        guard let videoDataOutput = videoDataOutput else {
            print("videoDataOutput is nil, can't create VideoWriter")
            return
        }
        
        guard let videoWidth = videoDataOutput.videoSettings["Width"] as? Int else  {
            print("Can't recognize video resolution, can't create VideoWriter")
            return
        }
        
        guard let videoHeight = videoDataOutput.videoSettings["Height"] as? Int else  {
            print("Can't recognize video resolution, can't create VideoWriter")
            return
        }
        
        let videoURL = self.videoURL()
        let fileManager = FileManager()
        
        do {
            try fileManager.removeItem(at: videoURL)
        } catch {
            
        }
        
        var size = CGSize(width: videoWidth, height: videoHeight)
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            size = CGSize(width: videoHeight, height: videoWidth)
        }
        
        //self.cameraSwitchButton?.isHidden = true
        //self.torchButton?.isHidden = true
        
        self.videoWriter = VideoWriter(fileUrl: videoURL, size: size)
        self.isCapturing = true
    }
    
    func stopRecording( completion: @escaping (_ url:URL?)->()) {
        if isCapturing == false {
            print("Can't stop recording")
            return completion(nil)
        }
        
        guard let videoWriter = videoWriter else {
            print("Video writer is nil")
            return completion(nil)
        }
        
        self.isCapturing = false
        self.videoWriter?.markAsFinished()
        //self.cameraSwitchButton?.isHidden = false
        if isBackCameraActive {
            //self.torchButton?.isHidden = false
        }
        
        videoWriter.finish {
            self.videoWriter = nil
            self.cvPixelBuffer = nil
            let videoFilePath = self.videoURL()
            return completion(videoFilePath)
        }
    }
    
    func capturePhoto(completion: @escaping((_ image:UIImage)->()))
    {
        AudioServicesPlayAlertSound(1108)
        DispatchQueue.main.async {
            if let yo =  self.snapshot(of: self.bounds) { 
                return completion(yo.image!)
            }
        }
    }
    
    // MARK: User Interface
    func switchCamera() {
        guard let captureSession = captureSession else {
            print("Can't switch camera, session is nil")
            return
        }
        
        guard let frontCameraDeviceInput = frontCameraDeviceInput else {
            print("Can't switch camera, frontCameraDeviceInput is nil")
            return
        }
        
        guard let backCameraDeviceInput = backCameraDeviceInput else {
            print("Can't switch camera, backCameraDeviceInput is nil")
            return
        }
        
        captureSession.beginConfiguration()
        //Change camera device inputs from back to front or opposite
        if captureSession.inputs.contains(frontCameraDeviceInput) == true {
            captureSession.removeInput(frontCameraDeviceInput)
            captureSession.addInput(backCameraDeviceInput)
            backCameraDeviceInput.device.videoZoomFactor = deviceZoomFactor
            isBackCameraActive = true
            //self.torchButton?.isHidden = false
        } else if captureSession.inputs.contains(backCameraDeviceInput) == true {
            captureSession.removeInput(backCameraDeviceInput)
            captureSession.addInput(frontCameraDeviceInput)
            frontCameraDeviceInput.device.videoZoomFactor = deviceZoomFactor
            isBackCameraActive = false
            //self.torchButton?.isHidden = true
        }
        
        //Commit all the configuration changes at once
        captureSession.commitConfiguration();
        
        // fix mirrored preview
        videoPreviewView?.transform = (videoPreviewView?.transform.scaledBy(x: -1, y: 1))!
        cvPixelBuffer = nil
    }
    
    @objc func toggleTorch() -> Bool {
        guard let backDevice = backCameraDeviceInput?.device else {
            print("Can't find back device")
            return false;
        }
        
        if backDevice.hasTorch == false || backDevice.isTorchAvailable == false {
            print("Can't turn on/off tourch")
            return false;
        }
        
        do {
            try backDevice.lockForConfiguration()
            backDevice.torchMode = backDevice.torchMode == .on ? .off : .on;
            backDevice.unlockForConfiguration()
        } catch {
            print("Something went wrong")
        }
        
        return backDevice.torchMode == .on
    }
    
    var pivotPinchScale:CGFloat = 0.0
    
    func handlePinchGesture(_ gesture:UIPinchGestureRecognizer) {
        guard let backDevice = backCameraDeviceInput?.device else {
            print("Can't find back device")
            return;
        }
        
        guard let frontDevice = frontCameraDeviceInput?.device else {
            print("Can't find front device")
            return;
        }
        
        let device = isBackCameraActive ? backDevice : frontDevice
        do {
            try device.lockForConfiguration()
            switch gesture.state {
            case .began:
                self.pivotPinchScale = device.videoZoomFactor
            case .changed:
                var factor = self.pivotPinchScale * gesture.scale
                factor = max(1, min(factor, device.activeFormat.videoMaxZoomFactor))
                device.videoZoomFactor = factor
            default:
                break
            }
            device.unlockForConfiguration()
        } catch {
            // handle exception
        }
    }
}

extension FilterCamView: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if CMSampleBufferDataIsReady(sampleBuffer) == false {
            print("Sample buffer is not ready")
            return
        }
        
        if output is AVCaptureVideoDataOutput {
            videoOutput(output, didOutput: sampleBuffer, from: connection)
        }
        
        if output is AVCaptureAudioDataOutput {
            audioOutput(output, didOutput: sampleBuffer, from: connection)
        }
    }

    
    private func videoOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Can't create pixel buffer")
            return
        }
        
        guard let videoPreviewViewBounds = videoPreviewViewBounds else {
            print("Unrecognized preview bounds")
            return
        }
        
        var sourceImage = CIImage(cvImageBuffer: pixelBuffer)
        // fix video orientation issue
        if isBackCameraActive == true && orientation == .landscapeLeft {
            sourceImage = sourceImage.oriented(forExifOrientation: 3)
        } else if isBackCameraActive == false && orientation == .landscapeRight {
            sourceImage = sourceImage.oriented(forExifOrientation: 3)
        } else if orientation == .portrait {
            sourceImage = sourceImage.oriented(forExifOrientation: 6)
        }
        let sourceExtent = sourceImage.extent
        
        currentImage = sourceImage
        // add filter to image
        var filteredImage:CIImage = sourceImage
        if let effect = effectName {
            filteredImage = sourceImage.applyEffect(effect, intensity) ?? sourceImage

        }
        
//        guard let filteredImage = sourceImage else {
//            print("Can't add filter ro image")
//            return
//        }
        
        let sourceAspect = sourceExtent.size.width / sourceExtent.size.height
        let previewAspect = videoPreviewViewBounds.size.width / videoPreviewViewBounds.size.height
        
        // we want to maintain the aspect radio of the screen size, so we clip the video image
        var drawRect = sourceExtent
        if sourceAspect > previewAspect {
            // use full height of the video image, and center crop the width
            drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0
            drawRect.size.width = drawRect.size.height * previewAspect
        } else {
            // use full width of the video image, and center crop the height
            drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0
            drawRect.size.height = drawRect.size.width / previewAspect
        }
         
        videoPreviewView?.bindDrawable()
        if glContext != EAGLContext.current() {
            EAGLContext.setCurrent(glContext)
        }
        
        // clear eagl view to grey
        glClearColor(0.0, 0.0, 0.0, 0.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        
        // set the blend mode to "source over" so that CI will use that
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA));
        
        ciContext?.draw(filteredImage, in: videoPreviewViewBounds, from: drawRect)
        if videoPreviewView != nil {
            videoPreviewView?.display()
        }
        //recording
        if isCapturing {
            // convert CIImage to CVPixelBuffer
            if cvPixelBuffer == nil {
                let attributesDictionary = [kCVPixelBufferIOSurfacePropertiesKey: [:]]
                CVPixelBufferCreate(kCFAllocatorDefault,
                                    Int(sourceImage.extent.size.width),
                                    Int(sourceImage.extent.size.height),
                                    kCVPixelFormatType_32BGRA,
                                    attributesDictionary as CFDictionary,
                                    &cvPixelBuffer);
            }
            ciContext?.render(filteredImage, to: cvPixelBuffer!)
            
            // convert new CVPixelBuffer to new CMSampleBuffer
            var sampleTime = CMSampleTimingInfo()
            sampleTime.duration = CMSampleBufferGetDuration(sampleBuffer)
            sampleTime.presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            sampleTime.decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
            
            var videoInfo: CMVideoFormatDescription? = nil
            CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, cvPixelBuffer!, &videoInfo)
            var newSampleBuffer: CMSampleBuffer?
            CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, cvPixelBuffer!, videoInfo!, &sampleTime, &newSampleBuffer)
            
            // writer new CMSampleBuffer to asser writer
            self.videoWriter?.write(sample: newSampleBuffer!, isVideoBuffer: true)
        }
    }
    
    private func audioOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //recording
        if isCapturing {
            self.videoWriter?.write(sample: sampleBuffer, isVideoBuffer: false)
        }
    }
    
    @objc func handlePinch(_ gesture:UIPinchGestureRecognizer) {
        print("PINCH: \(gesture.scale)")
    }
}

