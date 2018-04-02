//
//  UserService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-27.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

class UserService {
    
    static var isSignedIn:Bool {
        guard let user = Auth.auth().currentUser else { return false }
        return !user.isAnonymous
    }
}


