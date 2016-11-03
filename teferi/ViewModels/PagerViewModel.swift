import RxSwift
import Foundation

class PagerViewModel
{
    //MARK: Fields
    private let settingsService : SettingsService
    private let dateVariable = Variable(Date())
    
    init(settingsService: SettingsService)
    {
        self.settingsService = settingsService
        self.dateObservable = self.dateVariable.asObservable()
    }
    
    //MARK: Properties
    var date : Date
    {
        get { return self.dateVariable.value }
        set(value) { self.dateVariable.value = value }
    }
    
    let dateObservable : Observable<Date>
    
    //Methods
    func canScroll(toDate date: Date) -> Bool
    {
        let minDate = settingsService.installDate!.ignoreTimeComponents()
        let maxDate = Date().ignoreTimeComponents()
        let dateWithNoTime = date.ignoreTimeComponents()
        
        guard dateWithNoTime >= minDate  && dateWithNoTime <= maxDate else { return false }
        
        return true
    }
}
