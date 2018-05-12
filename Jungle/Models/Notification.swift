//
//  Notification.swift
//  Jungle
//
//  Created by Robert Canton on 2018-04-15.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation

enum NotificationType:String {
    case postVotes = "POST_VOTES"
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
    var type:NotificationType
    var timestamp:Date
    
    init(type:NotificationType, timestamp:Double) {
        self.type = type
        self.timestamp = Date(timeIntervalSince1970: timestamp / 1000)
    }
    
    static func parse(_ data:[String:Any]) -> JNotification? {
        if let typeStr = data["type"] as? String,
            let timestamp = data["timestamp"] as? Double {
            switch typeStr {
            case NotificationType.postVotes.rawValue:
                if let postID = data["postID"] as? String,
                    let newVotes = data["newVotes"] as? Int {
                    return PostVotesNotification(type: .postVotes, timestamp: timestamp, postID: postID, newVotes: newVotes)
                }
            case NotificationType.commentVotes.rawValue:
                return nil
            case NotificationType.postReply.rawValue:
                if let postID = data["postID"] as? String,
                    let replyID = data["replyID"] as? String {
                    return PostReplyNotification(type: .postVotes, timestamp: timestamp, postID: postID, replyID: replyID)
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

class PostVotesNotification:JNotification {

    var postID:String
    var newVotes:Int
    var post:Post?
    
    init(type: NotificationType, timestamp:
        Double, postID: String, newVotes:Int) {
        self.postID = postID
        self.newVotes = newVotes
        super.init(type: type, timestamp: timestamp)
        
    }
    override func fetchData(completion: @escaping () -> ()) {
        PostsService.getPost(postID) { _post in
            self.post = _post
            return completion()
        }
    }
}

class PostReplyNotification:JNotification {
    
    var postID:String
    var replyID:String
    var post:Post?
    var reply:Post?
    
    init(type: NotificationType, timestamp:
        Double, postID: String, replyID: String) {
        self.postID = postID
        self.replyID = replyID
        super.init(type: type, timestamp: timestamp)
        
    }
    override func fetchData(completion: @escaping () -> ()) {
        PostsService.getPost(postID) { _post in
             self.post = _post
            PostsService.getPost(self.replyID) { _reply in
                 self.reply = _reply
                return completion()
            }
        }
    }
}
