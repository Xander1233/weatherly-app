//
//  LocationManager.swift
//  weatherly
//
//  Created by David Neidhart on 18.12.22.
//

import Foundation
import CoreLocation

class LocationManagerWidgets: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    
    @Published var degrees: Double = .zero
    
    init(_ accuracy: CLLocationAccuracy) {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = accuracy
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    override init() {
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
            case .authorizedWhenInUse: return "authorizedWhenInUse"
            case .authorizedAlways: return "authorizedAlways"
            case .denied: return "denied"
            case .notDetermined: return "notDetermined"
            case .restricted: return "restricted"
            default: return "unknown"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.degrees = -1 * newHeading.magneticHeading
    }
}
