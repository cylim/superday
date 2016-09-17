import Foundation

protocol PersistencyService
{
    func getLastTimeSlot() -> TimeSlot
    
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    
    func addNewTimeSlot(_ timeSlot: TimeSlot) -> Bool
    
    func subscribeToTimeSlotChanges(_ callback: @escaping (TimeSlot) -> ())
}
