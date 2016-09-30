import Foundation

class PagerViewModel
{
    //MARK: Fields
    private let settingsService : SettingsService
    
    init(settingsService: SettingsService)
    {
        self.settingsService = settingsService
    }
    
    func canScroll(toDate date: Date) -> Bool
    {
        let minDate = settingsService.installDate!.ignoreTimeComponents()
        let maxDate = Date().ignoreTimeComponents()
        let dateWithNoTime = date.ignoreTimeComponents()
        
        guard dateWithNoTime >= minDate  && dateWithNoTime <= maxDate else { return false }
        
        return true
    }
}
