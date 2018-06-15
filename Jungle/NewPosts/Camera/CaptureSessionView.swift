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

class CaptureSessionView:UIView {
    
    private(set) var isFrontCamera = false
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var videoFileOutput: AVCaptureMovieFileOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
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
            
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            videoFileOutput = AVCaptureMovieFileOutput()
            self.captureSession.addOutput(videoFileOutput!)
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
        
    }
    
    func destroySession() {
        cameraPreviewLayer?.removeFromSuperlayer()
        captureSession.stopRunning()
    }
}
