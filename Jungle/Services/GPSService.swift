//
//  GPSService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-26.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

class GPSService: NSObject, CLLocationManagerDelegate {
    
    static let locationUpdatedNotification = Notification.Name.init("LocationUpdated")
    fileprivate var locationManager: CLLocationManager?
    fileprivate var lastLocation: CLLocation?
    fileprivate var currentAccuracy:Double?
    fileprivate var lastSignificantLocation: CLLocation? {
        didSet {
            if lastSignificantLocation != nil {
                NotificationCenter.default.post(name: GPSService.locationUpdatedNotification, object: self)
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
        self.locationManager?.requestWhenInUseAuthorization()
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
        
    }
    
    internal func updateLocationDidFailWithError(_ error: NSError) {
        
    }

}
