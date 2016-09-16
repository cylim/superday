import Foundation

protocol PersistencyService
{
    func addNewTimeSlot(_ timeSlot: TimeSlot) -> Bool
    
    func getTimeSlotsForDay(_ date: Date) -> [TimeSlot]
}
