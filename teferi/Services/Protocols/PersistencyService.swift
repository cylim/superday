import Foundation

///Service that persists data locally
protocol PersistencyService
{
    //MARK: Methods
    
    ///Returns the last TimeSlot created.
    func getLastTimeSlot() -> TimeSlot
    
    /**
     Get TimeSlots for any given day.
     
     - Parameter day: The day used for filtering the TimeSlots.
     
     - Returns: The found TimeSlots for the day or an empty array if there are none.
     */
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    
    /**
     Persists a new TimeSlot and ends the previous one.
     
     - Parameter timeSlot: The TimeSlots to be added.
     
     - Returns: A Bool indicating whether the operation suceeded or not.
     */
    @discardableResult func addNewTimeSlot(_ timeSlot: TimeSlot) -> Bool
    
    /**
     Changes the category of an existing TimeSlot.
     
     - Parameter timeSlot: The TimeSlots to be updated.
     
     - Parameter category: The new category of the TimeSlot.
     
     - Returns: A Bool indicating whether the operation suceeded or not.
     */
    @discardableResult func updateTimeSlot(_ timeSlot: TimeSlot, withCategory category: Category) -> Bool
    
    /**
     Adds a callback that gets called everytime a new TimeSlot is created.
     
     - Parameter callback: The function that gets invoked.
     */
    func subscribeToTimeSlotChanges(_ callback: @escaping (TimeSlot) -> ())
}
