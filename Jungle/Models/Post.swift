//
//  Post.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

enum Vote {
    case upvoted, downvoted, notvoted
}

class Post {
    private(set) var key:String
    private(set) var anon:Anon
    private(set) var text:String
    private(set) var createdAt:Date
    var votes:Int
    var replies:Int
    private(set) var attachments:Attachments?
    
    var vote = Vote.notvoted
    var isYou = false
    
    init(key:String, anon:Anon, text:String, createdAt:Date, votes:Int, replies:Int, attachments:Attachments?=nil) {
        self.key = key
        self.anon = anon
        self.text = text
        self.createdAt = createdAt
        self.votes = votes
        self.replies = replies
        self.attachments = attachments
    }
    
    static func parse(id:String, _ data:[String:Any]) -> Post? {
        var post:Post?
        if let anon = Anon.parse(data),
            let text = data["text"] as? String,
            let createdAt = data["createdAt"] as? Double,
            let votes = data["votes"] as? Int,
            let replies = data["replies"] as? Int {
            
            let attachments = Attachments.parse(data)
            
            post = Post(key: id, anon: anon, text: text, createdAt: Date(timeIntervalSince1970: createdAt / 1000), votes: votes, replies: replies, attachments: attachments)
        }
        return post
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

class ImageAttachment {
    var url:URL
    var order:Int
    var source:String
    var colorHex:String
    
    init(url:URL, order:Int, source:String, colorHex:String) {
        self.url = url
        self.order = order
        self.source = source
        self.colorHex = colorHex
    }
    
    static func parse(_ dict:[String:Any]) -> ImageAttachment? {
        if let urlStr = dict["url"] as? String,
            let url = URL(string: urlStr),
            let order = dict["order"] as? Int,
            let source = dict["source"] as? String,
            let color = dict["color"] as? String {
            return ImageAttachment(url: url, order: order, source: source, colorHex: color)
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
