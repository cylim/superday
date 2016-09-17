import CoreData
import UIKit

class CoreDataPersistencyService : PersistencyService
{
    //MARK: Static properties
    private(set) static var instance = CoreDataPersistencyService()
    
    //MARK: Initializers
    private init()
    {
        
    }
    
    //MARK: Fields
    private let timeSlotEntityName = "TimeSlot"
    private var callbacks = [(TimeSlot) -> ()]()
    
    //MARK: PersistencyService implementation
    func addNewTimeSlot(_ timeSlot: TimeSlot) -> Bool
    {
        guard endPreviousTimeSlot() else { return false }
        
        let managedContext = getManagedObjectContext()
        let entity =  NSEntityDescription.entity(forEntityName: timeSlotEntityName, in: managedContext)!
        let managedTimeSlot = NSManagedObject(entity: entity, insertInto: managedContext)
        
        managedTimeSlot.setValue(timeSlot.startTime, forKey: "startTime")
        managedTimeSlot.setValue(timeSlot.endTime, forKey: "endTime")
        managedTimeSlot.setValue(timeSlot.category.rawValue, forKey: "category")
        
        do
        {
            try managedContext.save()
            callbacks.forEach { callback in callback(timeSlot) }
            return true
        }
        catch
        {
            return false
        }
    }
    
    func getTimeSlots(forDay date: Date) -> [TimeSlot]
    {
        let startTime = date.ignoreTimeComponents()
        let endTime = date.tomorrow.ignoreTimeComponents()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: timeSlotEntityName)
        fetchRequest.predicate = NSPredicate(format: "(startTime >= %@) AND (startTime <= %@)", startTime as NSDate, endTime as NSDate)
     
        do
        {
            let results = try getManagedObjectContext().fetch(fetchRequest) as! [NSManagedObject]
            
            let timeSlots = results.map(mapManagedObjectToTimeSlot)
            return timeSlots
        }
        catch
        {
            return []
        }
    }
    
    func getLastTimeSlot() -> TimeSlot
    {
        guard let managedTimeSlot = getLastManagedTimeSlot() else { return TimeSlot() }
        
        let timeSlot = mapManagedObjectToTimeSlot(managedTimeSlot as! NSManagedObject)
        return timeSlot
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
        let managedContext = getManagedObjectContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: timeSlotEntityName, in: managedContext)!
        request.fetchLimit = 5
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        
        do
        {
            guard let managedTimeSlot = try managedContext.fetch(request).first else { return nil }
            return managedTimeSlot as AnyObject?
        }
        catch
        {
            return nil
        }
    }
    
    private func endPreviousTimeSlot() -> Bool
    {
        do
        {
            guard let managedTimeSlot = getLastManagedTimeSlot() else { return true }
            let timeSlot = mapManagedObjectToTimeSlot(managedTimeSlot as! NSManagedObject)
            let actualEndTime = timeSlot.startTime.addingTimeInterval(timeSlot.duration)
            
            managedTimeSlot.setValue(actualEndTime, forKey: "endTime")
            
            try getManagedObjectContext().save()
            return true
        }
        catch
        {
            return false
        }
    }
}
