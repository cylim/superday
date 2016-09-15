import Foundation
import UIKit
import CoreLocation
import CoreMotion
import UIKit

class BackgroundLocationService : NSObject, CLLocationManagerDelegate, LocationService
{
    typealias LocationServiceCallback = CLLocation -> ()
    
    private let distanceFilter = 100.0
    private var onLocationCallbacks = [LocationServiceCallback]()
    private let locationManager = CLLocationManager()
    private var timer: NSTimer? = nil
    
    override init()
    {
        super.init()
        
        locationManager.delegate = self
        locationManager.distanceFilter = distanceFilter
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .Other
        
        if Double(UIDevice.currentDevice().systemVersion) >= 8.0
        {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func startLocationTracking()
    {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopLocationTracking()
    {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func subscribeToLocationChanges(onLocationCallback: LocationServiceCallback)
    {
        onLocationCallbacks.append(onLocationCallback)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let lastLocation = locations.filter(filterLocations).last else { return }
        
        //Notifies new location to listeners
        onLocationCallbacks.forEach { callback in callback(lastLocation) }
    }
    
    private func filterLocations(location: CLLocation) -> Bool
    {
        //Location is valid
        guard location.coordinate.latitude != 0.0 && location.coordinate.latitude != 0.0 else { return false }
        
        //Location is up-to-date
        let locationAge = -location.timestamp.timeIntervalSinceNow
        guard locationAge > 30 else { return false }
        
        //Location is accurate enough
        guard 0 ... 2000 ~= location.horizontalAccuracy else { return false }
        
        return true
    }
}