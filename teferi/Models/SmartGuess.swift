import CoreLocation

class SmartGuess
{
    let errorCount : Int
    var lastUsed : Date?
    let category : Category
    let location : CLLocation
    
    init(withCategory category: Category, location: CLLocation)
    {
        self.errorCount = 0
        self.category = category
        self.location = location
    }
    
    init(withCategory category: Category, location: CLLocation, errorCount: Int)
    {
        self.category = category
        self.location = location
        self.errorCount = errorCount
    }
}
