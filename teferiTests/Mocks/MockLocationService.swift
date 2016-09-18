import Foundation
import CoreLocation
@testable import teferi

class MockLocationService : LocationService
{
    //MARK: Fields
    private var onLocationCallbacks = [(CLLocation) -> ()]()
    
    //MARK: Properties
    private(set) var locationStarted = false
    
    //MARK: LocationService implementation
    var isInBackground : Bool = false
    
    func startLocationTracking()
    {
        locationStarted = true
    }
    
    func stopLocationTracking()
    {
        locationStarted = false
    }
    
    func subscribeToLocationChanges(_ onLocationCallback: @escaping (CLLocation) -> ())
    {
        onLocationCallbacks.append(onLocationCallback)
    }
    
    //MARK: Methods
    func setMockLocation(_ location: CLLocation)
    {
        onLocationCallbacks.forEach { locationCallback in locationCallback(location) }
    }
}
