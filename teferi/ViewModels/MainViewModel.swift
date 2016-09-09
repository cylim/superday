import Foundation
import RxSwift

class MainViewModel
{
    // MARK: Fields
    private let superday = "Superday"
    private let superyesterday = "Superyesterday"
    private let locationService : LocationService
    private let currentLocation : Variable<Location> = Variable(Location(latitude: 0, longitude: 0))
    
    // MARK: Properties
    var date = NSDate()
    let locationObservable : Observable<Location>
    
    var title : String
    {
        let today = NSDate()
        let yesterday = today.addDays(-1)
        
        if date.equalsDate(today)
        {
            return superday.translate()
        }
        else if date.equalsDate(yesterday)
        {
            return superyesterday.translate()
        }
        
        let dayOfMonthFormatter = NSDateFormatter();
        dayOfMonthFormatter.timeZone = NSTimeZone.localTimeZone();
        dayOfMonthFormatter.dateFormat = "dd MMMM";
        
        return dayOfMonthFormatter.stringFromDate(date)
    }
    
    // MARK: Initializers
    init(locationService : LocationService)
    {
        self.locationService = locationService
        self.locationObservable = currentLocation.asObservable()
    }
    
    // MARK: Methods
    func start()
    {
        locationService.subscribeToLocationChanges(onLocation)
    }
    
    func onLocation(location: Location)
    {
        currentLocation.value = location
    }
}