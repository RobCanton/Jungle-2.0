//
//  GPSService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-26.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class GPSService: NSObject, CLLocationManagerDelegate {
    
    static let locationUpdatedNotification = Notification.Name.init("LocationUpdated")
    static let regionUpdatedNotification = Notification.Name.init("RegionUpdated")
    
    fileprivate var locationManager: CLLocationManager?
    fileprivate var lastLocation: CLLocation?
    fileprivate var currentAccuracy:Double?
    
    private(set) var region:Region? {
        didSet {
            NotificationCenter.default.post(name: GPSService.regionUpdatedNotification, object: self)
        }
    }
    fileprivate var lastSignificantLocation: CLLocation? {
        didSet {
            if let location = lastSignificantLocation {
                NotificationCenter.default.post(name: GPSService.locationUpdatedNotification, object: self)
                let params = [
                    "lat": location.coordinate.latitude,
                    "lng": location.coordinate.longitude
                ]
                functions.httpsCallable("myRegion").call(params) { results, error in
                    if let data = results?.data as? [String:Any], error == nil {
                        self.region = Region.parse(data)
                    }
                }
            }
        }
    }
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // The accuracy of the location data
        locationManager.distanceFilter = 50.0 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
    }
    
    func requestAuthorization() {
        let status = authorizationStatus()
        switch status {
        case .notDetermined:
            self.locationManager?.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(settingsUrl)
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
        
    }
    
    func setAccurateGPS(_ accurate:Bool) {
        if accurate {
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
        }
    }
    
    func getLastLocation() -> CLLocation? { return lastLocation }
    
    func authorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    func isAuthorized() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                return false
            case .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }
    
    func startUpdatingLocation() {
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager?.stopUpdatingLocation()
    }
    
    // CLLocationManagerDelegate
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        currentAccuracy = location.horizontalAccuracy
        
        if location.horizontalAccuracy > 100.0 { return }
        self.lastLocation = location
        
        if lastSignificantLocation == nil {
            lastSignificantLocation = location

        } else {
            let age = location.timestamp.timeIntervalSince(lastSignificantLocation!.timestamp)
            
            let dist = lastSignificantLocation!.distance(from: location)
            if age > 3.0 && dist > 25.0 {
                print("Updating location -> age: \(age) dist: \(dist)")
                lastSignificantLocation = location
            }
        }
        
        
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Location failed: \(error.localizedDescription)")
        // do on error
        updateLocationDidFailWithError(error as NSError)
    }
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }
    
    internal func updateLocationDidFailWithError(_ error: NSError) {
        
    }

}
