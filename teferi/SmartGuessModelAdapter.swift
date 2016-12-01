import CoreData
import CoreLocation

class SmartGuessModelAdapter : CoreDataModelAdapter<SmartGuess>
{
    //MARK: Fields
    private let lastUsedKey = "lastUsed"
    private let categoryKey = "category"
    private let errorCountKey = "errorCount"
    private let locationTimeKey = "locationTime"
    private let locationLatitudeKey = "locationLatitude"
    private let locationLongitudeKey = "locationLongitude"
    
    override init()
    {
        super.init()
        
        self.sortDescriptors = [ NSSortDescriptor(key: self.locationTimeKey, ascending: false) ]
    }
    
    override func getModel(fromManagedObject managedObject: NSManagedObject) -> SmartGuess
    {
        let lastUsed = managedObject.value(forKey: self.lastUsedKey) as? Date
        let errorCount = managedObject.value(forKey: self.errorCountKey) as! Int
        let category = Category(rawValue: managedObject.value(forKey: self.categoryKey) as! String)!
        
        let location = super.getLocation(managedObject,
                                         timeKey: self.locationTimeKey,
                                         latKey: self.locationLatitudeKey,
                                         lngKey: self.locationLongitudeKey)!
        
        let smartGuess = SmartGuess(withCategory: category, location: location, errorCount: errorCount)
        smartGuess.lastUsed = lastUsed
        
        return smartGuess
    }
    
    override func setManagedElementProperties(fromModel model: SmartGuess, managedObject: NSManagedObject)
    {
        managedObject.setValue(model.category, forKey: self.categoryKey)
        managedObject.setValue(model.lastUsed, forKey: self.lastUsedKey)
        managedObject.setValue(model.errorCount, forKey: self.errorCountKey)
        
        managedObject.setValue(model.location.timestamp, forKey: self.locationTimeKey)
        managedObject.setValue(model.location.coordinate.latitude, forKey: self.locationLatitudeKey)
        managedObject.setValue(model.location.coordinate.longitude, forKey: self.locationLongitudeKey)
    }
}
