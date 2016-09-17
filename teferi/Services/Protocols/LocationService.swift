import CoreLocation

/// Responsible for tracking the users location.
protocol LocationService
{
    //MARK: Properties
    
    ///Indicates whether the app is running on background or not.
    var isInBackground : Bool { get set }
    
    //MARK: Methods
    
    ///Starts the tracking service.
    func startLocationTracking()
    
    ///Stops the tracking service.
    func stopLocationTracking()
    
    /**
     Adds a callback that gets called everytime a new location is received.
     
     - Parameter callback: The function that gets invoked.
     */
    func subscribeToLocationChanges(_ onLocationCallback: @escaping (CLLocation) -> ())
}
