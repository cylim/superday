import Foundation

class MainViewModel : BaseViewModel
{
    let locationService : LocationService
    var currentLocation : Location? = nil
    
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
        
    }
}