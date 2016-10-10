import Foundation

protocol SettingsService
{
    ///Indicates the date the app was ran for the first time
    var installDate : Date? { get }
    
    var lastLocationDate : Date? { get }
    
    func setInstallDate(_ date: Date)
    
    func setLastLocationDate(_ date: Date)
}
