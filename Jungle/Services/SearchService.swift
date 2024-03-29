//
//  SearchService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

extension String {
    
    var containsWhitespace : Bool {
        return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
    
    func removeWhitespaces() -> String  {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isHashtag:Bool {
        if self.count > 0 {
            return self[self.index(self.startIndex, offsetBy: 0)] == "#"
        }
        return false
    }

}

class SearchService {
    
    static let distancePairs:[UInt:UInt] = [
        0: 10000,
        1: 100000,
        2: 1000000,
        3: 10000000
    ]
    static let trendingTagsNotification = NSNotification.Name.init("trendingHashtagsUpdated")
    
    static var trendingHashtags = [TrendingHashtag]() {
        didSet {
            NotificationCenter.default.post(name: trendingTagsNotification, object: nil)
        }
    }
    
    static func searchFor(text:String, type:SearchType, limit:Int, offset:Int, completion: @escaping(_ posts:[Post])->()) {
        
        let params = [
            "text": text,
            "length": 15,
            "offset": offset,
            "searchType": type.rawValue
            ] as [String:Any]
        
        functions.httpsCallable("searchPosts").call(params) { result, error in
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
                
                return completion(posts)
            }
        }
    }
    
    static func searchNearby(proximity:UInt, offset:Int, completion: @escaping(_ posts:[Post])->()) {
        if let location = LocationAPI.shared.getLastLocation() {
            let params = [
                "length": 15,
                "offset": offset,
                "distance": distancePairs[proximity]!,
                "lat": location.coordinate.latitude,
                "lng": location.coordinate.longitude
                ] as [String:Any]
            
            functions.httpsCallable("nearbyPosts").call(params) { result, error in
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
                    
                    return completion(posts)
                }
            }
        } else {
            DispatchQueue.main.async {
                return completion([])
            }
        }
    }
    
    static func myPosts(offset:Int, completion: @escaping(_ posts:[Post])->()) {
        
        let params = [
            "length": 15,
            "offset": offset,
            ] as [String:Any]
        
        functions.httpsCallable("myPosts").call(params) { result, error in
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
                
                return completion(posts)
            }
        }
    }
    
    static func myComments(offset:Int, completion: @escaping(_ posts:[Post])->()) {
        
        let params = [
            "length": 15,
            "offset": offset,
            ] as [String:Any]
        
        functions.httpsCallable("myComments").call(params) { result, error in
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
                
                return completion(posts)
            }
        }
    }
    
    static func likedPosts(offset:Int, completion: @escaping(_ posts:[Post])->()) {
        
        let params = [
            "length": 15,
            "offset": offset,
            ] as [String:Any]
        
        functions.httpsCallable("likedPosts").call(params) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return completion([])
            } else if let data = result?.data as? [String:Any],
                let results = data["results"] as? [[String:Any]] {
                
                var posts = [Post]()
                for data in results {
                    if let post = Post.parse(data: data) {
                        posts.insert(post, at: 0)
                    }
                }
                
                return completion(posts)
            }
        }
    }
    
    static func getTrendingHastags() {
        
        var trendingGroups = [String]()
        functions.httpsCallable("trendingTags").call { result, error in
            if let data = result?.data as? [String:[String:Any]] {
                var tags = [TrendingHashtag]()
                for (key, data) in data {
                    if let count = data["count"] as? Int,
                        let _posts = data["posts"] as? [[String:Any]] {
                        var posts = [Post]()
                        for postData in _posts {
                            if let post = Post.parse(data: postData) {
                                posts.append(post)
                                print("POST ADDED!")
                            } else {
                                print("NO POST")
                            }
                        }
                        
                        print("TRENDING DATA: \(data)")
                        if let first = posts.first,
                            let group = GroupsService.groupsDict[first.groupID] {
                            trendingGroups.append(group.id)
                        }
                        let tag = TrendingHashtag(hashtag: key, count: count, posts: posts)
                        tags.append(tag)
                        
                    }
                }
                
                tags.sort(by: { return $0 > $1 })
                GroupsService.trendingGroupKeys = trendingGroups
                trendingHashtags = tags
            }
        }
    }
    
    static func userPosts(username:String, offset:Int, completion: @escaping(_ posts:[Post])->()) {
        
        let params = [
            "username": username,
            "length": 15,
            "offset": offset,
            ] as [String:Any]
        
        functions.httpsCallable("userPosts").call(params) { result, error in
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
                
                return completion(posts)
            }
        }
    }
    
    static func userComments(username:String, offset:Int, completion: @escaping(_ posts:[Post])->()) {
        
        let params = [
            "username": username,
            "length": 15,
            "offset": offset,
            ] as [String:Any]
        
        functions.httpsCallable("userComments").call(params) { result, error in
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
                
                return completion(posts)
            }
        }
    }
    
    static func groupPosts(groupID:String, offset:Int, completion: @escaping(_ posts:[Post])->()) {
        
        let params = [
            "groupID": groupID,
            "limit": 15,
            "offset": offset,
            ] as [String:Any]
        
        print("SEARCHING GROUP POSTS: \(params)")
        
        functions.httpsCallable("recentGroupPosts").call(params) { result, error in
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
                
                return completion(posts)
            }
        }
    }
}
