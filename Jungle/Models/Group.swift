//
//  Group.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class Group {
    private(set) var id:String
    private(set) var name:String
    private(set) var desc:String
    private(set) var tags:[String]
    private(set) var gradient:[String]
    var gradientColors:[UIColor] {
        var colors = [UIColor]()
        for hex in gradient {
            colors.append(hexColor(from: hex))
        }
        return colors
    }
    var gradientCGColors:[CGColor] {
        var colors = [CGColor]()
        for hex in gradient {
            colors.append(hexColor(from: hex).cgColor)
        }
        return colors
    }
    private(set) var avatar_low:URL
    private(set) var avatar_high:URL
    var numMembers:Int
    var numPosts:Int
    
    var score:Double {
        return Double(numMembers) + Double(numPosts) / 2
    }
    
    var infoStr:String {
        var membersStr:String
        if numMembers == 1 {
            membersStr = "1 Member"
        } else {
            membersStr = "\(numMembers) Members"
        }
        
        var postsStr:String
        if numPosts == 1 {
            postsStr = "1 Post"
        } else {
            postsStr = "\(numPosts) Posts"
        }
        return "\(membersStr)   \(postsStr)"
    }
    
    init(id:String, name:String, desc:String,
         tags:[String], gradient:[String],
         avatar_low:URL, avatar_high:URL,
         numMembers:Int, numPosts:Int) {
        self.id = id
        self.name = name
        self.desc = desc
        self.tags = tags
        self.gradient = gradient
        self.avatar_low = avatar_low
        self.avatar_high = avatar_high
        self.numMembers = numMembers
        self.numPosts = numPosts
    }
    
    static func parse(id:String, _ data:[String:Any]) -> Group? {
        if let name = data["name"] as? String,
            let desc = data["desc"] as? String,
            let gradient = data["gradient"] as? [String],
            let avatar = data["avatar"] as? [String:Any],
            let low = avatar["low"] as? String,
            let lowURL = URL(string: low),
            let high = avatar["high"] as? String,
            let highURL = URL(string: high) {
            var tags = [String]()
            
            if let _tags = data["tags"] as? [String] {
                tags = _tags
            }
            
            var numMembers = 0
            var numPosts = 0
            
            if let meta = data["meta"] as? [String:Any] {
                numMembers = meta["numMembers"] as? Int ?? 0
                numPosts = meta["numPosts"] as? Int ?? 0
            }
            
            return Group(id: id, name: name, desc: desc,
                         tags: tags, gradient: gradient,
                         avatar_low: lowURL, avatar_high: highURL,
                         numMembers: numMembers, numPosts: numPosts)
        }
        return nil
    }
}
