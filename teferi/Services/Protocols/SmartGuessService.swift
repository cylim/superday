import Foundation
import CoreLocation

protocol SmartGuessService
{
    func get(forLocation: CLLocation) -> SmartGuess?
    
    @discardableResult func add(withCategory category: Category, location: CLLocation) -> SmartGuess?
    
    func strike(withId id: Int)
    
    func purgeEntries(olderThan maxAge: Date)
}
