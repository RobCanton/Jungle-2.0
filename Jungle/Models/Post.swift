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
    var comments:Int
    var rank:Int?
    private(set) var attachments:Attachments?
    private(set) var location:LocationPair?
    
    var vote = Vote.notvoted
    var isYou = false
    var myAnonKey = ""
    
    init(key:String, anon:Anon, text:String, createdAt:Date, votes:Int, comments:Int,rank:Int?, attachments:Attachments?=nil, location:LocationPair?) {
        self.key = key
        self.anon = anon
        self.text = text
        self.createdAt = createdAt
        self.votes = votes
        self.comments = comments
        self.rank = rank
        self.attachments = attachments
        self.location = location
    }
    
    static func parse(id:String, _ data:[String:Any]) -> Post? {
        var post:Post?
        if let anon = Anon.parse(data),
            let text = data["text"] as? String,
            let createdAt = data["createdAt"] as? Double,
            let votes = data["votes"] as? Int,
            let comments = data["numComments"] as? Int {
            
            let rank = data["rank"] as? Int
            let attachments = Attachments.parse(data)
            let location = LocationPair.parse(data)
            
            post = Post(key: id, anon: anon, text: text, createdAt: Date(timeIntervalSince1970: createdAt / 1000), votes: votes, comments: comments, rank: rank, attachments: attachments, location:location)
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
