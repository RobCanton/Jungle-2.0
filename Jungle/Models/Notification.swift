//
//  Notification.swift
//  Jungle
//
//  Created by Robert Canton on 2018-04-15.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation

enum NotificationType:String {
    case postVotes = "POST_LIKES"
    case commentVotes = "COMMENT_VOTES"
    case postReply = "POST_REPLY"
    
    static func parse(_ typeStr:String) -> NotificationType? {
        switch typeStr {
        case NotificationType.postVotes.rawValue:
            return NotificationType.postVotes
        case NotificationType.commentVotes.rawValue:
            return NotificationType.commentVotes
        default:
            return nil
        }
    }
}

class JNotification {
    var id:String
    var type:NotificationType
    var timestamp:Date
    var seen:Bool
    var profile:Profile?
    var anon:Anon
    
    init(id:String, type:NotificationType, timestamp:Double, seen:Bool, profile: Profile?, anon:Anon) {
        self.id = id
        self.type = type
        self.timestamp = Date(timeIntervalSince1970: timestamp / 1000)
        self.seen = seen
        self.profile = profile
        self.anon = anon
    }
    
    static func parse(_ id:String, _ data:[String:Any]) -> JNotification? {
        if let typeStr = data["type"] as? String,
            let timestamp = data["timestamp"] as? Double,
            let seen = data["seen"] as? Bool {
            print("Notification \(id): seen \(seen)")
            let profile = Profile.parse(data)
            let anon = Anon.parse(data) ?? Anon(key: "", adjective: "", animal: "", color: .black)
            switch typeStr {
            case NotificationType.postVotes.rawValue:
                if let postID = data["postID"] as? String,
                    let newVotes = data["numLikes"] as? Int {
                    return PostVotesNotification(id: id, type: .postVotes, timestamp: timestamp,
                                                 seen: seen, profile: profile, anon: anon, postID: postID, newVotes: newVotes)
                }
            case NotificationType.commentVotes.rawValue:
                return nil
            case NotificationType.postReply.rawValue:
                if let postID = data["postID"] as? String,
                    let replyID = data["replyID"] as? String {
                    let mention = data["mention"] as? Bool ?? false
                    let replyToID = data["replyTo"] as? String

                    return PostReplyNotification(id: id, type: .postVotes, timestamp: timestamp,
                                                 seen: seen, profile: profile, anon: anon, postID: postID, replyID: replyID,
                                                 replyToID: replyToID, mention: mention)
                }
            default:
                return nil
            }
            
        }
        return nil
    }
    
    func fetchData(completion:@escaping()->()) {
        completion()
    }
}

extension JNotification: Equatable, Comparable {
    static func < (lhs: JNotification, rhs: JNotification) -> Bool {
        return lhs.timestamp.compare(rhs.timestamp) == .orderedAscending
    }
    
    
    static func == (lhs: JNotification, rhs: JNotification) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}

class PostVotesNotification:JNotification {

    var postID:String
    var newVotes:Int
    var post:Post?
    
    init(id:String, type: NotificationType, timestamp:
        Double, seen:Bool, profile: Profile?,anon:Anon, postID: String, newVotes:Int) {
        self.postID = postID
        self.newVotes = newVotes
        super.init(id:id, type: type, timestamp: timestamp, seen: seen, profile: profile, anon: anon)
        
    }
    override func fetchData(completion: @escaping () -> ()) {
        if post != nil { return completion() }
        PostsService.getPost(postID) { _post in
            self.post = _post
            return completion()
        }
    }
}

class PostReplyNotification:JNotification {
    
    var postID:String
    var replyID:String
    var replyToID:String?
    var post:Post?
    var reply:Post?
    var mention:Bool
    
    init(id:String, type: NotificationType, timestamp:
        Double, seen:Bool, profile:Profile?, anon:Anon,  postID: String, replyID: String, replyToID: String?, mention:Bool) {
        self.postID = postID
        self.replyID = replyID
        self.replyToID = replyToID
        self.mention = mention
        super.init(id:id, type: type, timestamp: timestamp, seen: seen, profile: profile, anon: anon)
    }
    
    override func fetchData(completion: @escaping () -> ()) {
        if post != nil, reply != nil { return completion() }
        PostsService.getPost(postID) { _post in
            if let post = _post {
                PostsService.getAdditionalPostInfo(post) { populatedPost in
                    self.post = populatedPost
                    if self.reply != nil {
                        return completion()
                    }
                }
            }
        }
        PostsService.getPost(self.replyID) { _post in
            if let post = _post {
                PostsService.getAdditionalPostInfo(post) { populatedPost in
                    self.reply = populatedPost
                    if self.post != nil {
                        return completion()
                    }
                }
            }
        }
    }
}
