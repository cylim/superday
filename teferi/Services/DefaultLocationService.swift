import Foundation
import UIKit
import CoreLocation
import CoreMotion

///Default implementation for the location service.
class DefaultLocationService : NSObject, CLLocationManagerDelegate, LocationService
{
    //MARK: Fields
    private let loggingService : LoggingService
    
    ///The location manager itself
    private let locationManager = CLLocationManager()
    
    /// Timer that allows the location service to pause and save battery
    private var timer : Timer? = nil
    
    /// Callbacks that get called when a new location is available
    private var onLocationCallbacks = [(CLLocation) -> ()]()
    
    // for logging date/time of received location updates
    private let dateTimeFormatter = DateFormatter()
    
    //MARK: Properties
    var isInBackground : Bool = false
    {
        didSet
        {
            if isInBackground
            {
                loggingService.log(withLogLevel: .info, message: "App is now in Background")
            }
            else
            {
                loggingService.log(withLogLevel: .info, message: "App is now in Foreground")
                locationManager.requestAlwaysAuthorization()
            }
        }
    }
    
    //MARK: Initializers
    init(loggingService: LoggingService)
    {
        self.loggingService = loggingService
        
        super.init()
        
        locationManager.delegate = self
        locationManager.distanceFilter = Constants.distanceFilter
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
        
        //TODO: We might need to disable this if we are getting poor location results...
        locationManager.pausesLocationUpdatesAutomatically = true
        
        dateTimeFormatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        
        loggingService.log(withLogLevel: .verbose, message: "DefaultLocationService Initialized")
    }
    
    //MARK: LocationService implementation
    func startLocationTracking()
    {
        loggingService.log(withLogLevel: .debug, message: "DefaultLocationService started")
        
        if !isInBackground
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
        
        if !isInBackground
        {
            locationManager.stopUpdatingLocation()
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
            logLocationUpdate(location, "Received an invalid location")
            return false
        }
                
        //Location is accurate enough
        guard 0 ... 2000 ~= location.horizontalAccuracy else
        {
            logLocationUpdate(location, "Received an inaccurate location")
            return false
        }
        
        logLocationUpdate(location, "Received a valid location")
        return true
    }
    
    private func logLocationUpdate(_ location: CLLocation, _ message: String)
    {
        let text = "\(message) <\(location.coordinate.latitude),\(location.coordinate.longitude)>"
                 + " ~\(max(location.horizontalAccuracy, location.verticalAccuracy))m"
                 + " (speed: \(location.speed)m/s course: \(location.course))"
                 + " at \(dateTimeFormatter.string(from: location.timestamp))"
        
        loggingService.log(withLogLevel: .debug, message: text)
    }
}
