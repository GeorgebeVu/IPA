//
//  LocationManager.swift
//  Test
//
//  Created by George Vu on 10/15/24.
//

import CoreLocation
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()

    @Published var userLocation = LocationData()
    @Published var userLocationDescription: String = ""
    
    private var hasSentLocation = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 500
    }

    func requestLocationAccess() {
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .denied || status == .restricted {
            print("Location access denied or restricted. Please enable it in settings.")
        } else {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            performReverseGeocoding(for: location)
        }
    }

    func performReverseGeocoding(for location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("Reverse geocoding failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""

            DispatchQueue.main.async {
                self.userLocation.city = city
                self.userLocation.state = state

                print("Location updated: city = \(self.userLocation.city), state = \(self.userLocation.state)")

                if !self.hasSentLocation {
                    self.hasSentLocation = true
                    self.stopUpdatingLocation()
                }
            }
        }
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        print("Stopped location updates to prevent further triggers.")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
