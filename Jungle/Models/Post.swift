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
    private var _text:String
    private var _textClean:String
    var text:String {
        return UserService.currentUserSettings.safeContentMode ? _textClean : _text
    }
    private(set) var createdAt:Date
    private(set) var attachments:Attachments
    private(set) var location:Region?
    private(set) var tags:[String]
    private(set) var score:Double
    var votes:Int
    var numLikes:Int
    var numReplies:Int
    var reports:Reports
    var replies:[Post]
    var parent:String?
    var parentPost:Post?
    var replyTo:String?
    var gradient:[String]
    var documentSnapshot:DocumentSnapshot?
    
    var liked = false
    var likedAt:Double?
    
    var topComment:Post?
    var vote = Vote.notvoted
    var isYou = false
    
    var offenses:[String]
    var offensesStr:String {
        var str = ""
        for i in 0..<offenses.count {
            if i < 3 {
                if i == 0 {
                    str += "\(offenses[i])"
                } else {
                    str += ", \(offenses[i])"
                }
            }
        }
        return str
    }
    var isOffensive:Bool {
        return offenses.count > 0 && !isYou
    }
    
    var blockedMessage:String? {
        if !UserService.currentUserSettings.safeContentMode { return nil }
        if isOffensive {
            return "[Contains muted words]"
        }
        if reports.inappropriate > 0 {
            return "[May contain inappropriate content]"
        }
        return nil
    }
    
    init(key:String, anon:Anon, text:String, textClean:String, createdAt:Date, attachments:Attachments, location:Region?, tags:[String], score:Double, votes:Int, numLikes:Int,
         numReplies:Int, replies:[Post], reports:Reports,parent:String?, replyTo:String?, gradient:[String]) {
        
        self.key = key
        self.anon = anon
        self._text = text
        self._textClean = textClean
        self.createdAt = createdAt
        self.attachments = attachments
        self.location = location
        self.tags = tags
        self.score = score
        self.votes = votes
        self.numLikes = numLikes
        self.numReplies = numReplies
        self.replies = replies
        self.reports = reports
        self.parent = parent
        self.replyTo = replyTo
        self.offenses = ContentSettings.checkContent(ofText: text)
        self.gradient = gradient
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
            let location = Region.parse(data)
            let numLikes = data["numLikes"] as? Int ?? 0
            let score = data["score"] as? Double ?? 0.0
            
            var inappropriateReports = 0
            var spamReports = 0
            if let reportsData = data["reports"] as? [String:Any] {
                inappropriateReports = reportsData["inappropriate"] as? Int ?? 0
                spamReports = reportsData["spam"] as? Int ?? 0
            }
            
            let reports = Reports(inappropriate: inappropriateReports, spam: spamReports)
            
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
            
            let gradient = data["gradient"] as? [String] ?? [String]()
            
            post = Post(key: id, anon: anon, text: text, textClean: textClean, createdAt: Date(timeIntervalSince1970: createdAt / 1000), attachments: attachments, location:location, tags: tags, score:score, votes: votes,numLikes: numLikes, numReplies: numReplies, replies:[], reports: reports, parent: parent, replyTo: replyTo, gradient: gradient )
            post?.isYou = data["isYou"] as? Bool ?? false
            
            if let parentData = data["parentPost"] as? [String:Any] {
                post?.parentPost = Post.parse(data: parentData)
                print("SET PARENT POST!")
            }
            post?.likedAt = data["likedAt"] as? Double
        }
        return post
    }
    
    static func parse(data:[String:Any]) -> Post? {
        var post:Post?
        if let id = data["id"] as? String,
            let anon = Anon.parse(data),
            let text = data["text"] as? String,
            let textClean = data["textClean"] as? String,
            let createdAt = data["createdAt"] as? Double,
            let votes = data["votes"] as? Int,
            let numReplies = data["numReplies"] as? Int,
            let tags = data["hashtags"] as? [String] {
            
            let attachments = Attachments.parse(data)
            let location = Region.parse(data)
            let numLikes = data["numLikes"] as? Int ?? 0
            let score = data["score"] as? Double ?? 0.0
            
            var inappropriateReports = 0
            var spamReports = 0
            if let reportsData = data["reports"] as? [String:Any] {
                inappropriateReports = reportsData["inappropriate"] as? Int ?? 0
                spamReports = reportsData["spam"] as? Int ?? 0
            }
            
            let reports = Reports(inappropriate: inappropriateReports, spam: spamReports)
            
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
            
            let gradient = data["gradient"] as? [String] ?? [String]()
            
            post = Post(key: id, anon: anon, text: text, textClean: textClean, createdAt: Date(timeIntervalSince1970: createdAt / 1000), attachments: attachments, location:location, tags: tags, score:score, votes: votes,numLikes: numLikes, numReplies: numReplies, replies:[], reports: reports, parent: parent, replyTo: replyTo, gradient: gradient)
            post?.isYou = data["isYou"] as? Bool ?? false
            
            if let parentData = data["parentPost"] as? [String:Any] {
                post?.parentPost = Post.parse(data: parentData)
                print("SET PARENT POST!")
            }
            post?.likedAt = data["likedAt"] as? Double
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
    
    var image:ImageAttachment?
    var video:VideoAttachment?
    init(image:ImageAttachment?, video:VideoAttachment?) {
        self.image = image
        self.video = video
    }
    
    static func parse(_ data:[String:Any]) -> Attachments {
        var image:ImageAttachment?
        var video:VideoAttachment?
        if let attachments = data["attachments"] as? [String:Any] {
            
            
            if let imageData = attachments["image"] as? [String:Any] {
                image = ImageAttachment.parse(imageData)
            }
            
            if let videoData = attachments["video"] as? [String:Any] {
                print("WE GOT VIDEO DATA: \(videoData)")
                video = VideoAttachment.parse(videoData)
            }
        }
        
        return Attachments(image: image, video: video)
    }
    
    var isVideo:Bool {
        return video != nil
    }
    
    var isImage:Bool {
        return image != nil
    }
}



class Region {
    var city:String
    var country:String
    var countryCode:String
    
    init(city:String, country:String, countryCode:String) {
        self.city = city
        self.country = country
        self.countryCode = countryCode
    }
    
    static func parse(_ data:[String:Any]) -> Region? {
        if let location = data["location"] as? [String:Any],
            let city = location["city"] as? String,
            let country = location["country"] as? String,
            let countryCode = location["countryCode"] as? String {
            return Region(city: city, country: country, countryCode: countryCode)
        } else if let city = data["city"] as? String,
            let country = data["country"] as? String,
            let countryCode = data["countryCode"] as? String {
            return Region(city: city, country: country, countryCode: countryCode)
        }
        return nil
    }
    
    var locationStr:String {
        get {
            return "\(city), \(country)"
        }
    }
    
    var locationShortStr:String {
        get {
            return "\(city.trunc(length: 16)), \(countryCode)"
        }
    }
}

class VideoAttachment {
    var size:CGSize
    var ratio:CGFloat
    var length:Double
    init(size:CGSize, ratio:CGFloat, length:Double) {
        self.size = size
        self.ratio = ratio
        self.length = length
    }
    
    static func parse(_ dict:[String:Any]) -> VideoAttachment? {
        if let length = dict["length"] as? Double,
            let size = dict["size"] as? [String:Any],
            let width = size["width"] as? Double,
            let height = size["height"] as? Double,
            let ratio = size["ratio"] as? Double {
            let size = CGSize(width: width, height: height)
            
            return VideoAttachment(size: size, ratio: CGFloat(ratio), length:length)
        }
        return nil
    }
}

class ImageAttachment {
    var size:CGSize
    var ratio:CGFloat
    init(size:CGSize, ratio:CGFloat) {
        self.size = size
        self.ratio = ratio
    }
    
    static func parse(_ dict:[String:Any]) -> ImageAttachment? {
        if let size = dict["size"] as? [String:Any],
            let width = size["width"] as? Double,
            let height = size["height"] as? Double,
            let ratio = size["ratio"] as? Double {
            let size = CGSize(width: width, height: height)
            
            return ImageAttachment(size: size, ratio: CGFloat(ratio))
        }
        return nil
    }
}

class Reports {
    var inappropriate:Int
    var spam:Int
    init(inappropriate:Int, spam:Int) {
        self.inappropriate = inappropriate
        self.spam = spam
    }
}
