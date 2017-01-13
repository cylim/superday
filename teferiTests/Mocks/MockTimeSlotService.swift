import Foundation
import RxSwift
@testable import teferi

class MockTimeSlotService : TimeSlotService
{
    //MARK: Fields
    private let timeSlotCreatedVariable = Variable(TimeSlot(withStartTime: Date(), categoryWasSetByUser: false))
    private let timeSlotUpdatedVariable = Variable(TimeSlot(withStartTime: Date(), categoryWasSetByUser: false))
    
    //MARK: Properties
    private(set) var timeSlots = [TimeSlot]()
    private(set) var getLastTimeSlotWasCalled = false
    
    init()
    {
        self._timeSlotCreatedObservable = timeSlotCreatedVariable.asObservable().skip(1)
        self.timeSlotUpdatedObservable = timeSlotUpdatedVariable.asObservable().skip(1)
    }
    
    // MARK: Properties
    private let _timeSlotCreatedObservable : Observable<TimeSlot>
    var timeSlotCreatedObservable : Observable<TimeSlot>
    {
        self.didSubscribe = true
        return _timeSlotCreatedObservable
    }

    let timeSlotUpdatedObservable : Observable<TimeSlot>
    var didSubscribe = false
    
    //PersistencyService implementation
    func getLast() -> TimeSlot?
    {
        self.getLastTimeSlotWasCalled = true
        return timeSlots.last
    }
    
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    {
        let startDate = day.ignoreTimeComponents()
        let endDate = day.tomorrow.ignoreTimeComponents()
        
        return self.timeSlots.filter { t in t.startTime > startDate && t.startTime < endDate }
    }
    
    @discardableResult func add(timeSlot: TimeSlot)
    {
        if let lastTimeSlot = timeSlots.last
        {
            lastTimeSlot.endTime = timeSlot.startTime
        }
        
        self.timeSlots.append(timeSlot)
        self.timeSlotCreatedVariable.value = timeSlot
    }
    
    @discardableResult func update(timeSlot: TimeSlot, withCategory category: teferi.Category, setByUser: Bool)
    {
        timeSlot.category = category
        timeSlot.categoryWasSetByUser = setByUser
        self.timeSlotUpdatedVariable.value = timeSlot
    }
}
