//
//  LocationService.swift
//  WeatherUp
//
//  Created by Jan Dammshäuser on 24.03.16.
//  Copyright © 2016 Jan Dammshäuser. All rights reserved.
//

import Foundation
import MapKit

class LocationService: NSObject, CLLocationManagerDelegate {
    static let inst = LocationService()
    
    let locationManager = CLLocationManager()
    
    private var _lat: String!
    private var _lon: String!
    
    private var _lastUpdate: NSDate!
    
    var apiLocation: String {
        guard _lat != nil && _lon != nil else {
            return ""
        }
        return "\(API_LAT)\(_lat)\(API_LON)\(_lon)"
    }
    
    func getLocation() -> Bool {
        guard _lastUpdate == nil || _lastUpdate.olderThan(inMinutes: 15) else {
            print("no location updated needed")
            locationIsAvailable()
            return false
        }
        
        return locationAuthStatus()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            return locationIsNotAvailable()
        }
        
        locationManager.stopUpdatingLocation()
        
        let position = location.coordinate
        _lat = "\(position.latitude.roundTo(decimals: 2))"
        _lon = "\(position.longitude.roundTo(decimals: 2))"
        
        _lastUpdate = NSDate()
        
        locationIsAvailable()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        locationIsNotAvailable()
    }

    private func locationAuthStatus() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            return locationRequest()
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            return locationAuthStatus()
        default:
            return locationAuthError()
        }
    }
    
    private func locationRequest() -> Bool {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        return true
    }
    
    private func locationAuthError() -> Bool {
        NSNotificationCenter.defaultCenter().postNotificationName("locationAuthError", object: nil)
        return false
    }
    
    private func locationIsNotAvailable() {
        NSNotificationCenter.defaultCenter().postNotificationName("locationIsNotAvailable", object: nil)
    }
    
    private func locationIsAvailable() {
        NSNotificationCenter.defaultCenter().postNotificationName("locationIsAvailable", object: nil)
    }

}
