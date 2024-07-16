//
//  LocationManager.swift
//  PennEntertainmentAGI
//
//  Created by Buddy Rich on 7/11/24.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func didFetchLocation(_ latitude: Double, _ longitude: Double)
    func didFailWithError(_ error: Error)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    private var locationManager: CLLocationManager
    
    weak var delegate: LocationManagerDelegate?
    
    private override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Stop updating location to conserve battery - Plus we only need it when they first load the screen in case they have changed locations
        locationManager.stopUpdatingLocation()
        
        // Notify delegate with fetched location coordinates
        delegate?.didFetchLocation(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle location error
        delegate?.didFailWithError(error)
    }
}
