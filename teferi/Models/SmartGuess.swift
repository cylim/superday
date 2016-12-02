import CoreLocation

class SmartGuess
{
    let id : Int
    var errorCount : Int
    var lastUsed : Date?
    let category : Category
    let location : CLLocation
    
    init(withId id: Int, category: Category, location: CLLocation)
    {
        self.id = id
        self.errorCount = 0
        self.category = category
        self.location = location
    }
    
    init(withId id: Int, category: Category, location: CLLocation, errorCount: Int)
    {
        self.id = id
        self.category = category
        self.location = location
        self.errorCount = errorCount
    }
    
    static let empty = SmartGuess(withId: -1, category: .unknown, location: CLLocation())
}
