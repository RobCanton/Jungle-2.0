//
//  Reply.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-17.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class Reply {
    var key:String
    var anon:Anon
    var text:String
    var createdAt:Date
    
    init(key:String, anon:Anon, text:String, createdAt:Date) {
        self.key = key
        self.anon = anon
        self.text = text
        self.createdAt = createdAt
    }
    
    static func parse(id:String,_ data:[String:Any]) -> Reply? {
        if let anon = Anon.parse(data),
            let text = data["text"] as? String,
            let createdAt = data["createdAt"] as? Double {
            let reply = Reply(key: id, anon: anon, text: text, createdAt: Date(timeIntervalSince1970: createdAt / 1000))
            return reply
        }
        return nil
    }
}
