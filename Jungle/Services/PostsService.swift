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
import PromiseKit

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
                if _posts.count > 0 {
                    var count = 0
                    for post in _posts {
                        getMyAnon(forPostID: post.key) { postID, anonKey in
                            post.myAnonKey = anonKey
                            
                            count += 1
                            if count >= _posts.count {
                                completion(_posts, endReached)
                            }
                        }
                    }
                } else {
                    completion(_posts, endReached)
                }
            }
    }
    
    static func getPopularPosts(existingKeys: [String:Bool], lastRank: Int?, completion: @escaping (_ posts:[Post], _ endReached:Bool)->()) {
        let rootPostRef = firestore.collection("posts").whereField("status", isEqualTo: "active")
        var postsRef:Query!
        var queryRef:Query!
        
        postsRef = rootPostRef.order(by: "score", descending: true)
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
    
    static func getMyAnon(forPostID postID:String, completion: @escaping (_ postID:String, _ anonKey:String)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return completion(postID,"") }
        let postsRef = firestore.collection("posts")
        let lexiconRef = postsRef.document(postID).collection("lexicon").document(uid)
        
        lexiconRef.getDocument { snapshot, error in
            var myAnonKey:String = ""
            if let error = error {
                print("Error Getting Anon Key: \(error.localizedDescription)")
            } else if let dict = snapshot,
                let key = dict["key"] as? String {
                myAnonKey = key
            }
            
            completion(postID, myAnonKey)
        }
        
    }
    
    static func getReplyVote(replyID:String, completion: @escaping (_ replyID:String, _ vote: Vote)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return completion(replyID,.notvoted) }
        let replyRef = firestore.collection("replies").document(replyID).collection("votes").document(uid)
        print("REPLY VOTE REF: \(replyRef.debugDescription)")
        replyRef.getDocument { snapshot, error in
            var vote = Vote.notvoted
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let dict = snapshot?.data(),
                let val = dict["val"] as? Bool {
                vote = val ? Vote.upvoted : Vote.downvoted
                print("GOT ZE VOTE: \(val)")
            }
            
            
            completion(replyID, vote)
        }
        
    }
    
    static func getSubReplies(replyID:String, myAnonKey:String, completion: @escaping (_ replyID:String, _ replies:[Reply])->()) {
        let repliesRef = firestore.collection("replies")
        let postRepliesRef = repliesRef.whereField("replyTo", isEqualTo: replyID).order(by: "createdAt", descending: true).limit(to: 3)
        postRepliesRef.getDocuments { snapshot, error in
            var replies = [Reply]()
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                let documents = snapshot.documents
                
                for document in documents {
                    let data = document.data()
                    if let reply = Reply.parse(id: document.documentID, data, replyTo: replyID) {
                        replies.insert(reply, at: 0)
                    }
                }
            }
            
            if replies.count > 0 {
                var count = 0
                for reply in replies {
                    reply.isYou = reply.anon.key == myAnonKey
                    getReplyVote(replyID: reply.key) { _, vote in
                        reply.vote = vote
                        count += 1
                        print("JJR - count: \(count) | replies: \(replies.count)")
                        if count >= replies.count {
                            print("DO WE EVER GET HERE?")
                            completion(replyID, replies)
                        }
                    }
                }
            } else {
                completion(replyID, replies)
            }
        }
    }

    static func getReplies(postID:String, after:Double?, completion: @escaping (_ replies:[Reply])->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return completion([]) }
        let repliesRef = firestore.collection("replies")
        let postsRef = firestore.collection("posts")
        let lexiconRef = postsRef.document(postID).collection("lexicon").document(uid)
        
        lexiconRef.getDocument { snapshot, error in
            var myAnonKey:String = ""
            if let error = error {
                print("Error Getting Anon Key: \(error.localizedDescription)")
            } else if let dict = snapshot,
                let key = dict["key"] as? String {
                myAnonKey = key
            }
            
            let postRepliesRef = repliesRef.whereField("replyTo", isEqualTo: postID).order(by: "createdAt", descending: false)
            var postRepliesQuery:Query!
            if let after = after {
                postRepliesQuery = postRepliesRef.start(after: [after]).limit(to: 12)
            } else {
                postRepliesQuery = postRepliesRef.limit(to: 12)
            }
            
            postRepliesQuery.getDocuments { snapshot, error in
                var replies = [Reply]()
                
                if let err = error {
                    print("Error getting documents: \(err)")
                    return completion([])
                } else {
                    
                    let documents = snapshot!.documents
                    for document in documents {
                        let replyID = document.documentID
                        if let reply = Reply.parse(id: replyID, document.data()) {
                            print("ReplyID: \(replyID)")
                            replies.append(reply)
                        }
                        
                    }
                }
                if replies.count > 0 {
                    var count = 0
                    
                    for reply in replies {
                        var _vote:Vote?
                        var _subReplies:[Reply]?
                        reply.isYou = reply.anon.key == myAnonKey
                        
                        getReplyVote(replyID: reply.key) { _replyID, vote in
                            _vote = vote
                            
                            if _subReplies != nil && _vote != nil {
                                reply.replies = _subReplies!
                                reply.vote = _vote!
                                
                                count += 1
                                if count >= replies.count {
                                    return completion(replies)
                                }
                            }
                        }
                        getSubReplies(replyID: reply.key, myAnonKey: myAnonKey) { _replyID, subReplies in
                            
                            _subReplies = subReplies
                            
                            if _subReplies != nil && _vote != nil {
                                reply.replies = _subReplies!
                                reply.vote = _vote!
                                
                                count += 1
                                if count >= replies.count {
                                    return completion(replies)
                                }
                            }
                        }
                    }
                } else {
                    return completion([])
                }
            }
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
            
            Alamofire.request("\(API_ENDPOINT)/posts/nearby", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                DispatchQueue.main.async {
                    var posts = [Post]()
                    
                    if let dict = response.result.value as? [String:Any],
                        let success = dict["success"] as? Bool, success {
                        //print("GET NEARBY SUCCESS: \(dict )")
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
