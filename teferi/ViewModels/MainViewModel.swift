import Foundation
import RxSwift

class MainViewModel
{
    private let locationService : LocationService
    var currentLocation : Variable<Location> = Variable(Location(latitude: 0, longitude: 0))
    
    init(locationService : LocationService)
    {
        self.locationService = locationService
    }
    
    func start()
    {
        locationService.subscribeToLocationChanges(onLocation)
    }
    
    func onLocation(location: Location)
    {
        currentLocation.value = location
    }
}