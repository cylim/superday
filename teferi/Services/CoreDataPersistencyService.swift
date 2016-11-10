import CoreData
import UIKit

///Implementation that uses CoreData to persist information on disk.
class CoreDataPersistencyService : PersistencyService
{
    //MARK: Fields
    private let timeSlotEntityName = "TimeSlot"
    private let loggingService : LoggingService
    private var callbacks = [(TimeSlot) -> ()]()
    
    //MARK: Initializers
    init(loggingService: LoggingService)
    {
        self.loggingService = loggingService
    }
    
    //MARK: PersistencyService implementation
    @discardableResult func addNewTimeSlot(_ timeSlot: TimeSlot) -> Bool
    {
        //The previous TimeSlot needs to be finished before a new one can start
        guard endPreviousTimeSlot(atDate: timeSlot.startTime) else { return false }
        
        //Gets the managed object from CoreData's context
        let managedContext = getManagedObjectContext()
        let entity =  NSEntityDescription.entity(forEntityName: timeSlotEntityName, in: managedContext)!
        let managedTimeSlot = NSManagedObject(entity: entity, insertInto: managedContext)
        
        //Sets the properties
        managedTimeSlot.setValue(timeSlot.startTime, forKey: "startTime")
        managedTimeSlot.setValue(timeSlot.endTime, forKey: "endTime")
        managedTimeSlot.setValue(timeSlot.category.rawValue, forKey: "category")
        
        do
        {
            try managedContext.save()
            callbacks.forEach { callback in callback(timeSlot) }
            
            loggingService.log(withLogLevel: .info, message: "New TimeSlot with category \"\(timeSlot.category)\" created")
            return true
        }
        catch
        {
            loggingService.log(withLogLevel: .error, message: "Failed to create new TimeSlot")
            return false
        }
    }
    
    func getTimeSlots(forDay date: Date) -> [TimeSlot]
    {
        let startTime = date.ignoreTimeComponents()
        let endTime = date.tomorrow.ignoreTimeComponents()
        
        //Filter in order to get only the TimeSlots for said date
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: timeSlotEntityName)
        fetchRequest.predicate = NSPredicate(format: "(startTime >= %@) AND (startTime <= %@)", startTime as NSDate, endTime as NSDate)
        
        do
        {
            let results = try getManagedObjectContext().fetch(fetchRequest) as! [NSManagedObject]
            
            let timeSlots = results.map(mapManagedObjectToTimeSlot)
            loggingService.log(withLogLevel: .info, message: "\(timeSlots.count) TimeSlots found")
            return timeSlots
        }
        catch
        {
            //Returns an empty array if anything goes wrong
            loggingService.log(withLogLevel: .warning, message: "No TimeSlots found, return empty array")
            return []
        }
    }
    
    func getTimeSlots(last numberOfTimeSlots: Int = 1, forDay day: Date = Date()) -> [TimeSlot] {
        guard let managedTimeSlot = getLastNManagedTimeSlot(numberOfTimeSlots) else { return [TimeSlot()] }
        
        var timeSlotsToReturn = [TimeSlot]()
        for mangedObject in managedTimeSlot {
            timeSlotsToReturn.append(mapManagedObjectToTimeSlot(mangedObject as! NSManagedObject))
        }
        return timeSlotsToReturn
    }
    
    func getLastTimeSlot() -> TimeSlot
    {
        guard let timeSlot = getTimeSlots().first else { return TimeSlot() }
        
        return timeSlot
    }
    
    @discardableResult func updateTimeSlot(_ timeSlot: TimeSlot, withCategory category: Category) -> Bool
    {
        //No need to persist anything if the categories are the same
        guard timeSlot.category != category else { return true }
        
        
        let managedContext = getManagedObjectContext()
        let entity = NSEntityDescription.entity(forEntityName: timeSlotEntityName, in: managedContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        let predicate = NSPredicate(format: "startTime == %@", timeSlot.startTime as CVarArg)
        
        request.entity = entity
        request.predicate = predicate
        
        do
        {
            guard let managedTimeSlot = try managedContext.fetch(request).first as AnyObject? else { return false }
            managedTimeSlot.setValue(category.rawValue, forKey: "category")
            
            try managedContext.save()
            
            return true
        }
        catch
        {
            loggingService.log(withLogLevel: .warning, message: "No TimeSlot found when trying to update")
            return false
        }
    }
    
    func subscribeToTimeSlotChanges(_ callback: @escaping (TimeSlot) -> ())
    {
        callbacks.append(callback)
    }
    
    //MARK: Methods
    private func getManagedObjectContext() -> NSManagedObjectContext
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    private func mapManagedObjectToTimeSlot(_ managedObject: NSManagedObject) -> TimeSlot
    {
        let timeSlot = TimeSlot()
        timeSlot.startTime = managedObject.value(forKey: "startTime") as! Date
        timeSlot.endTime = managedObject.value(forKey: "endTime") as? Date
        timeSlot.category = Category(rawValue: managedObject.value(forKey: "category") as! String)!
        
        return timeSlot
    }
    
    private func getLastManagedTimeSlot() -> AnyObject?
    {
        return getLastNManagedTimeSlot()?.first
    }
    
    private func getLastNManagedTimeSlot(_ n:Int = 1) -> [AnyObject]?
    {
        let managedContext = getManagedObjectContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: timeSlotEntityName, in: managedContext)!
        request.fetchLimit = n
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        
        do
        {
            let managedTimeSlot = try managedContext.fetch(request)
            return managedTimeSlot as [AnyObject]?
        }
        catch
        {
            loggingService.log(withLogLevel: .error, message: "No TimeSlots found")
            return nil
        }
    }
    
    private func endPreviousTimeSlot(atDate date: Date) -> Bool
    {
        guard let managedTimeSlot = getLastManagedTimeSlot() else { return true }
        
        let startDate = managedTimeSlot.value(forKey: "startTime") as! Date
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
        
        managedTimeSlot.setValue(endDate, forKey: "endTime")
        
        do
        {
            try getManagedObjectContext().save()
//            loggingService.log(withLogLevel: .error, message: "TimeSlot created at \(timeSlot.startTime) ended at \(timeSlot.endTime)")
            return true
        }
        catch
        {
//            loggingService.log(withLogLevel: .error, message: "Failed to end TimeSlot started at \(timeSlot.startTime) with category \(timeSlot.category)")
            return false
        }
    }
}
