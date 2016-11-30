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
    private let shouldHideVariable = Variable(false)
    private let selectedDateVariable = Variable(Date())
    
    var selectedDate : Date
    {
        get { return self.selectedDateVariable.value }
        set(value) { self.selectedDateVariable.value = value }
    }
    var shouldHide : Bool
    {
        get { return self.shouldHideVariable.value }
        set(value) { self.shouldHideVariable.value = value }
    }
    let dateObservable : Observable<Date>
    let shouldHideObservable : Observable<Bool>
    
    init(timeSlotService: TimeSlotService)
    {
        self.timeSlotService = timeSlotService
        self.dateObservable = self.selectedDateVariable.asObservable()
        self.shouldHideObservable = self.shouldHideVariable.asObservable()
    }
    
    // Categories order: Commute, Food, Friends, Work and Leisure
    func getCategoriesSlots(date:Date) -> [CategorySlot]
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
}
