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
}
