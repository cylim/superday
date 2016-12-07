import Foundation
import CoreLocation

protocol SettingsService
{
    //MARK: Properties
    var installDate : Date? { get }
    
    var lastLocation : CLLocation? { get }
    
    var hasLocationPermission : Bool { get }
    
    var lastAskedForLocationPermission : Date? { get }
    
    var canIgnoreLocationPermission : Bool { get }
    
    var hasNotificationPermission : Bool { get }
    
    var lastInactiveDate : Date?  { get }
    
    //MARK: Methods
    
    func setInstallDate(_ date: Date)
    
    func setLastInactiveDate(_ date: Date?)
    
    func setLastLocation(_ location: CLLocation)
    
    func setLastAskedForLocationPermission(_ date: Date)
    
    func setAllowedLocationPermission()
}
