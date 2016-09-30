import CoreData

class DefaultSettingsService : SettingsService
{
    //MARK: Fields
    private let installDateKey = "installDate"
    
    private(set)  var installDate : Date?
    
    init()
    {
        installDate = UserDefaults.standard.object(forKey: installDateKey) as! Date?
    }
    
    func setInstallDate(date: Date)
    {
        guard installDate == nil else { return }
        
        UserDefaults.standard.set(date, forKey: installDateKey)
        installDate = date
    }
}
