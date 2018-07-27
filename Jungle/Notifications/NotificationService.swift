//
//  NotificationService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-24.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase
import Differ
import UserNotifications
import SwiftMessages

enum DiffOperationType {
    case insertion
    case deletion
}

enum NotificationPermissionStatus {
    case authorized, notDetermined, denied
}

class NotificationService {
    
    static func authorizationStatus(completion: @escaping((_ status:NotificationPermissionStatus)->())) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let ref = database.child("users/settings/\(uid)/pushNotifications")
                switch settings.authorizationStatus {
                case .authorized:
                    return completion(.authorized)
                case .notDetermined:
                    ref.setValue(false)
                    return completion(.notDetermined)
                case .denied:
                    ref.setValue(false)
                    return completion(.denied)
                }
                
            }
        }
    }
    
    static func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let ref = database.child("users/settings/\(uid)/pushNotifications")
                ref.setValue(true)
            }
        }
    }
    
    static func showRequestAlert(_ messageWrapper:SwiftMessages?=nil, message:String?=nil) {
        let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
        messageView.configureBackgroundView(width: 250)
        var msg = "You will receive push notifications when users interact with your posts and comments."
        if message != nil {
            msg = message!
        }
        messageView.configureContent(title: "Recieve Push Notifications?", body: message, iconImage: nil, iconText: "🔔", buttonImage: nil, buttonTitle: "Enable Notifications") { _ in
            registerForPushNotifications()
            if let wrapper = messageWrapper {
                wrapper.hide()
            } else {
                SwiftMessages.hide()
            }
        }
        messageView.titleLabel?.font = Fonts.semiBold(ofSize: 16.0)
        messageView.bodyLabel?.font = Fonts.regular(ofSize: 14.0)
        
        let button = messageView.button!
        button.backgroundColor = accentColor
        button.titleLabel!.font = Fonts.semiBold(ofSize: 16.0)
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 12.0, right: 16.0)
        button.sizeToFit()
        button.layer.cornerRadius = messageView.button!.bounds.height / 2
        button.clipsToBounds = true
        
        messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
        messageView.backgroundView.layer.cornerRadius = 12
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.duration = .forever
        config.dimMode = .gray(interactive: true)
        
        if let wrapper = messageWrapper {
            wrapper.show(config: config, view: messageView)
        } else {
            SwiftMessages.show(config: config, view: messageView)
        }
        
    }
}


protocol NotificationObserverDelegate:class {
    func newNotificationRecieved()
}
class NotificationObserver {
    struct State {
        var newNotifications:[JNotification]
        var notifications: [JNotification]
        var fetchingMore: Bool
        var lastTimestamp:Double?
        var endReached:Bool
        var isFirstLoad:Bool
        var pendingRemovals: [(String,Date)]
        
        static let empty = State(newNotifications: [],
                                 notifications: [],
                                 fetchingMore: false,
                                 lastTimestamp: nil,
                                 endReached: false,
                                 isFirstLoad: true,
                                 pendingRemovals: [])
    }
    
    var state = State.empty
    
    weak var delegate:NotificationObserverDelegate?
    
    
    enum Action {
        case beginBatchFetch
        case insertNew(notification:JNotification)
        case insertBatch(notifications: [JNotification])
        case appendBatch(notifications: [JNotification])
        case remove(id:String, date: Date)
        case firstLoadComplete
        case clear
    }
    
    func initialFetch() {
        
        if state.fetchingMore || state.endReached, !state.isFirstLoad { return }
        let oldState = self.state
        self.state = NotificationObserver.handleAction(.beginBatchFetch, fromState: oldState)
        print("INITIAL FETCH!")
        fetchData { notifications, endReached in
            let oldState = self.state
            self.state = NotificationObserver.handleAction(.appendBatch(notifications: notifications), fromState: oldState)
            
            if self.state.isFirstLoad {
                let oldState = self.state
                self.state = NotificationObserver.handleAction(.firstLoadComplete, fromState: oldState)
                self.observeNewNotifications()
            }
        }
    }
    
    func observeNewNotifications() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = database.child("users/notifications/\(uid)")
        var query = ref.queryOrdered(byChild: "timestamp")
        var firstTimestamp:Double = 0.0
        if let first = state.notifications.first {
            firstTimestamp = first.timestamp.timeIntervalSince1970 * 1000
            query = query.queryStarting(atValue: firstTimestamp)
        }
        query.observe(.childAdded, with: { snapshot in
            print("NOTIFICATION ADDED")
            if let data = snapshot.value as? [String:Any],
                let n = JNotification.parse(snapshot.key, data),
                firstTimestamp != n.timestamp.timeIntervalSince1970 * 1000 {
                print("WE GOT A NEW ONE: \(n.id)")
                let oldState = self.state
                self.state = NotificationObserver.handleAction(.insertNew(notification: n), fromState: oldState)
                self.delegate?.newNotificationRecieved()
            }
        })
        
        ref.observe(.childRemoved, with: { snapshot in
            print("NOTIFICATION REMOVED: \(snapshot.value as? [String:Any])")
            
            if let data = snapshot.value as? [String:Any],
                let n = JNotification.parse(snapshot.key, data) {
                let key = snapshot.key
                let oldState = self.state
                let action = NotificationObserver.Action.remove(id: key, date: n.timestamp)
                self.state = NotificationObserver.handleAction(action, fromState: oldState)
                self.delegate?.newNotificationRecieved()
            }
        })

    }
    
    func fetchData(completion:@escaping (_ notifications:[JNotification], _ endReached:Bool)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = database.child("users/notifications/\(uid)")
        let queryRoot = ref.queryOrdered(byChild: "timestamp")
        var query:DatabaseQuery
        var lastID:Double = 0.0
        if let last = state.notifications.last {
            
            let lastTimestamp = last.timestamp.timeIntervalSince1970 * 1000
            lastID = lastTimestamp
            lastID = lastTimestamp
            query = queryRoot.queryEnding(atValue:
                lastTimestamp).queryLimited(toLast: 12)
            
        } else {
           query = queryRoot.queryLimited(toLast: 12)
        }
        
        
        query.observeSingleEvent(of: .value, with: { snapshot in
            var notifications = [JNotification]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                let childData = childSnapshot.value as? [String:Any],
                let n = JNotification.parse(childSnapshot.key, childData),
                lastID != n.timestamp.timeIntervalSince1970 * 1000{
                    print("RXC N: \(n.timestamp.timeSinceNow())")
                    notifications.insert(n, at: 0)
                }
            }
            
            return completion(notifications, notifications.count == 0)
        })
    }
    
    
    func clear() {
        let oldState = self.state
        self.state = NotificationObserver.handleAction(.clear, fromState: oldState)
        self.delegate?.newNotificationRecieved()
    }
    
    static func handleAction(_ action: Action, fromState state: State) -> State {
        var state = state
        switch action {
        case let .insertNew(notification):
            state.newNotifications.insert(notification, at: 0)
            break
        case .beginBatchFetch:
            state.fetchingMore = true
            break
        case let .insertBatch(notifications):
            state.notifications.insert(contentsOf: notifications, at: 0)
            
            if let last = state.notifications.last {
                state.lastTimestamp = last.timestamp.timeIntervalSince1970 * 1000
            } else {
                state.lastTimestamp = nil
            }
            
            break
        case let .appendBatch(notifications):
            state.notifications.append(contentsOf: notifications)
            
            if let last = state.notifications.last {
                state.lastTimestamp = last.timestamp.timeIntervalSince1970 * 1000
            } else {
                state.lastTimestamp = nil
            }
            
            state.fetchingMore = false
            state.endReached = notifications.count == 0
            
            for removal in state.pendingRemovals {
                let id = removal.0
                let date = removal.1
                for i in 0..<state.notifications.count {
                    let notification = state.notifications[i]
                    if notification.id == id,
                        notification.timestamp.compare(date) == .orderedSame {
                        state.notifications.remove(at: i)
                        break
                    }
                }
                for j in 0..<state.newNotifications.count {
                    let notification = state.newNotifications[j]
                    if notification.id == id,
                        notification.timestamp.compare(date) == .orderedSame {
                        state.newNotifications.remove(at: j)
                        break
                    }
                }
            }
            state.pendingRemovals = []
            
            break
        case let .remove(id, date):
            if state.fetchingMore {
                print("STATE ADD PENDING REMOVAL")
                state.pendingRemovals.append((id, date))
            } else {
                print("STATE ATTEMPT REMOVE")
                for i in 0..<state.notifications.count {
                    let notification = state.notifications[i]
                    if notification.id == id,
                        notification.timestamp.compare(date) == .orderedSame {
                        print("STATE REMOVE")
                        state.notifications.remove(at: i)
                        break
                    }
                }
                for j in 0..<state.newNotifications.count {
                    let notification = state.newNotifications[j]
                    if notification.id == id,
                        notification.timestamp.compare(date) == .orderedSame {
                        print("STATE REMOVE")
                        state.newNotifications.remove(at: j)
                        break
                    }
                }
            }
            break
        case .firstLoadComplete:
            state.isFirstLoad = false
            break
        case .clear:
            state = .empty
            break
        }
        
        
        return state
    }
}


func binarySearch(_ a: [JNotification], key: Date) -> Int? {
    var lowerBound = 0 // The start of the array
    var upperBound = a.count // The end of the array
    // If we still have elements to search for in the array
    while lowerBound < upperBound {
        // Get the middle of the array
        let midIndex = lowerBound + (upperBound - lowerBound) / 2
        // If middle of array is the value we are searching for return it
        if a[midIndex].timestamp.compare(key) == .orderedSame {
            return midIndex
            // Otherewise if the middle element is less then the value search the right side of the array
        } else if a[midIndex].timestamp.compare(key) == .orderedAscending {
            lowerBound = midIndex + 1
            // Otherewise if the middle element is greater then the value search the left side of the array
        } else {
            upperBound = midIndex
        }
    }
    // If we dont find the value we are searching for return nil
    return nil
}
