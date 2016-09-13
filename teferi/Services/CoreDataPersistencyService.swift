import CoreData
import UIKit

class CoreDataPersistencyService : PersistencyService
{
    private(set) static var instance = CoreDataPersistencyService()
    
    private init()
    {
        
    }
    
    let timeSlotEntityName = "TimeSlot"
    
    func createTimeSlot(timeSlot: TimeSlot) -> Bool
    {
        let managedContext = getManagedObjectContext()
        let entity =  NSEntityDescription.entityForName(timeSlotEntityName, inManagedObjectContext: managedContext)!
        let managedTimeSlot = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedContext)
        
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
    
    func updateTimeSlot(timeSlot: TimeSlot) -> Bool
    {
        let managedContext = getManagedObjectContext()
        
        let entity = NSEntityDescription.entityForName(timeSlotEntityName, inManagedObjectContext: managedContext)
        let request = NSFetchRequest()
        let predicate = NSPredicate(format: "startTime == %@", timeSlot.startTime)
        
        request.entity = entity
        request.predicate = predicate
        
        // Set the sorting -- mandatory, even if you're fetching a single record/object
        //let sortDescriptor = NSSortDescriptor() initWithKey:@"yourIdentifyingQualifier" ascending:YES];
        //NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        //[request setSortDescriptors:sortDescriptors];
//        [sortDescriptors release]; sortDescriptors = nil;
//        [sortDescriptor release]; sortDescriptor = nil;
        
        do
        {
            let managedTimeSlot = try managedContext.executeFetchRequest(request).first!;
            managedTimeSlot.setValue(timeSlot.startTime, forKey: "startTime")
            managedTimeSlot.setValue(timeSlot.endTime, forKey: "endTime")
            managedTimeSlot.setValue(timeSlot.category.rawValue, forKey: "category")
            
            try managedContext.save()
            return true
        }
        catch
        {
            return false
        }
    }
    
    func getTimeSlotsForDay(date: NSDate) -> [TimeSlot]
    {
        let startTime = date.ignoreTimeComponents()
        let endTime = date.addDays(1).ignoreTimeComponents()
        
        let fetchRequest = NSFetchRequest(entityName: timeSlotEntityName)
        fetchRequest.predicate = NSPredicate(format: "(startTime >= %@) AND (startTime <= %@)", startTime, endTime)
     
        do
        {
            let results = try getManagedObjectContext().executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
            let timeSlots = results.map(mapManagedObjectToTimeSlot)
            return timeSlots
        }
        catch
        {
            return []
        }
    }
    
    private func getManagedObjectContext() -> NSManagedObjectContext
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    private func mapManagedObjectToTimeSlot(managedObject: NSManagedObject) -> TimeSlot
    {
        let timeSlot = TimeSlot()
        timeSlot.startTime = managedObject.valueForKey("startTime") as! NSDate
        timeSlot.endTime = managedObject.valueForKey("endTime") as? NSDate
        timeSlot.category = Category(rawValue: managedObject.valueForKey("category") as! String)!
        
        return timeSlot
    }
}