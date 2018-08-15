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
    var profile:Profile?

    
    init(uid:String, authType:String, profile:Profile?) {
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
        self.profile = profile
    }
}

class Profile {
    
    private(set) var uid:String
    private(set) var username:String
    var gradient:[String]
    
    init(uid:String, username:String, gradient: [String]) {
        self.uid = uid
        self.username = username
        self.gradient = gradient
    }
    
    static func parse(_ data:[String:Any]) -> Profile? {
        var profileData = data
        if let _profileData = data["profile"] as? [String:Any] {
            profileData = _profileData
        }
        
        if let uid = profileData["uid"] as? String,
            let username = profileData["username"] as? String {
            let gradient = profileData["gradient"] as? [String] ?? [String]()
            return Profile(uid:uid,
                           username: username,
                           gradient: gradient)
        }
        
        return nil
    }
}
