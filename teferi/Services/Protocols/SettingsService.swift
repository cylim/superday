import Foundation

protocol SettingsService
{
    ///Indicates the date the app was ran for the first time
    var installDate : Date? { get }
    
    func setInstallDate(date: Date)
}
