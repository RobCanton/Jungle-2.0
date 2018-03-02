//
//  PostsService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-26.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import MobileCoreServices
import Photos
import SwiftMessages

class PostsService {
    
    static func refreshNearbyPosts(existingKeys: [String:Bool], startAfter firstTimestamp: Double?, completion: @escaping (_ posts:[Post])->()) {
        
    }

    static func refreshNewPosts(existingKeys: [String:Bool], startAfter firstTimestamp: Double?, completion: @escaping (_ posts:[Post])->()) {
        let postsRef = firestore.collection("posts").whereField("status", isEqualTo: "active").order(by: "createdAt", descending: false)
        
        
        var queryRef:Query!
        if let firstTimestamp = firstTimestamp {
            queryRef = postsRef.start(after: [firstTimestamp]).limit(to: 12)
        } else {
            queryRef = postsRef.limit(to: 12)
        }
        queryRef.getDocuments() { (querySnapshot, err) in
            var posts = [Post]()
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let post = Post.parse(id: document.documentID, data) {
                        if existingKeys[post.key] == nil {
                            posts.insert(post, at: 0)
                        }
                    }
                }
            }
            completion(posts)
        }
    }
    
    static func getNewPosts(existingKeys: [String:Bool], lastPostID: Double?, completion: @escaping (_ posts:[Post], _ endReached:Bool)->()) {
            let rootPostRef = firestore.collection("posts").whereField("status", isEqualTo: "active")
            var postsRef:Query!
            var queryRef:Query!

            postsRef = rootPostRef.order(by: "createdAt", descending: true)
            if let lastPostID = lastPostID {
                queryRef = postsRef.start(after: [lastPostID]).limit(to: 15)
            } else{
                queryRef = postsRef.limit(to: 15)
            }
        
            queryRef.getDocuments() { (querySnapshot, err) in
                var _posts = [Post]()
                var endReached = false
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([], false)
                } else {
                    
                    let documents = querySnapshot!.documents
                    
                    if documents.count == 0 {
                        endReached = true
                    }
                    
                    for document in documents {
                        let data = document.data()
                        if let post = Post.parse(id: document.documentID, data) {
                            if existingKeys[post.key] == nil {
                                _posts.append(post)
                            }
                        }
                    }
                }
                completion(_posts, endReached)
            }
    }
    
    static func getPopularPosts(existingKeys: [String:Bool], lastRank: Int?, completion: @escaping (_ posts:[Post], _ endReached:Bool)->()) {
        let rootPostRef = firestore.collection("posts").whereField("status", isEqualTo: "active")
        var postsRef:Query!
        var queryRef:Query!
        
        postsRef = rootPostRef.order(by: "rank", descending: false)
        if let lastRank = lastRank {
            queryRef = postsRef.start(after: [lastRank]).limit(to: 15)
        } else{
            queryRef = postsRef.limit(to: 15)
        }
        
        queryRef.getDocuments() { (querySnapshot, err) in
            var _posts = [Post]()
            var endReached = false
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion([], false)
            } else {
                
                let documents = querySnapshot!.documents
                
                if documents.count == 0 {
                    endReached = true
                }
                
                for document in documents {
                    let data = document.data()
                    if let post = Post.parse(id: document.documentID, data) {
                        if existingKeys[post.key] == nil {
                            _posts.append(post)
                        }
                    }
                }
            }
            completion(_posts, endReached)
        }
    }

    static func getNearbyPosts(existingKeys: [String:Bool], lastTimestamp: Double?, isRefresh:Bool, completion: @escaping (_ posts:[Post], _ endReached:Bool)->()) {
        guard let location = gpsService.getLastLocation() else { return }
        
        UploadService.userHTTPHeaders { uid, headers in
            var parameters = [
                "lat": location.coordinate.latitude,
                "lon": location.coordinate.longitude,
                "limit": 5,
                "radius": 1000,
                "isRefresh": isRefresh
                ] as [String:Any]
            
            if let lastTimeStamp = lastTimestamp {
                parameters["lastTimestamp"] = lastTimeStamp
            }
            
            
            
            print("PARAMETERS: \(parameters)")
            
            Alamofire.request("\(API_ENDPOINT)/posts/nearby", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                DispatchQueue.main.async {
                    var posts = [Post]()
                    
                    if let dict = response.result.value as? [String:Any],
                        let success = dict["success"] as? Bool, success {
                        print("GET NEARBY SUCCESS: \(dict )")
                        if let postsArray = dict["results"] as? [[String:Any]] {
                            
                            for postData in postsArray {
                                if let postID = postData["postID"] as? String,
                                    existingKeys[postID] == nil,
                                    let data = postData["data"] as? [String:Any],
                                    let post = Post.parse(id: postID, data) {
                                    posts.insert(post, at: 0)
                                }
                            }
                            
                            if posts.count == 0 {
                                return completion(posts, true)
                            }
                        }   
                    } else {
                        print("GET NEARBY FAILED")
                    }
                    
                    return completion(posts, false)
                }
            }
        }
    }
}
