import Foundation
import UIKit
import CoreLocation
import CoreMotion
import UIKit

class DefaultLocationService : NSObject, CLLocationManagerDelegate, LocationService
{

    typealias LocationServiceCallback = (CLLocation) -> ()
    
    fileprivate let distanceFilter = 100.0
    fileprivate var onLocationCallbacks = [LocationServiceCallback]()
    fileprivate let locationManager = CLLocationManager()
    fileprivate var timer : Timer? = nil
    
    override init()
    {
        super.init()
        
        locationManager.delegate = self
        locationManager.distanceFilter = distanceFilter
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
        locationManager.pausesLocationUpdatesAutomatically = true
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    func startLocationTracking()
    {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationTracking()
    {
        locationManager.stopUpdatingLocation()
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
        
        if timer != nil && timer!.isValid { return }
        
        //Schedules tracking to restart in 1 minute
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(startLocationTracking), userInfo: nil, repeats: false)
        
        //Stops tracker after 10 seconds
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(stopLocationTracking), userInfo: nil, repeats: false);
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
