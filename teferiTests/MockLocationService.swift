import Foundation
@testable import teferi

class MockLocationService : LocationService
{
    private var onLocation : (Location -> ())! = nil
    private(set) var didSubscribe = false
    
    func subscribeToLocationChanges(onLocationCallback: Location -> ())
    {
        onLocation = onLocationCallback
        didSubscribe = true
    }
    
    func setMockLocation(location: Location)
    {
        onLocation!(location)
    }
    
    
}