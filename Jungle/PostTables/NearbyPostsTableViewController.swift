//
//  NearbyPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-20.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import SwiftMessages

class NearbyPostsTableViewController: PostsTableViewController {
    
    var proximity:UInt = 0
    
    override func lightBoxVC() -> LightboxViewController {
        let lightbox = NearbyLightboxViewController()
        lightbox.proximity = proximity
        return lightbox
    }
    
    override var headerCell: ASCellNode {
        get {
            if gpsService.isAuthorized() {
                let cell = NearbyHeaderCellNode()
                cell.delegate = self
                return cell
            } else {
                let cell = EnableLocationServicesCellNode()
                cell.handleTap = handleAuthorizeGPSTap
                let height = UIScreen.main.bounds.height - 49 - 70
                cell.style.height = ASDimension(unit: .points, value: height)
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func handleAuthorizeGPSTap() {
        let status = gpsService.authorizationStatus()
        switch status {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        case .denied:
            if #available(iOS 10.0, *) {
                let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)! as URL
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            } else {
                let alert = UIAlertController(title: "Go to Settings", message: "Please go to your device settings and enable location services for Jungle.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            break
        case .notDetermined:
            gpsService.requestAuthorization()
            break
        case .restricted:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.contentInset = .zero
        if gpsService.isAuthorized() {
            tableNode.view.isScrollEnabled = true
        } else {
            tableNode.view.isScrollEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLocationUpdate), name: GPSService.locationUpdatedNotification, object: nil)
    }
    
    @objc func handleLocationUpdate() {
        state = .empty
        tableNode.view.isScrollEnabled = true
        SearchService.searchNearby(proximity: self.proximity, offset: self.state.posts.count) { posts in
            
            let action = PostsStateController.Action.endBatchFetch(posts: posts)
            let oldState = self.state
            self.state = PostsStateController.handleAction(action, fromState: oldState)
            self.tableNode.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    override func handleRefresh() {
        context?.cancelBatchFetching()
        
        state = .empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            SearchService.searchNearby(proximity: self.proximity, offset: self.state.posts.count) { posts in
                let action = PostsStateController.Action.endBatchFetch(posts: posts)
                let oldState = self.state
                self.state = PostsStateController.handleAction(action, fromState: oldState)
                self.tableNode.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.searchNearby(proximity: proximity, offset: state.posts.count, completion: completion)
    }
}

extension NearbyPostsTableViewController: DistanceSliderDelegate {
    func proximityChanged(_ proximity: UInt) {
        self.proximity = proximity
        context?.cancelBatchFetching()

        state = .empty
        shouldBatchFetch = false
        
        self.tableNode.performBatch(animated: false, updates: {
            self.tableNode.reloadSections(IndexSet([1]), with: .none)
        }, completion: { _ in
            self.shouldBatchFetch = true
        })
    }
}
