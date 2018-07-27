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
    
    static func searchFor(text:String, limit:Int, offset:Int, completion: @escaping(_ posts:[Post], _ endReached:Bool)->()) {
        
        let params = [
            "text": text,
            "length": 15,
            "offset": offset,
            ] as [String:Any]
        print("QUERY PARAMS: \(params)")
        functions.httpsCallable("searchPosts").call(params) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return completion([], true)
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
    
    static func searchNearby(proximity:UInt, offset:Int, completion: @escaping(_ posts:[Post], _ endReached:Bool)->()) {
        if let location = gpsService.getLastLocation() {
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
                    return completion([], true)
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
        } else {
            DispatchQueue.main.async {
                return completion([], true)
            }
        }
    }
    
    static func myPosts(offset:Int, completion: @escaping(_ posts:[Post], _ endReached:Bool)->()) {
        
        let params = [
            "length": 15,
            "offset": offset,
            ] as [String:Any]
        
        functions.httpsCallable("myPosts").call(params) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return completion([], true)
            } else if let data = result?.data as? [String:Any],
                let results = data["results"] as? [[String:Any]]{
                
                var posts = [Post]()
                for data in results {
                    if let post = Post.parse(data: data) {
                        posts.append(post)
                    }
                }
                
                return completion(posts, posts.count == 0)
            }
        }
    }
    
    static func myComments(offset:Int, completion: @escaping(_ posts:[Post], _ endReached:Bool)->()) {
        
        let params = [
            "length": 15,
            "offset": offset,
            ] as [String:Any]
        
        functions.httpsCallable("myComments").call(params) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return completion([], true)
            } else if let data = result?.data as? [String:Any],
                let results = data["results"] as? [[String:Any]]{
                
                var posts = [Post]()
                for data in results {
                    if let post = Post.parse(data: data) {
                        posts.append(post)
                    }
                }
                
                return completion(posts, posts.count == 0)
            }
        }
    }
    
    static func likedPosts(offset:Int, completion: @escaping(_ posts:[Post], _ endReached:Bool)->()) {
        
        let params = [
            "length": 15,
            "offset": offset,
            ] as [String:Any]
        
        functions.httpsCallable("likedPosts").call(params) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return completion([], true)
            } else if let data = result?.data as? [String:Any],
                let results = data["results"] as? [[String:Any]] {
                
                var posts = [Post]()
                for data in results {
                    if let post = Post.parse(data: data) {
                        posts.insert(post, at: 0)
                    }
                }
                
                return completion(posts, posts.count == 0)
            }
        }
    }
    
    static func getTrendingHastags() {
        let trendingRef = database.child("trending/hashtags").queryOrdered(byChild: "count")
        trendingRef.observe(.value, with: { snapshot in
            guard let dictArray = snapshot.value as? [String:[String:Any]] else { return }
            var tags = [TrendingHashtag]()
            for (key, data) in dictArray {
                if let count = data["count"] as? Int,
                let post = data["post"] as? [String:Any],
                    let id = post["id"] as? String,
                    let createdAt = post["createdAt"] as? Double {
                    let date = Date(timeIntervalSince1970: createdAt / 1000)
                    let reports = Reports(inappropriate: 0, spam: 0)
                    if let _reports = post["reports"] as? [String:Int] {
                        reports.inappropriate = _reports["inappropriate"] ?? 0
                        reports.spam = _reports["spam"] ?? 0
                    }
                    let tag = TrendingHashtag(hastag: key, count: count, postID: id, lastPostedAt: date, report: reports)
                    tags.append(tag)
                }
            }
            
            trendingHashtags = tags
        })
    }
    
    
}
