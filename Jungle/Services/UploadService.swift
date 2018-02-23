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

class UploadService {
    
    static var pendingPostKey:String?
    
    fileprivate static func uploadPostImage(postID: String, image:UIImage, order:Int,  completion: @escaping (_ order:Int,_ url:URL?,_ color:String)->()) {
        
        DispatchQueue.global(qos: .background).async {
            let color = image.areaAverage().htmlRGBColor
            
            DispatchQueue.main.async {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let storageRef = Storage.storage().reference().child("userPosts/\(uid)/\(postID)/\(order).jpg")
                
                guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }
                
                let uploadMetadata = StorageMetadata()
                uploadMetadata.contentType = "image/jpg"
                
                storageRef.putData(imageData, metadata: uploadMetadata) { metaData, error in
                    completion(order, metaData?.downloadURL(), color)
                }
            }
        }
        
    }
    
    fileprivate static func uploadPostImages(postID:String, images:[SelectedImage], completion: @escaping (_ urls:[[String:Any]])->()) {
        var urlAttachments = [URLAttachment]()
        if images.count == 0 { return completion([]) }
        
        var uploadedCount = 0
        for i in 0..<images.count {
            uploadPostImage(postID: postID, image: images[i].image, order: i) { order, url, color in
                
                if let url = url {
                    let attachment = URLAttachment(url: url, order: order, source: images[order].type.rawValue, colorHex:color)
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
                            "color": attachment.colorHex
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
        for image in attachments.images {
            let imageRef = storage.child("userPosts/\(uid)/\(post.key)/\(image.order).jpg")
            imageRef.delete(completion: { error in
                if error != nil {
                    print("ERROR: \(error?.localizedDescription)")
                }
            })
        }
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
    
    
    static func uploadPost(text:String, images:[SelectedImage]) {
        
        
        userHTTPHeaders() { uid, headers in
            if let headers = headers, let uid = uid {
               
                var parameters: [String: Any] = [
                    "uid" : uid,
                    "text" : text
                ]
                
                getNewPostID(headers) { postID in
                    if let postID = postID {
                        pendingPostKey = postID
                        parameters["postID"] = postID
                        
                        UploadService.uploadPostImages(postID: postID, images: images) { urlAttachments in
                            if urlAttachments.count > 0 {
                                
                                parameters["attachments"] = [
                                    "images": urlAttachments
                                ]
                            }
                            UploadService.addNewPost(headers, withID: postID, parameters: parameters) { success in
                                if success {
                                    print ("BIG SUCCESS")
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
        var colorHex:String
        
        init(url:URL, order:Int, source:String, colorHex:String) {
            self.url = url
            self.order = order
            self.source = source
            self.colorHex = colorHex
        }
    }
}


