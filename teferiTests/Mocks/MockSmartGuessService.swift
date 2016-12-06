@testable import teferi
import CoreLocation

class MockSmartGuessService : SmartGuessService
{
    //MARK: Properties
    var addShouldWork = true
    var categoryToReturn = Category.unknown
    
    func get(forLocation location: CLLocation) -> SmartGuess
    {
        return SmartGuess(withId: 0, category: categoryToReturn, location: location)
    }
    
    func add(smartGuess: SmartGuess) -> Bool
    {
        return self.addShouldWork
    }
    
    func strike(withId id: Int)
    {
    }
    
    func purgeEntries(olderThan: Int)
    {
        
    }
}
