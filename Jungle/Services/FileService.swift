//
//  FileService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-24.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AsyncDisplayKit

var thumbnailCache = DictionaryCache<ASAnimatedImageProtocol>()

struct DictionaryCache<T> {
    var items = [(String,T)]()
    let maxItems = 25
    
    mutating func add(key:String, item: T) {
        if items.count > maxItems {
            items.removeFirst()
        }
        items.append((key,item))
    }
    
    func item(withKey key:String) -> T? {
        for item in items {
            if item.0 == key {
                return item.1
            }
        }
        return nil
    }
    
}

class FileService {
    
    static let gifCache = NSCache<NSString, NSData>()
    
    fileprivate static func thumbnailFileExists(withKey key:String) -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_thumbnail-\(key).jpg")
        let exists = FileManager.default.fileExists(atPath: dataPath.path)
        return exists
    }
    
    fileprivate static func writeThumbnailToFile(withKey key:String, data:Data) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_thumbnail-\(key).jpg")
        
        try! data.write(to: dataPath, options: [.atomic])
        return dataPath
    }
    
    fileprivate static func readThumbnailFromFile(withKey key:String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("user_content/upload_thumbnail-\(key).jpg")
        do {
            let data = try Data(contentsOf: dataPath)
            let image = UIImage(data: data)
            return image
        } catch {
            return nil
        }
    }
    
    fileprivate static func downloadThumbnail(withKey key:String, completion: @escaping (_ data:Data?)->()) {
        let thumbnailRef = storage.child("publicPosts/\(key)/thumbnail.jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        thumbnailRef.getData(maxSize: 4 * 1024 * 1024) { data, error in
            if let error = error {
                print("WE GOT AN ERROR: \(error.localizedDescription)")
            }
            print("YO")
            return completion(data)
        }
    }
    
    static func retrieveThumbnail(withKey key:String, completion: @escaping (_ image:UIImage?, _ fromFile:Bool)->()) {
        if let image = readThumbnailFromFile(withKey: key) {
            print("READ FROM FILE")
            completion(image, true)
        } else {
            print("DOWNLOAD!")
            downloadThumbnail(withKey: key) { data in
                if data != nil  {
                    let _ = writeThumbnailToFile(withKey: key, data: data!)
                    let image = UIImage(data: data!)
                    return completion(image, false)
                }
                return completion(nil, false)
            }
        }
    }
}
