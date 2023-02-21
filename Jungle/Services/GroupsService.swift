//
//  GroupsService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

class GroupsService {
    static var groups = [Group]()
    static var groupsDict = [String:Group]()
    
    static var groupsFetched = false
    static var notification_groupsUpdated = Notification.Name.init("groupsUpdated")
    
    static var myGroupKeys = [String:Bool]()
    static var createdGroupKeys = [String:Bool]()
    static var skippedGroupKeys = [String:Bool]()
    static var trendingGroupKeys = [String]()
    
    static var myGroups = [Group]()
    static var allGroups = [Group]()
    
    static var myGroupsDidChange = false
    
    static var gradients = [[String]]()
    
    static var backgroundsFetched = false

    static func fetchBackgrounds(completion: @escaping (() -> ())) {
        let ref = firestore.collection("backgrounds")
        let query = ref.order(by: "order")
        query.addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            var _gradients = [[String]]()
            for document in documents {
                if let colors = document.data()["colors"] as? [String] {
                    _gradients.append(colors)
                }
            }
            
            let isFirst = gradients.count == 0
            gradients = _gradients
            if isFirst {
               return completion()
            }
        }
    }
    
    static func fetchGroups(completion: @escaping (() -> ())) {
        
        let ref = database.child("/groups/info")
        
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            var _groups = [Group]()
            var _groupsDict = [String:Group]()
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                if let data = childSnapshot.value as? [String:Any],
                    let group = Group.parse(id: childSnapshot.key, data) {
                    _groups.append(group)
                    _groupsDict[group.id] = group
                }
            }
            
            groups = _groups
            groupsDict = _groupsDict

            groupsFetched = true
            return completion()
        
        }, withCancel: { error in
            print("ERROR: \(error.localizedDescription)")
        })
    }
    
    static func observeGroups() {
        let ref = database.child("/groups/info")
        
        ref.observe(.childAdded, with: { snapshot in
            if let data = snapshot.value as? [String:Any],
                let group = Group.parse(id: snapshot.key, data) {
                print("Add group!: \(group.name)")
                removeGroup(group)
                addGroup(group)
            }
        })
        
        ref.observe(.childChanged, with: { snapshot in
            if let data = snapshot.value as? [String:Any],
                let group = Group.parse(id: snapshot.key, data) {
                print("Update group!: \(group.name)")
                updateGroup(group)
                
                let notification = Notification.Name.init("group_updated:\(group.id)")
                NotificationCenter.default.post(name: notification, object: nil)
            }
        })
        
        ref.observe(.childRemoved, with: { snapshot in
            if let data = snapshot.value as? [String:Any],
                let group = Group.parse(id: snapshot.key, data) {
                print("Remove group!: \(group.name)")
                removeGroup(group)
            }
        })
    }
    
    static func updateGroup(_ group:Group) {
        groupsDict[group.id] = group
        if let index = indexOf(group: group) {
            groups[index] = group
        }
    }
    
    static func addMyGroup(_ group:Group) {
        myGroupKeys[group.id] = true
        myGroupsDidChange = true
        addGroup(group)
    }
    
    static func addGroup(_ group:Group) {
        groupsDict[group.id] = group
        if indexOf(group: group) == nil {
            groups.append(group)
        }
    }
    
    static func removeGroup(_ group:Group) {
        groupsDict[group.id] = nil
        myGroupKeys[group.id] = nil
        if let index = indexOf(group: group) {
            groups.remove(at: index)
        }
    }
    
    static func sortGroups() {
        var _myGroups = [Group]()
        var _allGroups = [Group]()
        for group in groups {
            if myGroupKeys[group.id] == true {
                _myGroups.append(group)
            } else {
                _allGroups.append(group)
            }
        }
        
        myGroups = _myGroups.sorted(by: { $0.name < $1.name })
        allGroups = _allGroups.sorted(by: { $0.name < $1.name })
    }
    
    static func indexOf(group:Group) -> Int? {
        for i in 0..<groups.count {
            let _group = groups[i]
            if _group.id == group.id {
                return i
            }
        }
        return nil
    }
    
    static func joinGroup(id:String, completion: @escaping (_ success:Bool)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let update:[String:Any?]  = [
            "users/groups/\(uid)/\(id)": true,
            "groups/members/\(id)/\(uid)": true
        ]
        
        database.updateChildValues(update) { error, _ in
            if error == nil {
                myGroupKeys[id] = true
                myGroupsDidChange = true
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static func leaveGroup(id:String, completion: @escaping (_ success:Bool)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let update:[String:Any?] = [
            "users/groups/\(uid)/\(id)": nil,
            "groups/members/\(id)/\(uid)": nil,
            "users/groupsSkipped/\(uid)/\(id)": nil
        ]
        
        database.updateChildValues(update) { error, _ in
            if error == nil {
                myGroupKeys[id] = nil
                myGroupsDidChange = true
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static func skipGroup(id:String, completion: @escaping (_ success:Bool)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let update:[String:Any] = [
            "users/groupsSkipped/\(uid)/\(id)": true
        ]
        
        database.updateChildValues(update) { error, _ in
            if error == nil {
                skippedGroupKeys[id] = true
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static func clearSkippedGroups(completion: @escaping (_ success:Bool)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = database.child("users/groupsSkipped/\(uid)")
        ref.removeValue { error, _ in
            if error == nil {
                skippedGroupKeys = [:]
                completion(true)
            } else {
                completion(false)
            }
        }
    }

}
