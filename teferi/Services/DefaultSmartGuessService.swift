import Foundation
import CoreLocation

class DefaultSmartGuessService : SmartGuessService
{
    //MARK: Fields
    private let persistencyService : BasePersistencyService<SmartGuess>
    
    init(persistencyService: BasePersistencyService<SmartGuess>)
    {
        self.persistencyService = persistencyService
    }
    
    func getCategory(forLocation location: CLLocation) -> Category
    {
        let bestMatches = self.persistencyService.get()
            .filter(self.isWithinHundredMeters(location))
            .sorted { $0.location.distance(from: location) > $1.location.distance(from: location) }
        
        guard let bestMatch = bestMatches.first else { return .unknown }
        
        //Every time a dictionary entry gets used in a guess, it gets refreshed.
        //Entries not refresh in N days get purged
        bestMatch.lastUsed = Date()
        return bestMatch.category
    }
    
    private func isWithinHundredMeters(_ location: CLLocation) -> (SmartGuess) -> Bool
    {
        return { smartGuess in return smartGuess.location.distance(from: location) <= 100 }
    }
}
