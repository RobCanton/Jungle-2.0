//
//  UploadService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-18.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase
import MobileCoreServices
import Photos
import SwiftMessages
import AVFoundation
import Regift

class UploadService {
    
    static var pendingPostKey:String?
    
    static func requestPHImage(_ asset:PHAsset, size: CGSize, completion: @escaping (_ image:UIImage?)->()) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: size,
                                              contentMode: .aspectFill,
                                              options: options) { (image, _) in
                                                completion(image)
        }
    }
    
    static func requestPHImageData(_ asset:PHAsset, completion: @escaping (_ data:Data?)->()) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        PHImageManager.default().requestImageData(for: asset, options: options)  { imageData, UTI, _, _ in
            completion(imageData)
        }
    }
    
    fileprivate static func uploadPostAsset(postID: String, asset:SelectedImage, order:Int, completion: @escaping (_ order:Int,_ url:URL?,_ color:String)->()) {
        
        DispatchQueue.global(qos: .background).async {
        
            requestPHImage(asset.asset, size: UIScreen.main.bounds.size) { image in
                
                if let image = image {
                    let color = image.areaAverage().htmlRGBColor
                    
                    if asset.assetType == .gif {
                        requestPHImageData(asset.asset) { gifData in
                            guard let uid = Auth.auth().currentUser?.uid else { return }
                            guard let data = gifData else { return }
                            let storageRef = Storage.storage().reference().child("userPosts/\(uid)/\(postID)/\(order).gif")
                            
                            let uploadMetadata = StorageMetadata()
                            uploadMetadata.contentType = "image/gif"
                            DispatchQueue.main.async {
                                storageRef.putData(data, metadata: uploadMetadata) { metaData, error in
                                    storageRef.downloadURL { url, error in
                                        completion(order, url, color)
                                    }
                                }
                            }
                        }
                    } else {
                        guard let uid = Auth.auth().currentUser?.uid else { return }
                        let storageRef = Storage.storage().reference().child("userPosts/\(uid)/\(postID)/\(order).jpg")
                            
                        guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }
                            
                        let uploadMetadata = StorageMetadata()
                        uploadMetadata.contentType = "image/jpg"
                        DispatchQueue.main.async {
                            storageRef.putData(imageData, metadata: uploadMetadata) { metaData, error in
                                storageRef.downloadURL { url, error in
                                    completion(order, url, color)
                                }
                            }
                        }
                    }
                    
                } else {
                    completion(order, nil, "")
                }
            }
            
        }
        
    }
    
    fileprivate static func uploadPostImages(postID:String, images:[SelectedImage], completion: @escaping (_ urls:[[String:Any]])->()) {
        var urlAttachments = [URLAttachment]()
        if images.count == 0 { return completion([]) }
        
        var uploadedCount = 0
        for i in 0..<images.count {
            
            let selectedAsset = images[i]
            
            uploadPostAsset(postID: postID, asset: selectedAsset, order: i) { order, url, color in
                if let url = url {
                    let uploadedAsset = images[order]
                    let attachment = URLAttachment(url: url, order: order, source: uploadedAsset.sourceType.rawValue, type: uploadedAsset.assetType.rawValue, colorHex:color)
                    urlAttachments.append(attachment)
                }
                
                uploadedCount += 1
                if uploadedCount >= images.count {
                    urlAttachments.sort(by:  { return $0 < $1 })
                    
                    var urls = [[String:Any]]()
                    for attachment in urlAttachments {
                        urls.append([
                            "url": attachment.url.absoluteString,
                            "source": attachment.source,
                            "order": order,
                            "color": attachment.colorHex,
                            "type": attachment.type,
                            "dimensions": [
                                "width": images[order].dimensions.width,
                                "height": images[order].dimensions.height,
                                "ratio": images[order].dimensions.width / images[order].dimensions.height
                                ] as [String:Any]
                            ])
                    }
                    completion(urls)
                }
            }
        }
    }
    
    static func getNewPostID(completion: @escaping(_ postID:String?)->()) {
        functions.httpsCallable("requestNewPostID").call { result, error in
            guard let data = result?.data as? [String:Any], let postID = data["postID"] as? String else {
                return completion(nil)
            }
            return completion(postID)
        }
    }
    
    fileprivate static func addNewPost(withID id:String, parameters:[String:Any]) {
        NSLog("RSC: addNewPost - Start")
        functions.httpsCallable("addPost").call(parameters) { result, error in
            NSLog("RSC: addNewPost - End")
            if error == nil {
                
                Alerts.showSuccessAlert(withMessage: "Uploaded!")
            } else {
                Alerts.showFailureAlert(withMessage: "Failed to upload.")
            }
            
        }
    }
    
    static func deletePost(_ post:Post, completion: @escaping (_ success:Bool)->()) {
        let _ = Alerts.showInfoAlert(withMessage: "Deleting...")
        functions.httpsCallable("postRemove").call(["postID": post.key]) { result, error in
            if let error = error {
                print("Error: \(error)")
                Alerts.showFailureAlert(withMessage: "Failed to delete post.")
                return completion(false)
            }
            
            Alerts.showSuccessAlert(withMessage: "Deleted!")
            return completion(true)
        }
        
    }
    
    static func deletePostAttachments(post:Post, completion: @escaping (_ success:Bool)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return completion(false) }
        let attachments = post.attachments
        if let video = attachments.video {
            let videoRef = storage.child("userPosts/\(uid)/\(post.key)/video.mp4")
            videoRef.delete { error in
                if let _ = error {
                    return completion(false)
                }
                let thumbnailRef = storage.child("userPosts/\(uid)/\(post.key)/thumbnail.gif")
                thumbnailRef.delete { error in
                    if let _ = error {
                        return completion(false)
                    }
                    return completion(true)
                }
            }
        } else {
            return completion(true)
        }
    }
    
    
    static func uploadPost(postID:String, text:String, image:UIImage?, videoURL:URL?, gif:GIF?=nil, region:Region?=nil, location:CLLocation?=nil) {
        NSLog("RSC: uploadPost - Start")
        UserService.recentlyPosted = true
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var parameters: [String: Any] = [
            "postID": postID,
            "uid" : uid,
            "text" : text,
            "isAnonymous" : UserService.anonMode
        ]
        
        if let region = region, let location = location {
            parameters["location"] = [
                "lat": location.coordinate.latitude,
                "lng": location.coordinate.longitude,
                "region": [
                    "city": region.city,
                    "country": region.country,
                    "countryCode": region.countryCode
                ]
                
            ]
        }
        
        if let gif = gif {
            parameters["attachments"] = [
                "images": [
                    [
                        "url": gif.original_url.absoluteString,
                        "source": "GIF",
                        "order": 0,
                        "color": "0xFFFFFF",
                        "type": "GIF",
                        "dimensions": [
                            "width": gif.contentSize.width,
                            "height": gif.contentSize.height,
                            "ratio": gif.contentSize.width / gif.contentSize.height
                            ] as [String:Any]
                    ]
                ]
            ]
            
            UploadService.addNewPost(withID: postID, parameters: parameters)
        } else if let image = image {
            
            uploadImage(postID: postID, image: image) { success in
                if success {
                    parameters["attachments"] = [
                        "image": [
                            "size": [
                                "width": image.size.width,
                                "height": image.size.height,
                                "ratio": image.size.width / image.size.height
                            ]
                        ]
                    ]
                    UploadService.addNewPost(withID: postID, parameters: parameters)
                }
            }
            
        } else if let url = videoURL {
            let urlAsset = AVURLAsset(url: url, options: nil)
            let track =  urlAsset.tracks(withMediaType: AVMediaType.video)
            let videoTrack:AVAssetTrack = track[0] as AVAssetTrack
            let size = videoTrack.naturalSize
            NSLog("RSC: uploadVideo - Start")
            var videoLength:Float64?
            var videoUploaded = false
            var thumbnailUploaded = false
            
            uploadVideoStill(url: url, postID: postID) { success in
                if success {
                    UploadService.uploadVideo(pathName: "video.mp4", videoURL: url, postID: postID) { success, _vidLength in
                        NSLog("RSC: uploadVideo - End")
                        videoUploaded = success
                        videoLength = _vidLength
                        if videoUploaded, thumbnailUploaded, videoLength != nil {
                            parameters["attachments"] = [
                                "video": [
                                    "length": videoLength!,
                                    "size": [
                                        "width": size.width,
                                        "height": size.height,
                                        "ratio": size.width / size.height
                                    ]
                                ]
                            ]
                            
                            UploadService.addNewPost(withID: postID, parameters: parameters)
                            
                        }
                    }
                    
                    UploadService.createGif(videoURL: url, postID: postID) { success in
                        thumbnailUploaded = success
                        if thumbnailUploaded, videoUploaded, videoLength != nil {
                            parameters["attachments"] = [
                                "video": [
                                    "length": videoLength!,
                                    "size": [
                                        "width": size.width,
                                        "height": size.height,
                                        "ratio": size.width / size.height
                                    ]
                                ]
                            ]
                            
                            UploadService.addNewPost(withID: postID, parameters: parameters)
                        }
                    }
                }
            }
            
        } else {
            UploadService.addNewPost(withID: postID, parameters: parameters)
        }
    }
    
    static func uploadVideo(pathName:String, videoURL:URL, postID:String, completion: @escaping ((_ success:Bool, _ length:Float64?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return completion(false, nil) }
        
        let storageRef = Storage.storage().reference().child("userPosts/\(uid)/\(postID)/video.mp4")
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "video/mp4"
        
        let playerItem = AVAsset(url: videoURL)
        let length = CMTimeGetSeconds(playerItem.duration)
        guard let data = NSData(contentsOf: videoURL) else { return completion(false, nil) }
        storageRef.putData(data as Data, metadata: uploadMetadata) { metaData, error in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            completion(error == nil, length)
        }
    }
    
    static func uploadImage(postID:String, image:UIImage, completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        guard let data = UIImageJPEGRepresentation(image, 1.0) else { return completion(false) }

        let storageRef = Storage.storage().reference().child("userPosts/\(uid)/\(postID)/image.jpg")

        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpg"
        
        storageRef.putData(data, metadata: uploadMetadata) { metaData, error in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            
            guard let thumbnailData = UIImageJPEGRepresentation(image, 0.5) else { return completion(false) }
            
            let thumbnailRef = Storage.storage().reference().child("userPosts/\(uid)/\(postID)/thumbnail.jpg")
            
            thumbnailRef.putData(thumbnailData, metadata: uploadMetadata) { metaData, error in
                if let error = error {
                    print("ERROR: \(error.localizedDescription)")
                }
                completion(error == nil)
            }
        }
    }
    
    
    
    static func createGif(videoURL:URL, postID:String, completion:@escaping((_ success:Bool)->())) {
        NSLog("RSC: createGif - Start")
        guard let uid = Auth.auth().currentUser?.uid else { return completion(false) }
        let size = CGSize(width: 160, height: 160)
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentDirectory.appendingPathComponent("output-thumbnail.gif")
        
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        Regift.createGIFFromSource(videoURL, destinationFileURL: outputURL, startTime: 0.0, duration: 2.5, frameRate: 12, loopCount: 0, size: size) { result in
            guard let url = result else { return completion(false) }
            
            let storageRef = Storage.storage().reference().child("userPosts/\(uid)/\(postID)/thumbnail.gif")
            
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/gif"
            guard let data = NSData(contentsOf: url) else { return completion(false) }
            storageRef.putData(data as Data, metadata: uploadMetadata) { metaData, error in
                return completion(error == nil)
            }
        }
    }
    
    private static func uploadVideoStill(url:URL, postID:String, completion: @escaping(_ success:Bool)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return completion(false) }
        var image:UIImage?
        do {
            let asset = AVAsset(url: url)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            image = UIImage(cgImage: cgImage)
        } catch let error as NSError {
            print("Error generating thumbnail: \(error)")
            return completion(false)
        }
        guard let videoStill = image else { return completion(false) }
        guard let jpegData = UIImageJPEGRepresentation(videoStill, 0.5) else { return completion (false) }
        let storageRef = Storage.storage().reference().child("userPosts/\(uid)/\(postID)/thumbnail.jpg")
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpg"
        
        storageRef.putData(jpegData as Data, metadata: uploadMetadata) { metaData, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return completion(false)
            } else {
                return completion(true)
            }
            
        }
    }
    
    private class URLAttachment: NSObject, Comparable {
        static func <(lhs: URLAttachment, rhs: URLAttachment) -> Bool {
            return lhs.order < rhs.order
        }
        
        var url:URL
        var order:Int
        var source:String
        var type:String
        var colorHex:String
        
        init(url:URL, order:Int, source:String, type:String, colorHex:String) {
            self.url = url
            self.order = order
            self.source = source
            self.type = type
            self.colorHex = colorHex
        }
    }
    
    fileprivate static func videoFileExists(withKey key:String) -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_video-\(key).mp4")
        let exists = FileManager.default.fileExists(atPath: dataPath.path)
        return exists
    }
    
    fileprivate static func writeVideoToFile(withKey key:String, video:Data) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_video-\(key).mp4")
        
        try! video.write(to: dataPath, options: [.atomic])
        return dataPath
    }
    
    fileprivate static func readVideoFromFile(withKey key:String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_video-\(key).mp4")
        do {
            let _ = try Data(contentsOf: dataPath)
            
            return dataPath
        } catch {
            return nil
        }
    }
    
    fileprivate static func removeVideoFile(withKey key:String) -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_video-\(key).mp4")
        do {
            try FileManager.default.removeItem(at: dataPath)
            return true
        } catch {
            return false
        }
    }
    
    fileprivate static func downloadVideo(withKey key:String, completion: @escaping (_ data:Data?)->()) {
        let videoRef = storage.child("publicPosts/\(key)/video.mp4")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        videoRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
            return completion(data)
        }
    }
    
    static func retrieveVideo(withKey key:String, completion: @escaping (_ videoUrl:URL?, _ fromFile:Bool)->()) {
        if let data = readVideoFromFile(withKey: key) {
            completion(data, true)
        } else {
            downloadVideo(withKey: key) { data in
                if data != nil {
                    let url = writeVideoToFile(withKey: key, video: data!)
                    completion(url, false)
                }
                completion(nil, false)
            }
        }
    }
    
    
    fileprivate static func imageFileExists(withKey key:String) -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_image-\(key).jpg")
        let exists = FileManager.default.fileExists(atPath: dataPath.path)
        return exists
    }
    
    fileprivate static func writeImageToFile(withKey key:String, data:Data) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_image-\(key).jpg")
        try! data.write(to: dataPath, options: [.atomic])
    }
    
    fileprivate static func readImageFromFile(withKey key:String) -> Data? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_image-\(key).jpg")
        do {
            let data = try Data(contentsOf: dataPath)
            return data
        } catch {
            return nil
        }
    }
    
    fileprivate static func removeImageFile(withKey key:String) -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_image-\(key).jpg")
        do {
            try FileManager.default.removeItem(at: dataPath)
            return true
        } catch {
            return false
        }
    }
    
    
    fileprivate static func downloadImage(withKey key:String, completion: @escaping (_ data:Data?)->()) {
        let imageRef = storage.child("publicPosts/\(key)/image.jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
            return completion(data)
            
        }
    }

    static func retrieveImage(withKey key:String, completion: @escaping (_ image:UIImage?, _ fromFile:Bool)->()) {
        
        if let data = readImageFromFile(withKey: key),
            let image = UIImage(data: data) {
            
            completion(image, true)
        } else {
            downloadImage(withKey: key) { data in
                if data != nil {
                    writeImageToFile(withKey: key, data: data!)
                    return completion(UIImage(data: data!), false)
                }

                return completion(nil, false)
            }
        }
    }
    
}



