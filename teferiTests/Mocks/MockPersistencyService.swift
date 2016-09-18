@testable import teferi
import Foundation

class MockPersistencyService : PersistencyService
{
    //MARK: Fields
    private var newTimeSlotCallbacks = [(TimeSlot) -> ()]()
    
    //MARK: Properties
    private(set) var timeSlots = [TimeSlot]()
    
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
    
    func addNewTimeSlot(_ timeSlot: TimeSlot) -> Bool
    {
        if let lastTimeSlot = timeSlots.last
        {
            lastTimeSlot.endTime = Date()
        }
        
        timeSlots.append(timeSlot)
        newTimeSlotCallbacks.forEach { callback in callback(timeSlot) }
        
        return true
    }
    
    func subscribeToTimeSlotChanges(_ callback: @escaping (TimeSlot) -> ())
    {
        newTimeSlotCallbacks.append(callback)
    }
}
