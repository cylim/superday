import Foundation
@testable import teferi

class MockSettingsService : SettingsService
{
    ///Indicates the date the app was ran for the first time
    var installDate : Date? = Date()
    
    func setInstallDate(date: Date)
    {
        installDate = date
    }
}
