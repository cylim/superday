import CoreLocation

protocol TrackingService
{
    /**
     Called when the user's location changes.
     
     - Parameter location: contains the user's current location.
     */
    func onLocation(_ location: CLLocation)
    
    /**
     Called when the app's state changes.
     
     - Parameter appState: the current app state.
     */
    func onAppState(_ appState: AppState)
}
