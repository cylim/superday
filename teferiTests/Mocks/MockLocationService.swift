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
    var useNilOnLastKnownLocation = false
    
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
    
    func getLastKnownLocation() -> CLLocation?
    {
        return self.useNilOnLastKnownLocation ? nil : self.locationVariable.value
    }
    
    var locationObservable : Observable<CLLocation> { return locationVariable.asObservable() }
    
    //MARK: Methods
    func setMockLocation(_ location: CLLocation)
    {
        self.locationVariable.value = location
    }
}
