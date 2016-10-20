import Foundation
@testable import teferi

class MockSettingsService : SettingsService
{
    ///Indicates the date the app was ran for the first time
    var installDate : Date? = Date()
    var lastLocationDate : Date? = nil
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
    
    func setLastLocationDate(_ date: Date)
    {
        self.lastLocationDate = date
    }
    
    func setLastAskedForLocationPermission(_ date: Date)
    {
        self.lastAskedForLocationPermission = date
    }
}
