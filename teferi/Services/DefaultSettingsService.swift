import CoreData
import UIKit
import CoreLocation

class DefaultSettingsService : SettingsService
{
    //MARK: Fields
    private let installDateKey = "installDate"
    private let lastLocationDateKey = "lastLocationDate"
    
    //MARK: Properties
    var installDate : Date?
    {
        return UserDefaults.standard.object(forKey: installDateKey) as! Date?
    }
    
    var lastLocationDate : Date?
    {
        return UserDefaults.standard.object(forKey: lastLocationDateKey) as! Date?
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
    
    //MARK: Methods
    func setInstallDate(_ date: Date)
    {
        guard installDate == nil else { return }
        
        UserDefaults.standard.set(date, forKey: installDateKey)
    }
    
    func setLastLocationDate(_ date: Date)
    {
        UserDefaults.standard.set(date, forKey: lastLocationDateKey)
    }
}
