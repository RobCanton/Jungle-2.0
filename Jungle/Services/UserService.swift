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
    
    static var currentUser:User?
    static var currentUserSettings = UserSettings(locationServices: false, pushNotifications: false, safeContentMode: true)
    
    static let userUpdatedNotification = NSNotification.Name.init("userUpdated")
    static let userSettingsUpdatedNotification = NSNotification.Name.init("userSettingsUpdated")
    
    
    static var recentlyPosted  = false
    static func getUser(_ uid:String, completion: @escaping (_ user:User?)->()) {
        
        let ref = firestore.collection("users").document(uid)
        ref.getDocument { snapshot, error in
            print("LOL!")
            var user:User?
            if let error = error {
                print ("ERROR: \(error.localizedDescription)")
            }
            if let snapshot = snapshot {
                let data = snapshot.data()
                
                if let type = data?["type"] as? String {
                    var lastPostedAt:Date?
                    if let lastPostTimestamp = data?["lastPostedAt"] as? Double {
                        lastPostedAt = Date(timeIntervalSince1970: lastPostTimestamp)
                    }
                    
                    user = User(uid: uid, authType: type, lastPostedAt: lastPostedAt)
                }
            }
            return completion(user)
        }
    }
    
    static func observeCurrentUser() {
        guard let user = currentUser else { return }
        let ref = firestore.collection("users").document(user.uid)
        ref.addSnapshotListener { snapshot, error in
            if let snapshot = snapshot {
                let data = snapshot.data()
                
                if let type = data?["type"] as? String {
                    var lastPostedAt:Date?
                    if let lastPostTimestamp = data?["lastPostedAt"] as? Double {
                        lastPostedAt = Date(timeIntervalSince1970: lastPostTimestamp)
                    }
                    
                    currentUser = User(uid: user.uid, authType: type, lastPostedAt: lastPostedAt)
                    NotificationCenter.default.post(name: UserService.userUpdatedNotification, object: nil)
                }
            }
        }
    }
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


