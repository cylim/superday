import Foundation
import UIKit
import CoreLocation
import CoreMotion
import UIKit

///Default implementation for the location service.
class DefaultLocationService : NSObject, CLLocationManagerDelegate, LocationService
{
    //MARK: Fields
    
    ///The location manager itself
    private let locationManager = CLLocationManager()
    
    /// Timer that allows the location service to pause and save battery
    private var timer : Timer? = nil
    
    /// Callbacks that get called when a new location is available
    private var onLocationCallbacks = [(CLLocation) -> ()]()
    
    //MARK: Properties
    var isInBackground : Bool = false
    {
        didSet
        {
            if isInBackground
            {
                locationManager.requestAlwaysAuthorization()
            }
            else
            {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    //MARK: Initializers
    override init()
    {
        super.init()
        
        locationManager.delegate = self
        locationManager.distanceFilter = Constants.distanceFilter
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
        
        //TODO: We might need to disable this if we are getting poor location results...
        locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    //MARK: LocationService implementation
    func startLocationTracking()
    {
        if isInBackground
        {
            locationManager.startUpdatingLocation()
        }
        else
        {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func stopLocationTracking()
    {
        if isInBackground
        {
            locationManager.startUpdatingLocation()
        }
        else
        {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    func subscribeToLocationChanges(_ onLocationCallback: @escaping (CLLocation) -> ())
    {
        onLocationCallbacks.append(onLocationCallback)
    }
    
    //MARK: CLLocationManagerDelegate Implementation
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
    
    //MARK: Methods
    private func filterLocations(_ location: CLLocation) -> Bool
    {
        //Location is valid
        guard location.coordinate.latitude != 0.0 && location.coordinate.latitude != 0.0 else { return false }
                
        //Location is accurate enough
        guard 0 ... 2000 ~= location.horizontalAccuracy else { return false }
        
        return true
    }
}
