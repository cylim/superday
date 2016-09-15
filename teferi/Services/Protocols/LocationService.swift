import CoreLocation

protocol LocationService
{
    func startLocationTracking()
    
    func stopLocationTracking()
    
    func subscribeToLocationChanges(onLocationCallback: CLLocation -> ())
}