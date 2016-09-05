import Foundation
import CoreLocation
import UIKit

protocol LocationService
{
    func subscribeToLocationChanges(onLocationCallback: Location -> ())
}

class DefaultLocationService : NSObject, CLLocationManagerDelegate, LocationService
{
    private var onLocationCallback : (Location -> ())! = nil
    private let locationManager = CLLocationManager()
    
    func subscribeToLocationChanges(onLocationCallback: Location -> ())
    {
        self.onLocationCallback = onLocationCallback
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if Double(UIDevice.currentDevice().systemVersion) >= 8.0
        {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let coordinates = locations[0].coordinate
        let location = Location(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        onLocationCallback?(location)
    }
}