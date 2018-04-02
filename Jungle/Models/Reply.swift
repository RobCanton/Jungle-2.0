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
    var votes:Int
    var vote = Vote.notvoted
    var endReached = true
    var replyTo:String?
    var isYou = false
    
    init(key:String, anon:Anon, text:String, createdAt:Date, numReplies:Int, votes:Int, replies:[Reply], replyTo:String?=nil) {
        self.key = key
        self.anon = anon
        self.text = text
        self.createdAt = createdAt
        self.numReplies = numReplies
        self.replies = replies
        self.votes = votes
        self.replyTo = replyTo
    }
    
    static func parse(id:String,_ data:[String:Any], replyTo:String?=nil) -> Reply? {
        if let anon = Anon.parse(data),
            let text = data["text"] as? String,
            let createdAt = data["createdAt"] as? Double {
            let numReplies = data["numReplies"] as? Int ?? 0
            let votes = data["votes"] as? Int ?? 0
            var _subReplies = [Reply]()
            if let subReplies = data["replies"] as? [[String:Any]] {
                for subReplyData in subReplies {
                    if let subReplyID = subReplyData["id"] as? String,
                        let subReply = Reply.parse(id: subReplyID, subReplyData) {
                        _subReplies.append(subReply)
                    }
                }
            }
            
            let reply = Reply(key: id, anon: anon, text: text, createdAt: Date(timeIntervalSince1970: createdAt / 1000), numReplies: numReplies,votes:votes, replies: _subReplies, replyTo:replyTo)
            return reply
        }
        return nil
    }
    
    
    
    func fetchReplies( completion:@escaping ()->()) {
        let repliesRef = firestore.collection("replies").whereField("replyTo", isEqualTo: key).order(by: "createdAt", descending: true)
    
        var queryRef:Query!
        if replies.count > 0 {
            let lastReplyTimestamp = replies[0].createdAt.timeIntervalSince1970 * 1000
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
                    if let reply = Reply.parse(id: document.documentID, document.data()) {
                        _replies.insert(reply, at: 0)
                    }
                }
            }
            self.replies.insert(contentsOf: _replies, at: 0)
            self.endReached = self.replies.count >= self.numReplies
            completion()
        }
    }
}
