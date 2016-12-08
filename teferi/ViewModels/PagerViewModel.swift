import RxSwift
import Foundation

class PagerViewModel
{
    //MARK: Fields
    private let settingsService : SettingsService
    private var selectedDateService : SelectedDateService
    
    init(settingsService: SettingsService, selectedDateService: SelectedDateService)
    {
        self.settingsService = settingsService
        self.selectedDateService = selectedDateService
    }
    
    //MARK: Properties
    private(set) lazy var dateObservable : Observable<Date> =
    {
        return self.selectedDateService
            .currentlySelectedDateObservable
            .filter(self.dateIsDifferentFromCurrent)
    }()
    
    private var selectedDate = Date()
    var currentlySelectedDate : Date
    {
        get { return self.selectedDate }
        set(value)
        {
            self.selectedDate = value
            self.selectedDateService.currentlySelectedDate = value
        }
    }
    
    //Methods
    func canScroll(toDate date: Date) -> Bool
    {
        let minDate = self.settingsService.installDate!.ignoreTimeComponents()
        let maxDate = Date().ignoreTimeComponents()
        let dateWithNoTime = date.ignoreTimeComponents()
        
        return dateWithNoTime >= minDate && dateWithNoTime <= maxDate
    }
    
    private func dateIsDifferentFromCurrent(_ date: Date) -> Bool
    {
        if date != self.currentlySelectedDate
        {
            self.selectedDate = date
            return true
        }
        
        return false
    }
}
