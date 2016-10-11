import Foundation
@testable import teferi

class MockPersistencyService : PersistencyService
{
    //MARK: Fields
    private var newTimeSlotCallbacks = [(TimeSlot) -> ()]()
    
    //MARK: Properties
    private(set) var timeSlots = [TimeSlot]()
    var didSubscribe : Bool
    {
        return newTimeSlotCallbacks.count > 0
    }
    
    //PersistencyService implementation
    func getLastTimeSlot() -> TimeSlot
    {
        return timeSlots.last!
    }
    
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    {
        let startDate = day.ignoreTimeComponents()
        let endDate = day.tomorrow.ignoreTimeComponents()
        
        return timeSlots.filter { t in t.startTime > startDate && t.startTime < endDate }
    }
    
    @discardableResult func addNewTimeSlot(_ timeSlot: TimeSlot) -> Bool
    {
        if let lastTimeSlot = timeSlots.last
        {
            lastTimeSlot.endTime = Date()
        }
        
        timeSlots.append(timeSlot)
        newTimeSlotCallbacks.forEach { callback in callback(timeSlot) }
        
        return true
    }
    
    @discardableResult func updateTimeSlot(_ timeSlot: TimeSlot, withCategory category: teferi.Category) -> Bool
    {
        timeSlot.category = category
        return true
    }
    
    func subscribeToTimeSlotChanges(_ callback: @escaping (TimeSlot) -> ())
    {
        newTimeSlotCallbacks.append(callback)
    }
}
