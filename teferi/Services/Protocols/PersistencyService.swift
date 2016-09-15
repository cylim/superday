import Foundation

protocol PersistencyService
{
    func addNewTimeSlot(timeSlot: TimeSlot) -> Bool
    
    func getTimeSlotsForDay(date: NSDate) -> [TimeSlot]
}