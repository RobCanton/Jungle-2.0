//
//  ReportService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-21.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase


enum ReportType:String {
    case spam = "spam"
    case inappropriate = "inappropriate"
}

class ReportService {
    
    static func reportPost(_ post:Post, type:ReportType) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = database.child("posts/reports/\(post.key)/\(uid)")
        let reportData = [
            "type": type.rawValue,
            "timestamp": [".sv": "timestamp"]
            ] as [String: Any]
        
        ref.setValue(reportData) { error, _ in
            if let _ = error {
                Alerts.showFailureAlert(withMessage: "Report failed to send. Try again.")
            } else {
                Alerts.showSuccessAlert(withMessage: "Report Received!")
            }
        }
    }
    
    static func blockUser(_ post:Post) {
        functions.httpsCallable("blockUser").call([
            "postID": post.key,
            "blockedID": post.anon.key,
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]) { result, error in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
                Alerts.showFailureAlert(withMessage: "Failed to block user. Try again.")
            } else {
                Alerts.showSuccessAlert(withMessage: "User blocked!")
            }
        }
//        let userRef = firestore.collection("users").document(uid)
//            .collection("blocked").document("\(post.key):\(post.anon.key)")
//        userRef.setData([
//            "post": post.key,
//            "blockedID": post.anon.key,
//            "timestamp": Date().timeIntervalSince1970 * 1000
//            ], completion: { error in
//                if let error = error {
//                    print("ERROR: \(error.localizedDescription)")
//                    Alerts.showFailureAlert(withMessage: "Failed to block user. Try again.")
//                } else {
//                    Alerts.showSuccessAlert(withMessage: "User blocked!")
//                }
//        })
    }
}
