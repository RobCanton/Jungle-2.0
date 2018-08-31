//
//  UserService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-27.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

class UserSettings {
    var locationServices = false
    var pushNotifications = false
    var safeContentMode = true
    
    init(locationServices:Bool,pushNotifications:Bool, safeContentMode:Bool) {
        self.locationServices = locationServices
        self.pushNotifications = pushNotifications
        self.safeContentMode = safeContentMode
    }
}

class UserService {
    
    static var lastPostedAt:Date?
    
    static var anonMode = true
    
    static var currentUser:User?
    static var currentUserSettings = UserSettings(locationServices: false, pushNotifications: false, safeContentMode: true)
    
    struct Timeout {
        var canPost:Bool
        var progress:CGFloat
        var minsLeft:Int
    }
    
    static  var timeout = Timeout(canPost: false, progress: 0.0, minsLeft: 0)
    
    static func parseTimeout(_ data:[String:Any]) -> Timeout {
        if let canPost = data["canPost"] as? Bool {
            if canPost {
                return Timeout(canPost: true, progress: 1.0, minsLeft: 0)
            } else if let progress = data["progress"] as? Double,
                let minsLeft = data["minsLeft"] as? Int {
                
                return Timeout(canPost: false,
                               progress: CGFloat(progress),
                               minsLeft: minsLeft)
            }
        }
        
        return Timeout(canPost: false, progress: 0, minsLeft: 0)
    }
    
    
    static let userUpdatedNotification = NSNotification.Name.init("userUpdated")
    static let userSettingsUpdatedNotification = NSNotification.Name.init("userSettingsUpdated")
    
    
    static var recentlyPosted  = false
    
    static var userSettingsHandle:UInt?
    static func observeCurrentUserSettings() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = database.child("users/settings/\(uid)")
        if let handle = userSettingsHandle {
            ref.removeObserver(withHandle: handle)
        }
        
        userSettingsHandle = ref.observe(.value, with: { snapshot in
            
            var locationServices = false
            var pushNotifications = false
            var safeContentMode = true
            if let dict = snapshot.value as? [String:Any] {
                if let _locationServices = dict["locationServices"] as? Bool {
                    locationServices = _locationServices
                }
                if let _pushNotifications = dict["pushNotifications"] as? Bool {
                    pushNotifications = _pushNotifications
                }
                if let _safeContentMode = dict["safeContentMode"] as? Bool {
                    safeContentMode = _safeContentMode
                }
            }
            
            currentUserSettings = UserSettings(locationServices: locationServices,
                                               pushNotifications: pushNotifications,
                                               safeContentMode: safeContentMode)
            NotificationCenter.default.post(name: UserService.userUpdatedNotification, object: nil)
        })
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
    
    static let userImageCache = NSCache<NSString, UIImage>()
    fileprivate static func downloadUserImage(uid:String, _ quality:ProfileImageQuality, completion:@escaping(_ image:UIImage?)->()) {
        let imageRef = storage.child("userProfile/\(uid)/\(quality.rawValue).jpg")
        
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
    
    static func retrieveUserImage(uid: String, _ quality: ProfileImageQuality, completion: @escaping (_ image:UIImage?, _ fromFile:Bool)->()) {
        let key = NSString(string: "\(uid)-\(quality.rawValue)")
        if let image = userImageCache.object(forKey: key) {
            completion(image, true)
        } else {
            downloadUserImage(uid: uid, quality) { image in
                if image != nil {
                    userImageCache.setObject(image!, forKey: key)
                }
                completion(image, false)
            }
        }
    }
    
    static func uploadProfileImage(_ image:UIImage, quality:ProfileImageQuality, completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("userProfile/\(uid)/\(quality.rawValue).jpg")
        
        var _quality:CGFloat
        switch quality {
        case .high:
            _quality = 0.8
            break
        case .low:
            _quality = 0.3
            break
        }
        
        guard let imageData = UIImageJPEGRepresentation(image, _quality) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            completion(error == nil)
        }
    }


}


