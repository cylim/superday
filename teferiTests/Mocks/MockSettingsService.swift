import Foundation
import CoreLocation
@testable import teferi

class MockSettingsService : SettingsService
{
    ///Indicates the date the app was ran for the first time
    var installDate : Date? = Date()
    var lastInactiveDate : Date? = nil
    var lastLocation : CLLocation? = nil
    var lastAskedForLocationPermission : Date? = nil
    
    var hasLocationPermission = true
    var hasNotificationPermission = true
    var canIgnoreLocationPermission = false
    
    func setAllowedLocationPermission()
    {
        self.canIgnoreLocationPermission = true
    }
    
    func setInstallDate(_ date: Date)
    {
        self.installDate = date
    }
    
    func setLastInactiveDate(_ date: Date?)
    {
        self.lastInactiveDate = date
    }
    
    func setLastLocation(_ location: CLLocation)
    {
        self.lastLocation = location
    }
    
    func setLastAskedForLocationPermission(_ date: Date)
    {
        self.lastAskedForLocationPermission = date
    }
}
