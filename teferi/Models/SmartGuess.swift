import CoreLocation

class SmartGuess
{
    let id : Int
    var errorCount : Int
    var lastUsed : Date
    let category : Category
    let location : CLLocation
    
    init(withId id: Int, category: Category, location: CLLocation, lastUsed: Date)
    {
        self.id = id
        self.errorCount = 0
        self.lastUsed = lastUsed
        self.category = category
        self.location = location
    }
    
    init(withId id: Int, category: Category, location: CLLocation, lastUsed: Date, errorCount: Int)
    {
        self.id = id
        self.lastUsed = lastUsed
        self.category = category
        self.location = location
        self.errorCount = errorCount
    }
}
