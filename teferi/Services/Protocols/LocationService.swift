import CoreLocation

protocol LocationService
{
    func startLocationTracking()
    
    func stopLocationTracking()
    
    func subscribeToLocationChanges(_ onLocationCallback: @escaping (CLLocation) -> ())
}
