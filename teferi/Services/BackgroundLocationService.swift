import Foundation
import UIKit
import CoreLocation
import CoreMotion
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class BackgroundLocationService : NSObject, CLLocationManagerDelegate, LocationService
{
    fileprivate let distanceFilter = 100.0
    fileprivate var onLocationCallbacks = [(CLLocation) -> ()]()
    fileprivate let locationManager = CLLocationManager()
    fileprivate var timer: Timer? = nil
    
    override init()
    {
        super.init()
        
        locationManager.delegate = self
        locationManager.distanceFilter = distanceFilter
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
        
        if Double(UIDevice.current.systemVersion) >= 8.0
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
    
    func subscribeToLocationChanges(_ onLocationCallback: @escaping (CLLocation) -> ())
    {
        onLocationCallbacks.append(onLocationCallback)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let lastLocation = locations.filter(filterLocations).last else { return }
        
        //Notifies new location to listeners
        onLocationCallbacks.forEach { callback in callback(lastLocation) }
    }
    
    fileprivate func filterLocations(_ location: CLLocation) -> Bool
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
