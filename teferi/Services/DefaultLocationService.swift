import Foundation
import UIKit
import CoreLocation
import CoreMotion

///Default implementation for the location service.
class DefaultLocationService : NSObject, CLLocationManagerDelegate, LocationService
{
    //MARK: Fields
    private let loggingService : LoggingService
    
    ///Distance the user has to travel in order to trigger a new location event
    private let distanceFilter = 100.0
    
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
                loggingService.log(withLogLevel: .info, message: "App is now on Background")
                locationManager.requestAlwaysAuthorization()
            }
            else
            {
                loggingService.log(withLogLevel: .info, message: "App is now on Foreground")
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    //MARK: Initializers
    init(loggingService: LoggingService)
    {
        self.loggingService = loggingService
        
        super.init()
        
        locationManager.delegate = self
        locationManager.distanceFilter = distanceFilter
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
        locationManager.pausesLocationUpdatesAutomatically = true
        
        loggingService.log(withLogLevel: .verbose, message: "DefaultLocationService Initialized")
    }
    
    //MARK: LocationService implementation
    func startLocationTracking()
    {
        loggingService.log(withLogLevel: .debug, message: "DefaultLocationService started")
        
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
        loggingService.log(withLogLevel: .debug, message: "DefaultLocationService stoped")
        
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
        loggingService.log(withLogLevel: .verbose, message: "Subscribing to DefaultLocationService")
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
        guard location.coordinate.latitude != 0.0 && location.coordinate.latitude != 0.0 else
        {
            loggingService.log(withLogLevel: .debug, message: "Received an invalid location")
            return false
        }
                
        //Location is accurate enough
        guard 0 ... 2000 ~= location.horizontalAccuracy else
        {
            loggingService.log(withLogLevel: .debug, message: "Received an inaccurate location")
            return false
        }
        
        return true
    }
}
