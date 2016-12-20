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
        
        let result = minDate...maxDate ~= cellDate
        return result
    }
    
    // Categories order: Commute, Food, Friends, Work and Leisure
    func getCategoriesSlots(forDate date: Date) -> [CategoryDuration]?
    {
        guard self.canScroll(toDate: date) else { return nil }
        
        let result =
            self.timeSlotService
                .getTimeSlots(forDay: date)
                .filter(self.filterInvalidTimeSlots)
                .groupBy(self.groupByCategory)
                .map(self.mapIntoTimeInterval)
                .sorted(by: self.sortByCategory)
        
        return result
    }
    
    func getAttributedHeaderName(date: Date) -> NSMutableAttributedString
    {
        let monthName = DateFormatter().monthSymbols[(date.month-1) % 12] //GetHumanDate(month: month)
        let myAttribute = [ NSForegroundColorAttributeName: UIColor.black ]
        let myString = NSMutableAttributedString(string: "\(monthName) ", attributes: myAttribute )
        let attrString = NSAttributedString(string: String(date.year), attributes: [NSForegroundColorAttributeName: Color.offBlackTransparent])
        myString.append(attrString)
        return myString
    }
    
    private func filterInvalidTimeSlots(_ timeSlot: TimeSlot) -> Bool
    {
        return timeSlot.category != .unknown
    }
    
    private func groupByCategory(_ timeSlot: TimeSlot) -> Category
    {
        return timeSlot.category
    }
    
    private func mapIntoTimeInterval(_ timeSlots: [TimeSlot]) -> CategoryDuration
    {
        let totalTime =
            timeSlots
                .map(self.mapIntoDuration)
                .reduce(0, +)
        
        return CategoryDuration(category: timeSlots.first!.category, duration: totalTime)
    }
    
    private func mapIntoDuration(_ timeSlot: TimeSlot) -> TimeInterval
    {
        return timeSlot.duration
    }
    
    private func sortByCategory(_ element1: CategoryDuration, _ element2: CategoryDuration) -> Bool
    {
        let index1 = Constants.categories.index(of: element1.category)!
        let index2 = Constants.categories.index(of: element2.category)!
        
        return index1 > index2
    }
}

struct CategoryDuration
{
    let category : Category
    let duration : TimeInterval
}
