import CoreLocation

protocol TrackingService
{
    /**
     Called when the user's location changes.
     
     - Parameter location: contains the user's current location.
     */
    func onNewLocation(_ location: CLLocation)
}
