import CoreLocation
import CoreMotion

///Service that creates and updates TimeSlots
protocol TimeSlotService
{
    /**
     Adds a callback that gets called everytime a new TimeSlot is created.
     
     - Parameter callback: The function that gets invoked.
     */
    func subscribeToTimeSlotChanges(on event: TimeSlotChangeType, _ callback: @escaping (TimeSlot) -> ())
    
    /**
     Adds a new TimeSlot and ensures its validity.
     
     - Parameter timeSlot: The TimeSlot to be added.
     - Returns: The found TimeSlots for the day or an empty array if there are none.
     */
    func add(timeSlot: TimeSlot)
    
    /**
     Gets TimeSlots for any given day.
     
     - Parameter day: The day used for filtering the TimeSlots.
     - Returns: The found TimeSlots for the day or an empty array if there are none.
     */
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    
    /**
     Changes the category of an existing TimeSlot.
     
     - Parameter timeSlot: The TimeSlots to be updated.
     
     - Parameter category: The new category of the TimeSlot.
     
     - Parameter setByUser: Indicates if the user initiated the action that changed the TimeSlot.
     */
    func update(timeSlot: TimeSlot, withCategory category: Category, setByUser: Bool)
    
    /**
     Gets last registered TimeSlot.
     
     - Returns: The last saved TimeSlot.
     */
    func getLast() -> TimeSlot?
}
