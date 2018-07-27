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
    
    static func getPost(_ postID:String, completion: @escaping (_ post:Post?)->()) {
        let postRef = firestore.collection("posts").document(postID)
        postRef.getDocument { snapshot, error in
            if let snapshot = snapshot,
                let data = snapshot.data(),
                let post = Post.parse(id: snapshot.documentID, data) {
                return completion(post)
            }
            return completion(nil)
        }
    }

    
    static func getTopComment(forPost post:Post, completion: @escaping ((_ comment:Post?)->())) {
        let ref = firestore.collection("posts")
            .whereField("status", isEqualTo: "active")
            .whereField("parent", isEqualTo: post.key)
        
        let queryRef = ref.limit(to: 1)
        queryRef.getDocuments { querySnapshot, err in
            var comment:Post?
            if let err = err {
                print("Error getting documents: \(err)")
            } else if let documents = querySnapshot?.documents,
                let first = documents.first,
                let post = Post.parse(id: first.documentID, first.data()) {
                comment = post
            }
            completion(comment)
        }
    }
    
    static func refreshNewPosts(existingKeys: [String:Bool], startAfter firstTimestamp: Double?, completion: @escaping (_ posts:[Post])->()) {
        var params = [
            "limit": 15,
            ] as [String:Any]
        if let offset = firstTimestamp {
            params["offset"] = offset
        }
        
        functions.httpsCallable("recentPostsRefresh").call(params) { result, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return completion([])
            } else if let data = result?.data as? [String:Any],
                let results = data["results"] as? [[String:Any]]{
                var posts = [Post]()
                for data in results {
                    if let post = Post.parse(data: data) {
                        posts.insert(post, at: 0)
                    }
                }
                print("Results: \(posts)")
                return completion(posts)
            }
            
        }
    }
    
    static func getNewPosts(existingKeys: [String:Bool], lastPostID: Double?, completion: @escaping (_ posts:[Post], _ endReached:Bool)->()) {
        
        var params = [
            "limit": 15,
        ] as [String:Any]
        if let offset = lastPostID {
            params["offset"] = offset
        }
        
        functions.httpsCallable("recentPosts").call(params) { result, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return completion([], false)
            } else if let data = result?.data as? [String:Any],
                let results = data["results"] as? [[String:Any]]{
                var posts = [Post]()
                for data in results {
                    if let post = Post.parse(data: data) {
                        posts.append(post)
                    }
                }
                print("Results: \(posts)")
                return completion(posts, posts.count == 0)
            }
            
        }
    }
    
    static func fetchAdditionalInfo(forPosts _posts:[Post], completion: @escaping((_ posts:[Post])->())) {
        var posts = _posts
        if posts.count > 0 {
            var count = 0
            for i in 0..<posts.count {
                let post = posts[i]
                PostsService.getAdditionalPostInfo(post) { post in
                    posts[i] = post
                    count += 1
                    if count >= posts.count {
                        completion(posts)
                    }
                }
            }
        } else {
            completion(posts)
        }
    }
    
    static func getAdditionalPostInfo(_ post: Post, completion: @escaping ((_ post:Post)->())) {
        var parentID:String = post.key
        if let parent = post.parent, parent != "", parent != post.key {
            parentID = parent
        }
        completion(post)
    }

    
    static func getPopularPosts(existingKeys: [String:Bool], offset: Int, completion: @escaping (_ posts:[Post], _ endReached:Bool)->()) {
        
        var params = [
            "length": 15,
            "offset": offset
            ] as [String:Any]
        
        print("RXC DID CALL")
        functions.httpsCallable("popularPosts").call(params) { result, error in
            print("RXC DID RETURN!")
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return completion([], false)
            } else if let data = result?.data as? [String:Any],
                let results = data["results"] as? [[String:Any]]{
                var posts = [Post]()
                for data in results {
                    if let post = Post.parse(data: data) {
                        posts.append(post)
                    }
                }
                print("Results: \(posts)")
                return completion(posts, posts.count == 0)
            }
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
        let replyRef = firestore.collection("posts").document(replyID).collection("votes").document(uid)
        
        replyRef.getDocument { snapshot, error in
            var vote = Vote.notvoted
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let dict = snapshot?.data(),
                let val = dict["val"] as? Bool {
                vote = val ? Vote.upvoted : Vote.downvoted
            }
            
            completion(replyID, vote)
        }
    }
    
    
    
    static func getSubReplies(replyID:String, myAnonKey:String, completion: @escaping (_ replyID:String, _ replies:[Post])->()) {
        let repliesRef = firestore.collection("posts")
            .whereField("status", isEqualTo: "active")
            .whereField("replyTo", isEqualTo: replyID)
    
        let postRepliesRef = repliesRef.order(by: "createdAt", descending: true).limit(to: 3)
        postRepliesRef.getDocuments { snapshot, error in
            var replies = [Post]()
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                let documents = snapshot.documents
                
                for document in documents {
                    let data = document.data()
                    if let reply = Post.parse(id: document.documentID, data) {
                        replies.insert(reply, at: 0)
                    }
                }
            }
            
            PostsService.fetchAdditionalInfo(forPosts: replies) { _posts in
                completion(replyID, _posts)
            }
        }
    }

    static func getReplies(post:Post, after:Double?, completion: @escaping (_ replies:[Post])->()) {
        var params = [
            "limit": 15,
            "postID": post.key
            ] as [String:Any]
        if let offset = after {
            params["offset"] = offset
        }
        
        functions.httpsCallable("postReplies").call(params) { result, error in
            print("RXC DID RETURN!")
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return completion([])
            } else if let data = result?.data as? [String:Any],
                let results = data["results"] as? [[String:Any]]{
                var posts = [Post]()
                for data in results {
                    if let post = Post.parse(data: data) {
                        posts.append(post)
                    }
                }
                print("Results: \(posts)")
                return completion(posts)
            }
        }
    }
    
    static func getSuggestedTags(forText text: String, completion: @escaping (_ tags:[String], _ trending:[String])->()) {
        UploadService.userHTTPHeaders { uid, headers in
            let parameters = [
                "text": text
            ] as [String:Any]
            
            
            Alamofire.request("\(API_ENDPOINT)/tags/suggested", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                DispatchQueue.main.async {
                    var tags = [String]()
                    
                    var trending = [String]()
                    if let dict = response.result.value as? [String:Any],
                    let results = dict["results"] as? [String:Any],
                    let _tags = results["suggested"] as? [String:Bool],
                    let _trending = results["trending"] as? [String] {
                        for (t,_) in _tags{
                            tags.append(t)
                        }
                        trending = _trending
                    } else {
                        print("Failed to get suggested tags")
                    }
                    
                    return completion(tags, trending)
                }
            }
        }
    }

}
