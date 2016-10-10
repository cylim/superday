import Foundation
@testable import teferi

class MockSettingsService : SettingsService
{
    ///Indicates the date the app was ran for the first time
    var installDate : Date? = Date()
    
    var lastLocationDate : Date? = Date()
    
    func setInstallDate(_ date: Date)
    {
        installDate = date
    }
    
    func setLastLocationDate(_ date: Date)
    {
        lastLocationDate = date
    }
}
