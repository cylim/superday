import Foundation
import CoreLocation

protocol SmartGuessService
{
    func getCategory(forLocation: CLLocation) -> Category
}
