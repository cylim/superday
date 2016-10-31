import Foundation

protocol SettingsService
{
    ///Indicates the date the app was ran for the first time
    var installDate : Date? { get }
    
    var lastLocationDate : Date? { get }
    
    var lastAskedForLocationPermission : Date? { get }
    
    var hasLocationPermission : Bool { get }
    
    var canIgnoreLocationPermission : Bool { get }
    
    var hasNotificationPermission : Bool { get }
    
    var lastInactiveDate : Date?  { get }
    
    func setInstallDate(_ date: Date)
    
    func setLastInactiveDate(_ date: Date?)
    
    func setLastLocationDate(_ date: Date)
    
    func setLastAskedForLocationPermission(_ date: Date)
    
    func setAllowedLocationPermission()
}
