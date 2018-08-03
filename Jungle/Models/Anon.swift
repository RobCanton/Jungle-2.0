//
//  Anon.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class Anon {
    var key:String
    var adjective:String
    var animal:String
    var color:UIColor
    
    init(key:String,adjective:String,animal:String,color:UIColor) {
        self.key = key
        self.adjective = adjective
        self.animal = animal
        self.color = color
    }
    
    static func parse(_ data:[String:Any]) -> Anon? {
        if let anon = data["anon"] as? [String:Any],
            let key = anon["key"] as? String,
            let adjective = anon["adjective"] as? String,
            let animal = anon["animal"] as? String,
            let hex = anon["color"] as? String {
            
            return Anon(key: key, adjective: adjective, animal: animal, color: hexColor(from: hex))
        } else if let key = data["key"] as? String,
            let adjective = data["adjective"] as? String,
            let animal = data["animal"] as? String,
            let hex = data["color"] as? String {
            return Anon(key: key, adjective: adjective, animal: animal, color: hexColor(from: hex)                )
        } else {
            return nil
        }
    }
    
    var displayName:String {
        return "\(adjective)\(animal)"
    }
}

