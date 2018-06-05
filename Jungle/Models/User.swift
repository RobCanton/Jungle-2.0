//
//  User.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation


class User {
    private(set) var uid:String
    private(set) var username:String
    
    init(uid:String, username:String) {
        self.uid = uid
        self.username = username
    }
}
