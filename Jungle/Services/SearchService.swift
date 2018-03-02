//
//  SearchService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AlgoliaSearch

class SearchService {
    
    fileprivate static let client = Client(appID: "O8UGJJNEB6", apiKey: "0df072a9b2f30dfb8c0e312cb52200ff")
    fileprivate static let postsIndex = client.index(withName: "posts")
    
    static let facet_hastags = "hashtags"
    
    static func searchFor(text:String, offset:Int, completion: @escaping(_ documents:[[String:Any]])->()) {
        
        let query = Query()
        query.offset = UInt(offset)
        query.length = 15
        let searchText = text.replacingOccurrences(of: "#", with: "")
        query.facetFilters = ["hashtags:\(searchText)"]
        postsIndex.search(query) { content, error in
            var documents = [[String:Any]]()
            if let hits = content?["hits"] as? [[String:Any]] {
                documents = hits
            }
            completion(documents)
        }
    }
}
