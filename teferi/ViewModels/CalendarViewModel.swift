import Foundation
import RxSwift

///ViewModel for the CalendardViewModel.
class CalendardViewModel
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
    
    func getTimeSlots(date: Date) -> [TimeSlot]
    {
        return self.timeSlotService.getTimeSlots(forDay: date)
    }
}
