@testable import teferi
import Foundation

class MockPersistencyService : PersistencyService
{
    var timeSlots = [TimeSlot]()
    
    func createTimeSlot(timeSlot: TimeSlot) -> Bool
    {
        timeSlots.append(timeSlot)
        return true
    }
    
    func updateTimeSlot(timeSlot: TimeSlot) -> Bool
    {
        if let index = timeSlots.indexOf({ t in t === timeSlot })
        {
            timeSlots.removeAtIndex(index)
            timeSlots.append(timeSlot)
            
            return true
        }
        
        return false
    }
    
    func getTimeSlotsForDay(date: NSDate) -> [TimeSlot]
    {
        let startDate = date.ignoreTimeComponents()
        let endDate = date.addDays(1).ignoreTimeComponents()
        
        return timeSlots.filter { t in t.startTime.compare(startDate) == NSComparisonResult.OrderedDescending && t.startTime.compare(endDate) == NSComparisonResult.OrderedAscending   }
    }
}