//
//  Reply.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-17.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Reply {
    var key:String
    var anon:Anon
    var text:String
    var createdAt:Date
    var numReplies:Int
    var replies:[Reply] {
        didSet {
            print("DID SET THESE REPLIES: \(replies)")
        }
    }
    var endReached = true
    
    init(key:String, anon:Anon, text:String, createdAt:Date, numReplies:Int) {
        self.key = key
        self.anon = anon
        self.text = text
        self.createdAt = createdAt
        self.numReplies = numReplies
        self.replies = []
    }
    
    static func parse(id:String,_ data:[String:Any]) -> Reply? {
        if let anon = Anon.parse(data),
            let text = data["text"] as? String,
            let createdAt = data["createdAt"] as? Double {
            let numReplies = data["numReplies"] as? Int ?? 0
            let reply = Reply(key: id, anon: anon, text: text, createdAt: Date(timeIntervalSince1970: createdAt / 1000), numReplies: numReplies)
            return reply
        }
        return nil
    }
    
    func fetchReplies(_ postKey:String, completion:@escaping ()->()) {
        let repliesRef = firestore.collection("posts").document(postKey)
            .collection("comments").document(key).collection("replies")
            .order(by: "createdAt", descending: false)
    
        var queryRef:Query!
        if replies.count > 0 {
            let lastReplyTimestamp = replies[replies.count-1].createdAt.timeIntervalSince1970 * 1000
            queryRef = repliesRef.start(after: [lastReplyTimestamp]).limit(to: 5)
        } else{
            queryRef = repliesRef.limit(to: 5)
        }
        
        queryRef.getDocuments() { (querySnapshot, err) in
            var _replies = [Reply]()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let documents = querySnapshot!.documents
                
                for document in documents {
                    let data = document.data()
                    if let anon = Anon.parse(data),
                        let text = data["text"] as? String,
                        let createdAt = data["createdAt"] as? Double {
                        let numReplies = data["numReplies"] as? Int ?? 0
                        let reply = Reply(key: document.documentID, anon: anon, text: text, createdAt: Date(timeIntervalSince1970: createdAt / 1000), numReplies: numReplies)
                        _replies.append(reply)
                    }
                }
            }
            self.replies = _replies
            self.endReached = self.replies.count >= self.numReplies
            completion()
        }

    }
}
