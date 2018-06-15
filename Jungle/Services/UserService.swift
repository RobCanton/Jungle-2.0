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
    
    fileprivate  static func readAnonImageFromFile(withName name:String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("anon_icons/\(name).png")
        return UIImage(contentsOfFile: dataPath.path)
    }
    
    fileprivate static func writeAnonImageToFile(withName name:String, image:UIImage) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("anon_icons/\(name).png")
        if let pngData = UIImagePNGRepresentation(image) {
            do {
                try pngData.write(to: dataPath, options: [.atomic])
                print("ICON WRITTEN TO DISK: \(name)")
            } catch {
                print("Error writing to disk")
            }
        }
    }
    
    fileprivate static func downloadAnonImage(withName name:String, completion:@escaping(_ image:UIImage?)->()) {
        let imageRef = storage.child("AnonIcons/\(name).png")
        
        // Download in memory with a maximum allowed size of 2MB (2 * 1024 * 1024 bytes)
        imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                print("Error - \(error!.localizedDescription)")
                completion(nil)
            } else {
                var image:UIImage?
                if data != nil {
                    image = UIImage(data: data!)
                }
                return completion(image)
            }
        }
    }
    
    static func retrieveAnonImage(withName name: String, completion: @escaping (_ image:UIImage?, _ fromFile:Bool)->()) {
        if let image = readAnonImageFromFile(withName: name) {
            completion(image, true)
        } else {
            downloadAnonImage(withName: name) { image in
                if image != nil {
                    writeAnonImageToFile(withName: name, image: image!)
                }
                completion(image, false)
            }
        }
    }

}


