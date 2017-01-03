import CoreData
import Foundation

class DefaultTimeSlotService : TimeSlotService
{
    //MARK: Fields
    private let timeService : TimeService
    private let loggingService : LoggingService
    private let persistencyService : BasePersistencyService<TimeSlot>
    
    private var createCallbacks = [(TimeSlot) -> ()]()
    private var updateCallbacks = [(TimeSlot) -> ()]()
    
    init(timeService: TimeService,
         loggingService: LoggingService,
         persistencyService: BasePersistencyService<TimeSlot>)
    {
        self.timeService = timeService
        self.loggingService = loggingService
        self.persistencyService = persistencyService
    }
    
    func add(timeSlot: TimeSlot)
    {
        //The previous TimeSlot needs to be finished before a new one can start
        guard self.endPreviousTimeSlot(atDate: timeSlot.startTime) && self.persistencyService.create(timeSlot) else
        {
            self.loggingService.log(withLogLevel: .error, message: "Failed to create new TimeSlot")
            return
        }
        
        self.loggingService.log(withLogLevel: .info, message: "New TimeSlot with category \"\(timeSlot.category)\" created")
        
        self.createCallbacks.forEach { callback in callback(timeSlot) }
    }
    
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    {
        let startTime = day.ignoreTimeComponents() as NSDate
        let endTime = day.tomorrow.ignoreTimeComponents() as NSDate
        let predicate = Predicate(parameter: "startTime", rangesFromDate: startTime, toDate: endTime)
        
        let timeSlots = self.persistencyService.get(withPredicate: predicate)
        return timeSlots
    }
    
    func update(timeSlot: TimeSlot, withCategory category: Category, setByUser: Bool)
    {
        //No need to persist anything if the categories are the same
        guard timeSlot.category != category else { return }
        
        let predicate = Predicate(parameter: "startTime", equals: timeSlot.startTime as AnyObject)
        let editFunction = { (timeSlot: TimeSlot) -> (TimeSlot) in
            
            timeSlot.categoryWasSetByUser = setByUser
            timeSlot.category = category
            return timeSlot
        }
        
        if self.persistencyService.update(withPredicate: predicate, updateFunction: editFunction)
        {
            self.updateCallbacks.forEach { callback in callback(timeSlot) }
        }
        else
        {
            self.loggingService.log(withLogLevel: .error, message: "Error updating category of TimeSlot created on \(timeSlot.startTime) from \(timeSlot.category) to \(category)")
        }
    }
    
    func getLast() -> TimeSlot
    {
        return self.persistencyService.getLast() ?? TimeSlot(withStartTime: self.timeService.now,
                                                             categoryWasSetByUser: false)
    }
    
    func subscribeToTimeSlotChanges(on event: TimeSlotChangeType, _ callback: @escaping (TimeSlot) -> ())
    {
        switch event
        {
            case .create:
                self.createCallbacks.append(callback)
            case .update:
                self.updateCallbacks.append(callback)
        }
    }
    
    private func endPreviousTimeSlot(atDate date: Date) -> Bool
    {
        guard let timeSlot = self.persistencyService.getLast() else { return true }
        
        let startDate = timeSlot.startTime
        var endDate = date
        
        guard endDate > startDate else
        {
            self.loggingService.log(withLogLevel: .error, message: "Trying to create a negative duration TimeSlot")
            return false
        }
        
        //TimeSlot is going for over one day, we should end it at midnight
        if startDate.ignoreTimeComponents() != endDate.ignoreTimeComponents()
        {
            self.loggingService.log(withLogLevel: .debug, message: "Trying to create a negative duration TimeSlot")
            endDate = startDate.tomorrow.ignoreTimeComponents()
        }
        
        let predicate = Predicate(parameter: "startTime", equals: timeSlot.startTime as AnyObject)
        let editFunction = { (timeSlot: TimeSlot) -> TimeSlot in
            
            timeSlot.endTime = endDate
            return timeSlot
        }
        
        timeSlot.endTime = endDate
        
        guard self.persistencyService.update(withPredicate: predicate, updateFunction: editFunction) else
        {
            self.loggingService.log(withLogLevel: .error, message: "Failed to end TimeSlot started at \(timeSlot.startTime) with category \(timeSlot.category)")
            
            return false
        }
        
        return true
    }
}
