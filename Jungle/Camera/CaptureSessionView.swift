//
//  CaptureSessionView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CaptureSessionView:UIView, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private(set) var isFrontCamera = false
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var videoFileOutput: AVCaptureMovieFileOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var filteredImage: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }
            else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        
        currentCamera = backCamera
    }
    
    func switchCamera() {
        guard let currentCamera = currentCamera,
            let captureDeviceInput = captureDeviceInput,
            let frontCamera = frontCamera,
            let backCamera = backCamera else { return }
        captureSession.beginConfiguration()
        //Remove existing input
        for input in captureSession.inputs {
            if input == captureDeviceInput {
                captureSession.removeInput(input)
                self.captureDeviceInput = nil
            }
        }
        if currentCamera == backCamera {
            self.currentCamera = self.frontCamera
        } else {
            self.currentCamera = self.backCamera
        }
        do {
            self.captureDeviceInput = try AVCaptureDeviceInput(device: self.currentCamera!)
            captureSession.addInput(self.captureDeviceInput!)
            captureSession.commitConfiguration()
            
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
        
    }
    
        var captureDeviceInput:AVCaptureDeviceInput?
    func setupInputOutput() {
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
        do {
            
            captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            
            captureSession.addInput(captureDeviceInput!)
            captureSession.addInput(audioDeviceInput)
            
            let videoOutput = AVCaptureVideoDataOutput()
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
            
//
//        photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
           //videoFileOutput = AVCaptureMovieFileOutput()
           // self.captureSession.addOutput(videoFileOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        cameraPreviewLayer?.frame = self.bounds
        self.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        filteredImage = UIImageView(frame: self.bounds)
        //filteredImage.alpha = 0.5
        addSubview(filteredImage)
        
    }
    
    func destroySession() {
        cameraPreviewLayer?.removeFromSuperlayer()
        captureSession.stopRunning()
    }
    
    let context = CIContext()
    
    func setupCorrectFramerate(currentCamera: AVCaptureDevice) {
        for vFormat in currentCamera.formats {
            //see available types
            //print("\(vFormat) \n")
            
            var ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
            let frameRates = ranges[0]
            
            do {
                //set to 240fps - available types are: 30, 60, 120 and 240 and custom
                // lower framerates cause major stuttering
                if frameRates.maxFrameRate == 240 {
                    try currentCamera.lockForConfiguration()
                    currentCamera.activeFormat = vFormat as AVCaptureDevice.Format
                    //for custom framerate set min max activeVideoFrameDuration to whatever you like, e.g. 1 and 180
                    currentCamera.activeVideoMinFrameDuration = frameRates.minFrameDuration
                    currentCamera.activeVideoMaxFrameDuration = frameRates.maxFrameDuration
                }
            }
            catch {
                print("Could not set active format")
                print(error)
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        
        let comicEffect = CIFilter(name: "CIPixellate")
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvImageBuffer: pixelBuffer!)
        
        comicEffect!.setValue(cameraImage, forKey: kCIInputImageKey)
        
        let cgImage = self.context.createCGImage(comicEffect!.outputImage!, from: cameraImage.extent)!
        
        DispatchQueue.main.async {
            let filteredImage = UIImage(cgImage: cgImage)
            self.filteredImage.image = filteredImage
        }
    }
}
