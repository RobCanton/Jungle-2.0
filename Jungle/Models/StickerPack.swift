//
//  StickerPack.swift
//  Jungle
//
//  Created by Robert Canton on 2018-07-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation



class StickerPack {
    var id:String
    var name:String
    var url:URL
    
    init(id:String, name:String, url:URL) {
        self.id = id
        self.name = name
        self.url = url
    }
    
    static func parse(id:String, _ data:[String:Any]) -> StickerPack? {
        var pack:StickerPack?
        
        if let name = data["name"] as? String,
            let urlStr = data["url"] as? String,
            let url = URL(string: urlStr) {
            pack = StickerPack(id: id, name: name, url: url)
        }
        
        return pack
    }
    
}
