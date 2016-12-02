import CoreData
import UIKit
import CoreLocation

class DefaultSettingsService : SettingsService
{
    //MARK: Fields
    private let installDateKey = "installDate"
    private let smartGuessIdKey = "smartGuessId"
    private let lastLocationKey = "lastLocation"
    private let lastInactiveDateKey = "lastInactiveDate"
    private let canIgnoreLocationPermissionKey = " canIgnoreLocationPermission"
    private let lastAskedForLocationPermissionKey = "lastAskedForLocationPermission"
    
    //MARK: Properties
    var installDate : Date?
    {
        return UserDefaults.standard.object(forKey: self.installDateKey) as! Date?
    }
    
     var lastInactiveDate : Date?
    {
        return UserDefaults.standard.object(forKey: self.lastInactiveDateKey) as? Date
    }
    
    var lastLocation : CLLocation?
    {
        return UserDefaults.standard.object(forKey: self.lastLocationKey) as! CLLocation?
    }
    
    var hasLocationPermission : Bool
    {
        guard CLLocationManager.locationServicesEnabled() else { return false }
        return CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    var hasNotificationPermission : Bool
    {
        let notificationSettings = UIApplication.shared.currentUserNotificationSettings
        return notificationSettings?.types.contains([.alert, .badge]) ?? false
    }
    
    var lastAskedForLocationPermission : Date?
    {
        return UserDefaults.standard.object(forKey: self.lastAskedForLocationPermissionKey) as! Date?
    }
    
    var canIgnoreLocationPermission : Bool
    {
        return UserDefaults.standard.bool(forKey: self.canIgnoreLocationPermissionKey)
    }
    
    //MARK: Methods
    func setInstallDate(_ date: Date)
    {
        guard self.installDate == nil else { return }
        
        UserDefaults.standard.set(date, forKey: self.installDateKey)
    }
    
    func setLastInactiveDate(_ date: Date?)
    {
        UserDefaults.standard.set(date, forKey: self.lastInactiveDateKey)
    }
    
    func setLastLocation(_ location: CLLocation)
    {
        UserDefaults.standard.set(location, forKey: self.lastLocationKey)
    }
    
    func setLastAskedForLocationPermission(_ date: Date)
    {
        UserDefaults.standard.set(date, forKey: self.lastAskedForLocationPermissionKey)
    }
    
    func setAllowedLocationPermission()
    {
        UserDefaults.standard.set(true, forKey: self.canIgnoreLocationPermissionKey)
    }
    
    func getNextSmartGuessId() -> Int
    {
        return UserDefaults.standard.integer(forKey: self.smartGuessIdKey)
    }
    
    func incrementSmartGuessId()
    {
        var id = self.getNextSmartGuessId()
        id += 1
        UserDefaults.standard.set(id, forKey: self.smartGuessIdKey)
    }
}
