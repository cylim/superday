import Foundation
import RxSwift

struct CategorySlot
{
    var duration: TimeInterval
    var category: Category
}

///ViewModel for the CalendardViewModel.
class CalendarViewModel
{
    //MARK: Fields
    private let timeSlotService : TimeSlotService
    private var selectedDateService : SelectedDateService
    
    private let shouldHideVariable = Variable(false)
    private let currentVisibleCalendarDateVariable = Variable(Date())
    
    var selectedDate : Date
    {
        get { return self.selectedDateService.currentlySelectedDate }
        set(value) { self.selectedDateService.currentlySelectedDate = value }
    }
    
    var shouldHide : Bool
    {
        get { return self.shouldHideVariable.value }
        set(value) { self.shouldHideVariable.value = value }
    }
    
    let shouldHideObservable : Observable<Bool>
    var dateObservable : Observable<Date> { return self.selectedDateService.currentlySelectedDateObservable }
    let currentVisibleCalendarDateObservable : Observable<Date>
    
    let minValidDate : Date
    var maxValidDate : Date { return Date() }
    
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
        self.shouldHideObservable = self.shouldHideVariable.asObservable()
        
        self.currentVisibleCalendarDateObservable = self.currentVisibleCalendarDateVariable.asObservable()
    }
    
    // Categories order: Commute, Food, Friends, Work and Leisure
    func getCategoriesSlots(date: Date) -> [CategorySlot]
    {
        let timeSlots = self.timeSlotService.getTimeSlots(forDay: date)
        let activeTimeSlots = timeSlots.filter
            {
                $0.category != .unknown
        }
        let categoriesOrder: [Category] = [.commute, .food, .friends, .work, .leisure]
        var categoriesSlots:[CategorySlot] = []
        for category in categoriesOrder
        {
            let durationSum = activeTimeSlots.reduce(0.0)
            {
                if $1.category == category
                {
                    return $0 + $1.duration
                }
                return $0
            }
            if durationSum > 0
            {
                categoriesSlots.append(CategorySlot(duration: durationSum,
                                                    category: category)
                )
            }
        }
        return categoriesSlots
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
}
