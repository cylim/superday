import Foundation
import CoreLocation

protocol SmartGuessService
{
    func get(forLocation: CLLocation) -> SmartGuess
    
    func add(smartGuess: SmartGuess) -> Bool
    
    func strike(withId id: Int)
}
