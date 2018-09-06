//
//  GroupsService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class GroupsService {
    static var groups = [Group]()
    static var groupsDict = [String:Group]()
    
    static var groupsFetched = false
    static var notification_groupsUpdated = Notification.Name.init("groupsUpdated")
    
    static var myGroupKeys = [String:Bool]()
    
    
    static var myGroups = [Group]()
    static var allGroups = [Group]()
    
    static var myGroupsDidChange = false
    
    static func observeGroups() {
        let ref = Firestore.firestore().collection("groups")
        ref.addSnapshotListener { snapshot, error in
            var _groups = [Group]()
            var _groupsDict = [String:Group]()
            if let snapshot = snapshot {
                for doc in snapshot.documents {
                    if let group = Group.parse(id: doc.documentID, doc.data()) {
                        _groups.append(group)
                        _groupsDict[doc.documentID] = group
                    }
                }
            }
            
            groups = _groups
            groupsDict = _groupsDict
            
            groupsFetched = true
            NotificationCenter.default.post(name: notification_groupsUpdated, object: nil)
        }
    }
    
    static func addMyGroup(_ group:Group) {
        groupsDict[group.id] = group
        myGroupKeys[group.id] = true
        if indexOf(group: group) == nil {
            groups.append(group)
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
        let update:[String:Any]  = [
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
            "groups/members/\(id)/\(uid)": nil
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

}
