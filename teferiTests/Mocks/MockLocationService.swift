import Foundation
@testable import teferi

class MockLocationService : LocationService
{
    fileprivate var onLocation : ((Location) -> ())! = nil
    fileprivate(set) var didSubscribe = false
    
    func subscribeToLocationChanges(_ onLocationCallback: (Location) -> ())
    {
        onLocation = onLocationCallback
        didSubscribe = true
    }
    
    func setMockLocation(_ location: Location)
    {
        onLocation!(location)
    }
}
