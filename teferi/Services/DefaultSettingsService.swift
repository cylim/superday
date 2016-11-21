import CoreData
import UIKit
import CoreLocation

class DefaultSettingsService : SettingsService
{
    //MARK: Fields
    private let installDateKey = "installDate"
    private let lastLocationDateKey = "lastLocationDate"
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
    
    var lastLocationDate : Date?
    {
        return UserDefaults.standard.object(forKey: self.lastLocationDateKey) as! Date?
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
    
    func setLastLocationDate(_ date: Date)
    {
        UserDefaults.standard.set(date, forKey: self.lastLocationDateKey)
    }
    
    func setLastAskedForLocationPermission(_ date: Date)
    {
        UserDefaults.standard.set(date, forKey: self.lastAskedForLocationPermissionKey)
    }
    
    func setAllowedLocationPermission()
    {
        UserDefaults.standard.set(true, forKey: self.canIgnoreLocationPermissionKey)
    }
}
