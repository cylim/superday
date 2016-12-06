import Foundation
import CoreLocation

protocol SmartGuessService
{
    typealias Days = Int
    
    func get(forLocation: CLLocation) -> SmartGuess
    
    func add(smartGuess: SmartGuess) -> Bool
    
    func strike(withId id: Int)
    
    func purgeEntries(olderThan: Days)
}
