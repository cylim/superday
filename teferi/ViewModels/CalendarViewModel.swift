import Foundation
import RxSwift

///ViewModel for the CalendardViewModel.
class CalendarViewModel
{
    //MARK: Fields
    private let timeSlotService : TimeSlotService
    private var selectedDateService : SelectedDateService
    
    private let currentVisibleCalendarDateVariable = Variable(Date())
    
    var selectedDate : Date
    {
        get { return self.selectedDateService.currentlySelectedDate }
        set(value) { self.selectedDateService.currentlySelectedDate = value }
    }
    
    let minValidDate : Date
    var maxValidDate : Date { return Date() }
    
    let currentVisibleCalendarDateObservable : Observable<Date>
    
    var dateObservable : Observable<Date> { return self.selectedDateService.currentlySelectedDateObservable }
    
    var currentVisibleCalendarDate : Date
    {
        get { return self.currentVisibleCalendarDateVariable.value }
        set(value) { self.currentVisibleCalendarDateVariable.value = value }
    }
    
    init(settingsService: SettingsService,
         timeSlotService: TimeSlotService,
         selectedDateService: SelectedDateService)
    {
        self.timeSlotService = timeSlotService
        self.selectedDateService = selectedDateService
        
        self.minValidDate = settingsService.installDate ?? Date()
        
        self.currentVisibleCalendarDateObservable = self.currentVisibleCalendarDateVariable.asObservable()
    }
    
    func canScroll(toDate date: Date) -> Bool
    {
        let cellDate = date.ignoreTimeComponents()
        let minDate = self.minValidDate.ignoreTimeComponents()
        let maxDate = self.maxValidDate.ignoreTimeComponents()
        
        let dateIsWithinInterval = minDate...maxDate ~= cellDate
        return dateIsWithinInterval
    }
    
    func getActivities(forDate date: Date) -> [Activity]?
    {
        guard self.canScroll(toDate: date) else { return nil }
        
        let result =
            self.timeSlotService
                .getTimeSlots(forDay: date)
                .filter(categoryIsSet)
                .groupBy(category)
                .map(toActivity)
                .sorted(by: category)
        
        return result
    }
    
    private func categoryIsSet(for timeSlot: TimeSlot) -> Bool
    {
        return timeSlot.category != .unknown
    }
    
    private func category(of timeSlot: TimeSlot) -> Category
    {
        return timeSlot.category
    }
    
    private func toActivity(_ timeSlots: [TimeSlot]) -> Activity
    {
        let totalTime =
            timeSlots
                .map(toDuration)
                .reduce(0, +)
        
        return Activity(category: timeSlots.first!.category, duration: totalTime)
    }
    
    private func toDuration(_ timeSlot: TimeSlot) -> TimeInterval
    {
        return timeSlot.duration
    }
    
    private func category(_ element1: Activity, _ element2: Activity) -> Bool
    {
        let index1 = Constants.categories.index(of: element1.category)!
        let index2 = Constants.categories.index(of: element2.category)!
        
        return index1 > index2
    }
}
