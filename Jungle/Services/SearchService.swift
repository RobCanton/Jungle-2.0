//
//  SearchService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AlgoliaSearch

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
    
    fileprivate static let client = Client(appID: "O8UGJJNEB6", apiKey: "0df072a9b2f30dfb8c0e312cb52200ff")
    fileprivate static let postsIndex = client.index(withName: "posts")
    
    static let facet_hastags = "hashtags"
    
    static func searchFor(text:String, offset:Int, completion: @escaping(_ documents:[[String:Any]])->()) {
        
        var query:Query!
        
        if text.isHashtag && !text.containsWhitespace {
            let searchText = String(text.dropFirst())
            query = Query()
            query.facetFilters = ["hashtags:\(searchText)"]
            query.offset = UInt(offset)
            query.length = 15
        } else {
            query = Query(query: text)
            query.offset = UInt(offset)
            query.length = 15
        }
        
        postsIndex.search(query) { content, error in
            var documents = [[String:Any]]()
            if let hits = content?["hits"] as? [[String:Any]] {
                documents = hits
            }
            print("DOCUMENTS:\(documents)")
            completion(documents)
        }
    }
}
