//
//  ImageTransitionManager.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-27.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class LightboxViewerTransitionManager: NSObject, UIViewControllerTransitioningDelegate  {
    
    weak var sourceDelegate:LightboxTransitionSourceDelegate?
    weak var destinationDelegate:LightboxTransitionDestinationDelegate?
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let sourceDelegate = self.sourceDelegate, let destinationDelegate = self.destinationDelegate else { return nil }
        return LightboxPresentAnimationController(sourceDelegate, destinationDelegate)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let sourceDelegate = self.sourceDelegate, let destinationDelegate = self.destinationDelegate else { return nil }
        
        return LightboxDismissAnimationController(sourceDelegate, destinationDelegate)
    }
    
}

/**
 Creates a screenshot image of a from a video asset at given time
 - Parameter video: The video item
 - Parameter at:    The time in the video to screenshot
 - Returns: The a screenshot of the video as a UIImage or nil
 */
func videoScreenshot(_ video: AVPlayerItem?, at cmTime: CMTime)  -> (UIImage)?
{
    guard let asset = video?.asset else { return nil }
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    var timePicture = kCMTimeZero
    imageGenerator.appliesPreferredTrackTransform = true
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero
    var image:UIImage? = nil
    do {
        let ref = try imageGenerator.copyCGImage(at: cmTime, actualTime: &timePicture)
        
        image = UIImage(cgImage: ref)
    }catch { }
    return image
}


