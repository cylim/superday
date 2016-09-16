import CoreData
import UIKit

class CoreDataPersistencyService : PersistencyService
{
    fileprivate(set) static var instance = CoreDataPersistencyService()
    
    fileprivate init()
    {
        
    }
    
    let timeSlotEntityName = "TimeSlot"
    
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
            return true
        }
        catch
        {
            return false
        }
    }
    
    func getTimeSlotsForDay(_ date: Date) -> [TimeSlot]
    {
        let startTime = date.ignoreTimeComponents()
        let endTime = date.addDays(1).ignoreTimeComponents()
        
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
    
    fileprivate func getManagedObjectContext() -> NSManagedObjectContext
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    fileprivate func mapManagedObjectToTimeSlot(_ managedObject: NSManagedObject) -> TimeSlot
    {
        let timeSlot = TimeSlot()
        timeSlot.startTime = managedObject.value(forKey: "startTime") as! Date
        timeSlot.endTime = managedObject.value(forKey: "endTime") as? Date
        timeSlot.category = Category(rawValue: managedObject.value(forKey: "category") as! String)!
        
        return timeSlot
    }
    
    fileprivate func endPreviousTimeSlot() -> Bool
    {
        let managedContext = getManagedObjectContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: timeSlotEntityName, in: managedContext)!
        request.fetchLimit = 5
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        
        do
        {
            guard let managedTimeSlot = try managedContext.fetch(request).first else { return true }
            
            let timeSlot = mapManagedObjectToTimeSlot(managedTimeSlot as! NSManagedObject)
            let actualEndTime = timeSlot.startTime.addingTimeInterval(timeSlot.duration)
            
            (managedTimeSlot as AnyObject).setValue(actualEndTime, forKey: "endTime")
            
            try managedContext.save()
            return true
        }
        catch
        {
            return false
        }
    }
    
}
