import Foundation
import CoreLocation
import RxSwift
@testable import teferi

class MockLocationService : LocationService
{
    //MARK: Fields
    private var locationVariable = Variable(CLLocation())
    
    //MARK: Properties
    private(set) var locationStarted = false
    
    //MARK: LocationService implementation
    var isInBackground : Bool = false
    
    func startLocationTracking()
    {
        self.locationStarted = true
    }
    
    func stopLocationTracking()
    {
        self.locationStarted = false
    }
    
    var locationObservable : Observable<CLLocation> { return locationVariable.asObservable() }
    
    //MARK: Methods
    func setMockLocation(_ location: CLLocation)
    {
        self.locationVariable.value = location
    }
}
