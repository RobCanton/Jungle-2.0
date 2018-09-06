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
    var id:String
    var name:String
    var desc:String
    var avatar_low:URL
    var avatar_high:URL
    var numMembers:Int
    var numPosts:Int
    
    init(id:String, name:String, desc:String,
         avatar_low:URL, avatar_high:URL,
         numMembers:Int, numPosts:Int) {
        self.id = id
        self.name = name
        self.desc = desc
        self.avatar_low = avatar_low
        self.avatar_high = avatar_high
        self.numMembers = numMembers
        self.numPosts = numPosts
    }
    
    static func parse(id:String, _ data:[String:Any]) -> Group? {
        if let name = data["name"] as? String,
            let desc = data["desc"] as? String,
            let avatar = data["avatar"] as? [String:Any],
            let low = avatar["low"] as? String,
            let lowURL = URL(string: low),
            let high = avatar["high"] as? String,
            let highURL = URL(string: high) {
            let numMembers = data["numMembers"] as? Int ?? 0
            let numPosts = data["numPosts"] as? Int ?? 0
            return Group(id: id, name: name, desc: desc,
                         avatar_low: lowURL, avatar_high: highURL,
                         numMembers: numMembers, numPosts: numPosts)
        }
        return nil
    }
}
