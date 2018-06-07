//
//  UploadService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-18.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
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
    
    fileprivate static func getNewPostID(_ headers: HTTPHeaders, completion: @escaping(_ postID:String?)->()) {
        Alamofire.request("\(API_ENDPOINT)/posts/add", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            DispatchQueue.main.async {
                if let dict = response.result.value as? [String:Any], let success = dict["success"] as? Bool, success, let postID = dict["postID"] as? String {
                    completion(postID)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    fileprivate static func addNewPost(_ headers: HTTPHeaders, withID id:String, parameters:[String:Any], completion: @escaping(_ success:Bool)->()) {
        Alamofire.request("\(API_ENDPOINT)/posts/add", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                DispatchQueue.main.async {
                    if let dict = response.result.value as? [String:Any], let success = dict["success"] as? Bool, success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
    }
    
    static func deletePost(_ headers: HTTPHeaders, post:Post, completion: @escaping (_ success:Bool)->()) {
        let postRef = firestore.collection("posts").document(post.key)
        postRef.delete() { error in
            completion(error == nil)
        }
        
        deletePostAttachments(post: post)
    }
    
    static func deletePostAttachments(post:Post) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let attachments = post.attachments else { return }
//        for image in attachments.images {
//            
//            let imageRef = storage.child("userPosts/\(uid)/\(post.key)/\(image.order).\(image.type)")
//            imageRef.delete(completion: { error in
//                if error != nil {
//                    print("ERROR: \(error?.localizedDescription)")
//                }
//            })
//        }
    }
    
    static func userHTTPHeaders(completion: @escaping (_ uid:String?, _ headers: HTTPHeaders?)->()) {
        guard let user = Auth.auth().currentUser else { return completion(nil,nil) }
        user.getIDToken() { token, error in
            if token != nil && error == nil {
                let headers: HTTPHeaders = ["Authorization": "Bearer \(token!)", "Accept": "application/json", "Content-Type" :"application/json"]
                return completion(user.uid, headers)
            }
            return completion(nil,nil)
        }
    }
    
    
    static func uploadPost(text:String, image:SelectedImage?, videoURL:URL?, tags:[String], gif:GIF?=nil, includeLocation:Bool?=nil) {
        
        Alerts.showInfoAlert(withMessage: "Uploading...")
        
        userHTTPHeaders() { uid, headers in
            if let headers = headers, let uid = uid {
               
                var parameters: [String: Any] = [
                    "uid" : uid,
                    "text" : text,
                    "tags": tags
                ]
                
                if includeLocation != nil, includeLocation!, let location = gpsService.getLastLocation() {
                    parameters["location"] = [
                        "lat": SearchService.myCoords.lat,//location.coordinate.latitude,
                        "lon": SearchService.myCoords.lng//location.coordinate.longitude
                    ]
                }
                
                getNewPostID(headers) { postID in
                    if let postID = postID {
                        pendingPostKey = postID
                        parameters["postID"] = postID
                        
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
                            
                            UploadService.addNewPost(headers, withID: postID, parameters: parameters) { success in
                                if success {
                                    Alerts.showSuccessAlert(withMessage: "Uploaded!")
                                    
                                }
                            }
                        } else if let image = image {
                            UploadService.uploadPostImages(postID: postID, images: [image]) { urlAttachments in
                                if urlAttachments.count > 0 {
                                    
                                    parameters["attachments"] = [
                                        "images": urlAttachments
                                    ]
                                }
                                UploadService.addNewPost(headers, withID: postID, parameters: parameters) { success in
                                    if success {
                                        Alerts.showSuccessAlert(withMessage: "Uploaded!")
                                        
                                    }
                                }
                            }
                        } else if let url = videoURL {
                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let outputUrl = documentsURL.appendingPathComponent("output.mp4")
                            
                            do {
                                try FileManager.default.removeItem(at: outputUrl)
                            } catch {
                                print (error)
                            }
                            compressVideo(inputURL: url, outputURL: outputUrl) { size in
                                    UploadService.uploadVideo(pathName: "video.mp4", videoURL: outputUrl, postID: postID) { _vidURL, _vidLength in
                                        if let vidURL = _vidURL,
                                            let vidLength = _vidLength {
                                            UploadService.createGif(videoURL: vidURL, postID: postID) { _gifURL in
                                                if let gifURL = _gifURL {
                                                    print("WE GOT THE GIF URL: \(gifURL.absoluteString)")
                                                    parameters["attachments"] = [
                                                        "video": [
                                                            "url": vidURL.absoluteString,
                                                            "thumbnail_url": gifURL.absoluteString,
                                                            "length": "\(vidLength)",
                                                            "size": [
                                                                "width": size.width,
                                                                "height": size.height,
                                                                "ratio": size.width / size.height
                                                            ]
                                                        ]
                                                    ]
                                                    
                                                    UploadService.addNewPost(headers, withID: postID, parameters: parameters) { success in
                                                        if success {
                                                            Alerts.showSuccessAlert(withMessage: "Uploaded!")
                                                        
                                                        }
                                                    }
                                                } else {
                                                    print("WE AINT GOT THE GIF LIKE THAT")
                                                }
                                            }
                                        }
                                    }
                                
                                
                            }
                        } else {
                            UploadService.addNewPost(headers, withID: postID, parameters: parameters) { success in
                                if success {
                                    Alerts.showSuccessAlert(withMessage: "Uploaded!")
                                }
                            }
                        }
                    }
                    
                }
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
    
    static func videoFileExists(withKey key:String) -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_video-\(key).mp4")
        let exists = FileManager.default.fileExists(atPath: dataPath.path)
        return exists
    }
    
    static func writeVideoToFile(withKey key:String, video:Data) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_video-\(key).mp4")
        
        try! video.write(to: dataPath, options: [.atomic])
        return dataPath
    }
    
    static func readVideoFromFile(withKey key:String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_video-\(key).mp4")
        do {
            let _ = try Data(contentsOf: dataPath)
            
            return dataPath
        } catch let error as Error{
            //print("ERROR: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func downloadVideo(withKey key:String, url:URL, completion: @escaping (_ data:Data?)->()) {
        
        URLSession.shared.dataTask(with: url, completionHandler:
            { (data, response, error) in
                return completion(data)
                
        }).resume()
    }
    
    static func retrieveVideo(withKey key:String, url:URL, completion: @escaping (_ videoUrl:URL?, _ fromFile:Bool)->()) {
        if let data = readVideoFromFile(withKey: key) {
            completion(data, true)
        } else {
            downloadVideo(withKey: key, url: url) { data in
                if data != nil {
                    let url = writeVideoToFile(withKey: key, video: data!)
                    completion(url, false)
                }
                completion(nil, false)
            }
        }
    }
    
    static func uploadVideo(pathName:String, videoURL:URL, postID:String, completion: @escaping ((_ url:URL?, _ length:Float64?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return completion(nil, nil) }
        
        let storageRef = Storage.storage().reference().child("userPosts/\(uid)/\(postID)/\(pathName)")
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "video/mp4"
        
        let playerItem = AVAsset(url: videoURL)
        let length = CMTimeGetSeconds(playerItem.duration)
        guard let data = NSData(contentsOf: videoURL) else { return completion(nil, nil) }
        DispatchQueue.main.async {
            storageRef.putData(data as Data, metadata: uploadMetadata) { metaData, error in
                storageRef.downloadURL { url, error in
                    completion(url, length)
                }
            }
        }
    }
    
    static func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ size:CGSize)-> Void) {
        
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        let track =  urlAsset.tracks(withMediaType: AVMediaType.video)
        let videoTrack:AVAssetTrack = track[0] as AVAssetTrack
        let size = videoTrack.naturalSize
        if let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            exportSession.exportAsynchronously {
                handler(size)
            }
        }
    }
    
    static func createGif(videoURL:URL, postID:String, completion:@escaping((_ url:URL?)->())) {
        let frameCount = 16
        let delayTime  = Float(0.0)
        let loopCount  = 0    // 0 means loop forever
        let size = CGSize(width: 300, height: 300)
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentDirectory.appendingPathComponent("output-thumbnail.gif")
        
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        Regift.createGIFFromSource(videoURL, destinationFileURL: outputURL, startTime: 0.0, duration: 2.5, frameRate: 12, loopCount: 0, size: size) { result in
            guard let url = result else { return completion(nil) }
            
            guard let uid = Auth.auth().currentUser?.uid else { return completion(nil) }
            
            let storageRef = Storage.storage().reference().child("userPosts/\(uid)/\(postID)/thumbnail.gif")
            
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/gif"
            
            let playerItem = AVAsset(url: videoURL)
            let length = CMTimeGetSeconds(playerItem.duration)
            guard let data = NSData(contentsOf: url) else { return completion(nil) }
            DispatchQueue.main.async {
                storageRef.putData(data as Data, metadata: uploadMetadata) { metaData, error in
                    storageRef.downloadURL { url, error in
                        completion(url)
                    }
                }
            }
        }
    }
    
    static func cropVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil)
    {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let asset = AVAsset(url: sourceURL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        var outputURL = documentDirectory.appendingPathComponent("output-thumbnail.mp4")
        
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetLowQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
    }
    
}



