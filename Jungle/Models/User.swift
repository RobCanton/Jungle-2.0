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
    private(set) var profile:Profile?

    
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
    private(set) var username:String
    private(set) var avatarURL:URL
    private(set) var avatarThumbnailURL:URL
    
    init(username:String, avatarURL:URL, avatarThumbnailURL:URL) {
        self.username = username
        self.avatarURL = avatarURL
        self.avatarThumbnailURL = avatarThumbnailURL
    }
    
    static func parse(_ data:[String:Any]) -> Profile? {
        var profileData = data
        if let _profileData = data["profile"] as? [String:Any] {
            profileData = _profileData
        }
        
        if let username = profileData["username"] as? String,
            let avatarData = profileData["avatar"] as? [String:Any],
            let avatarURLStr = avatarData["high"] as? String,
            let avatarThumbnailURLStr = avatarData["low"] as? String,
            let avatarURL = URL(string: avatarURLStr),
            let avatarThumbnail = URL(string: avatarThumbnailURLStr) {
            
            return Profile(username: username, avatarURL: avatarURL, avatarThumbnailURL: avatarThumbnail)
        }
        
        return nil
    }
}
