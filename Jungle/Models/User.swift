//
//  User.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation

enum AuthType {
    case anonymous, email
}

class User {
    private(set) var uid:String
    private(set) var authType:AuthType
    private(set) var lastPostedAt:Date?

    
    init(uid:String, authType:String, lastPostedAt: Date?) {
        self.uid = uid
        switch authType {
        case "anonymous":
            self.authType = .anonymous
            break
        case "email":
            self.authType = .email
            break
        default:
            self.authType = .anonymous
            break
        }
        self.lastPostedAt = lastPostedAt
    }
}
