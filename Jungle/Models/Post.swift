//
//  Post.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Firebase

enum Vote {
    case upvoted, downvoted, notvoted
}

class Post {
    private(set) var key:String
    private(set) var anon:Anon
    private(set) var text:String
    private(set) var textClean:String
    private(set) var createdAt:Date
    private(set) var attachments:Attachments?
    private(set) var location:LocationPair?
    private(set) var tags:[String]
    
    var votes:Int
    var numReplies:Int
    var replies:[Post]
    var parent:String?
    var replyTo:String?
    
    
    var vote = Vote.notvoted
    var isYou = false
    var myAnonKey = ""
    
    init(key:String, anon:Anon, text:String, textClean:String, createdAt:Date, attachments:Attachments?=nil, location:LocationPair?, tags:[String], votes:Int,
         numReplies:Int, replies:[Post], parent:String?, replyTo:String?) {
        
        self.key = key
        self.anon = anon
        self.text = text
        self.textClean = textClean
        self.createdAt = createdAt
        self.attachments = attachments
        self.location = location
        self.tags = tags
        self.votes = votes
        self.numReplies = numReplies
        self.replies = replies
        self.parent = parent
        self.replyTo = replyTo
    }
    
    static func parse(id:String, _ data:[String:Any]) -> Post? {
        var post:Post?
        if let anon = Anon.parse(data),
            let text = data["text"] as? String,
            let textClean = data["textClean"] as? String,
            let createdAt = data["createdAt"] as? Double,
            let votes = data["votes"] as? Int,
            let numReplies = data["numReplies"] as? Int,
            let tags = data["hashtags"] as? [String] {
            
            let attachments = Attachments.parse(data)
            let location = LocationPair.parse(data)
            
            var parent:String?
            var replyTo:String?
            
            let _parent = data["parent"] as? String
            let _replyTo = data["replyTo"] as? String
            
            if _parent != nil, _parent != "NONE" {
                parent = _parent
            }
            if _replyTo != nil, _replyTo != "NONE" {
                replyTo = _replyTo
            }
            
            post = Post(key: id, anon: anon, text: text, textClean: textClean, createdAt: Date(timeIntervalSince1970: createdAt / 1000), attachments: attachments, location:location, tags: tags, votes: votes, numReplies: numReplies, replies:[], parent: parent, replyTo: replyTo )
        }
        return post
    }
    
    func fetchReplies( completion:@escaping ()->()) {
        let repliesRef = firestore.collection("posts")
            .whereField("status", isEqualTo: "active")
            .whereField("replyTo", isEqualTo: key)
            .order(by: "createdAt", descending: true)
        
        var queryRef:Query!
        if replies.count > 0 {
            let lastReplyTimestamp = replies[0].createdAt.timeIntervalSince1970 * 1000
            queryRef = repliesRef.start(after: [lastReplyTimestamp]).limit(to: 5)
        } else{
            queryRef = repliesRef.limit(to: 5)
        }
        
        queryRef.getDocuments() { (querySnapshot, err) in
            var _replies = [Post]()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let documents = querySnapshot!.documents
                
                for document in documents {
                    if let reply = Post.parse(id: document.documentID, document.data()) {
                        _replies.insert(reply, at: 0)
                    }
                }
            }
            self.replies.insert(contentsOf: _replies, at: 0)
            //self.endReached = self.replies.count >= self.numReplies
            completion()
        }
    }
}

class Attachments {
    var images:[ImageAttachment]
    
    init(images:[ImageAttachment]) {
        self.images = images
    }
    
    static func parse(_ data:[String:Any]) -> Attachments? {
        if let attachments = data["attachments"] as? [String:Any],
            let imagesArray = attachments["images"] as? [[String:Any]] {
            let images = ImageAttachment.parse(imagesArray)
            return Attachments(images: images)
        } else {
            return nil
        }
    }
}

class LocationPair {
    var city:String
    var country:String
    
    init(city:String, country:String) {
        self.city = city
        self.country = country
    }
    
    static func parse(_ data:[String:Any]) -> LocationPair? {
        if let location = data["location"] as? [String:Any],
            let city = location["city"] as? String,
            let country = location["countryCode"] as? String {
            return LocationPair(city: city, country: country)
        } else {
            return nil
        }
    }
    
    var locationStr:String {
        get {
            return "\(city), \(country)"
        }
    }
}

class ImageAttachment {
    var url:URL
    var order:Int
    var source:String
    var type:String
    var colorHex:String
    
    init(url:URL, order:Int, source:String, type:String, colorHex:String) {
        self.url = url
        self.order = order
        self.source = source
        self.type = type
        self.colorHex = colorHex
    }
    
    static func parse(_ dict:[String:Any]) -> ImageAttachment? {
        if let urlStr = dict["url"] as? String,
            let url = URL(string: urlStr),
            let order = dict["order"] as? Int,
            let source = dict["source"] as? String,
            let type = dict["type"] as? String,
            let color = dict["color"] as? String {
                return ImageAttachment(url: url, order: order, source: source, type: type, colorHex: color)
        }
        return nil
    }
    
    static func parse( _ dictArray:[[String:Any]]) -> [ImageAttachment] {
        var attachments = [ImageAttachment]()
        for dict in dictArray {
            if let imageAttachment = parse(dict) {
                attachments.append(imageAttachment)
            }
        }
        return attachments
    }
}
