import Foundation
import CoreData
import CoreLocation

class CoreDataModelAdapter<T>
{
    func getModel(fromManagedObject managedObject: NSManagedObject) -> T
    {
        fatalError("Not implemented")
    }
    
    func setManagedElementProperties(fromModel model: T, managedObject: NSManagedObject)
    {
        fatalError("Not implemented")
    }
    
    var sortDescriptors : [NSSortDescriptor]!
}

class TimeSlotModelAdapter : CoreDataModelAdapter<TimeSlot>
{
    override init()
    {
        super.init()
        
        self.sortDescriptors = [ NSSortDescriptor(key: "startTime", ascending: false) ]
    }
    
    override func getModel(fromManagedObject managedObject: NSManagedObject) -> TimeSlot
    {
        let startTime = managedObject.value(forKey: "startTime") as! Date
        let endTime = managedObject.value(forKey: "endTime") as? Date
        let category = Category(rawValue: managedObject.value(forKey: "category") as! String)!
        
        let possibleTime = managedObject.value(forKey: "locationTime") as? Date
        let possibleLatitude = managedObject.value(forKey: "locationLatitude") as? Double
        let possibleLongitude = managedObject.value(forKey: "locationLongitude") as? Double
        
        //Entries created on versions <= 0.5.3 don't have any location information attached
        guard let time = possibleTime, let latitude = possibleLatitude, let longitude = possibleLongitude else
        {
            let timeSlot = TimeSlot(withStartTime: startTime, endTime: endTime, category: category)
            return timeSlot
        }
        
        let wasSmartGuessed = managedObject.value(forKey: "wasSmartGuessed") as? Bool ?? false
        
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //TODO: Should we store altitude and accuracy?
        let location = CLLocation(coordinate: coord, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: time)
        
        let timeSlot = TimeSlot(withStartTime: startTime,
                                endTime: endTime,
                                category: category,
                                location: location,
                                wasSmartGuessed: wasSmartGuessed)
        return timeSlot
    }
    
    override func setManagedElementProperties(fromModel model: TimeSlot, managedObject: NSManagedObject)
    {
        managedObject.setValue(model.startTime, forKey: "startTime")
        managedObject.setValue(model.endTime, forKey: "endTime")
        managedObject.setValue(model.category.rawValue, forKey: "category")
        
        managedObject.setValue(model.wasSmartGuessed, forKey: "wasSmartGuessed")
        managedObject.setValue(model.location?.timestamp, forKey: "locationTime")
        managedObject.setValue(model.location?.coordinate.latitude, forKey: "locationLatitude")
        managedObject.setValue(model.location?.coordinate.longitude, forKey: "locationLongitude")
    }
}

class SmartGuessModelAdapter : CoreDataModelAdapter<SmartGuess>
{
    override init()
    {
        super.init()
        
        self.sortDescriptors = [ NSSortDescriptor(key: "locationTime", ascending: false) ]
    }
    
    override func getModel(fromManagedObject managedObject: NSManagedObject) -> SmartGuess
    {
        let lastUsed = managedObject.value(forKey: "lastUsed") as? Date
        let errorCount = managedObject.value(forKey: "errorCount") as! Int
        let category = Category(rawValue: managedObject.value(forKey: "category") as! String)!
        
        let time = managedObject.value(forKey: "locationTime") as! Date
        let latitude = managedObject.value(forKey: "locationLatitude") as! Double
        let longitude = managedObject.value(forKey: "locationLongitude") as! Double
        
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //TODO: Should we store altitude and accuracy?
        let location = CLLocation(coordinate: coord, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: time)
        
        let smartGuess = SmartGuess(withCategory: category, location: location, errorCount: errorCount)
        smartGuess.lastUsed = lastUsed
        
        return smartGuess
    }
    
    override func setManagedElementProperties(fromModel model: SmartGuess, managedObject: NSManagedObject)
    {
        managedObject.setValue(model.category, forKey: "category")
        managedObject.setValue(model.lastUsed, forKey: "lastUsed")
        managedObject.setValue(model.errorCount, forKey: "errorCount")
        
        managedObject.setValue(model.location.timestamp, forKey: "locationTime")
        managedObject.setValue(model.location.coordinate.latitude, forKey: "locationLatitude")
        managedObject.setValue(model.location.coordinate.longitude, forKey: "locationLongitude")
    }
}
