//
//  User.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation

enum AuthType {
    case anonymous, authenticated
}

class User {
    private(set) var uid:String
    private(set) var username:String
    private(set) var authType:AuthType
    
    init(uid:String, authType:String, username:String) {
        self.uid = uid
        self.username = username
        switch authType {
        case "anonymous":
            self.authType = .anonymous
            break
        case "authenticated":
            self.authType = .authenticated
            break
        default:
            self.authType = .anonymous
            break
        }
    }
}
