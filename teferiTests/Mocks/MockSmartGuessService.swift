@testable import teferi
import CoreLocation

class MockSmartGuessService : SmartGuessService
{
    var categoryToReturn = Category.unknown
    
    func getCategory(forLocation: CLLocation) -> teferi.Category
    {
        return categoryToReturn
    }
}
