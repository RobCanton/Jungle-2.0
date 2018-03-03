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
    var key:String
    var name:String
    var desc:String
    
    init(key:String, name:String, desc:String) {
        self.key = key
        self.name = name
        self.desc = desc
    }
}
