@testable import teferi
import Foundation

class MockPersistencyService : PersistencyService
{
    var timeSlots = [TimeSlot]()
    
    func createTimeSlot(_ timeSlot: TimeSlot) -> Bool
    {
        timeSlots.append(timeSlot)
        return true
    }
    
    func updateTimeSlot(_ timeSlot: TimeSlot) -> Bool
    {
        if let index = timeSlots.index(where: { t in t === timeSlot })
        {
            timeSlots.remove(at: index)
            timeSlots.append(timeSlot)
            
            return true
        }
        
        return false
    }
    
    func getTimeSlotsForDay(_ date: Date) -> [TimeSlot]
    {
        let startDate = date.ignoreTimeComponents()
        let endDate = date.addDays(1).ignoreTimeComponents()
        
        return timeSlots.filter { t in t.startTime.compare(startDate) == ComparisonResult.orderedDescending && t.startTime.compare(endDate) == ComparisonResult.orderedAscending   }
    }
}
