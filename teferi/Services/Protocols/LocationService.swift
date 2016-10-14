import CoreLocation
import RxSwift

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
     Observable that emits events when new locations are received.
     */
    var locationObservable : Observable<CLLocation> { get }
}
