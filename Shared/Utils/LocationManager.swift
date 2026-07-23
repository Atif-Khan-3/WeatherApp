//
//  LocationManager.swift
//  SecondWeather
//
//  Created by Atif Khan  on 14/07/2026.
//


import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject,ObservableObject {
    
    static let shared = LocationManager()
    private var continuation: CheckedContinuation<Void, Error>?
    let manager = CLLocationManager()
    @Published var location:CLLocation? = nil
    var latitude: String = ""
    var longitude: String = ""
    
    override init() {
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.distanceFilter = kCLDistanceFilterNone
        self.manager.requestWhenInUseAuthorization()
       
    }
    
    func getLocation() async throws {
           try await withCheckedThrowingContinuation { continuation in
               self.continuation = continuation
               manager.requestLocation()
           }
       }
   
    
}
extension LocationManager:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        latitude = "\(location.coordinate.latitude)"
        longitude = "\(location.coordinate.longitude)"
        self.location = location
        print("lat\(latitude)")
        print("long\(longitude)")
        continuation?.resume()
        continuation = nil
       
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
}
