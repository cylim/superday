import Foundation

protocol PersistencyService
{
    func createTimeSlot(timeSlot: TimeSlot) -> Bool
    
    func updateTimeSlot(timeSlot: TimeSlot) -> Bool
    
    func getTimeSlotsForDay(date: NSDate) -> [TimeSlot]
}