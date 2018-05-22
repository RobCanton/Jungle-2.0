//
//  SearchService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AlgoliaSearch
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
    
    static var myCoords:LatLng = LatLng(lat: 43.9050531135017, lng: -79.27830310499503)
    
    fileprivate static let client = Client(appID: "O8UGJJNEB6", apiKey: "0df072a9b2f30dfb8c0e312cb52200ff")
    fileprivate static let postsIndex = client.index(withName: "posts")
    
    static let facet_hastags = "hashtags"
    
    static let distancePairs:[UInt:UInt] = [
        0: 10000,
        1: 100000,
        2: 1000000,
        3: 10000000
    ]
    
    static func searchFor(text:String, limit:Int, offset:Int, completion: @escaping(_ posts:[Post], _ endReached:Bool)->()) {
        
        let query = Query()
        
        if text.isHashtag && !text.containsWhitespace {
            let searchText = String(text.dropFirst())
            query.facetFilters = ["hashtags:\(searchText)"]
            query.offset = UInt(offset)
            query.length = UInt(limit)
        } else {
            //query = Query(query: text)
            query.query = text
            query.offset = UInt(offset)
            query.length = UInt(limit)
        }
        
        postsIndex.search(query) { content, error in
            var documents = [[String:Any]]()
            if let hits = content?["hits"] as? [[String:Any]] {
                documents = hits
            }
            
            var posts = [Post]()
            var endReached = false
            
            if documents.count == 0 {
                endReached = true
            }
            
            for document in documents {
                if let postID = document["objectID"] as? String,
                    let post = Post.parse(id: postID, document) {
                    //if state.postKeys[post.key] == nil {
                    posts.append(post)
                    //}
                }
            }
            
            PostsService.fetchAdditionalInfo(forPosts: posts) { _posts in
                completion(_posts, endReached)
            }

        }
    }
    
    static func searchNearby(proximity:UInt, offset:Int, completion: @escaping(_ posts:[Post], _ endReached:Bool)->()) {
        let distance = distancePairs[proximity]!
        let query = Query()
        query.length = 15
        query.offset = UInt(offset)
        query.aroundLatLng = myCoords
        query.aroundRadius = Query.AroundRadius.explicit(distance)
        postsIndex.search(query) { content, error in
            var documents = [[String:Any]]()
            var posts = [Post]()
            if let hits = content?["hits"] as? [[String:Any]] {
                documents = hits
            }
            
            for document in documents {
                if let postID = document["objectID"] as? String,
                    let post = Post.parse(id: postID, document) {
                    posts.append(post)
                }
            }
            
            PostsService.fetchAdditionalInfo(forPosts: posts) { _posts in
                completion(_posts, documents.count == 0)
            }
        }
    }
    
    static func searchMyPosts(offset:Int, completion: @escaping(_ posts:[Post], _ endReached:Bool)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = Query()
        query.length = 15
        query.offset = UInt(offset)
        query.facetFilters = ["uid:\(uid)"]
        postsIndex.search(query) { content, error in
            var documents = [[String:Any]]()
            var posts = [Post]()
            if let hits = content?["hits"] as? [[String:Any]] {
                documents = hits
            }
            
            for document in documents {
                if let postID = document["objectID"] as? String,
                    let post = Post.parse(id: postID, document) {
                    posts.append(post)
                }
            }
            
            PostsService.fetchAdditionalInfo(forPosts: posts) { _posts in
                completion(_posts, documents.count == 0)
            }
        }
    }
    
    static func getTrendingHashtags() {
    }
}
